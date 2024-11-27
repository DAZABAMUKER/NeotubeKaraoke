//
//  Parse.swift
//  NeotubeKaraoke
//
//  Created by 안병욱 on 10/10/23.
//

import Foundation

class Parse {
    
    func get_Parse(url: String) {
        let watchUrl = URL(string: url)!
        var request = URLRequest(url: watchUrl)
        request.setValue("Mozilla/5.0", forHTTPHeaderField: "User-Agent")
        request.setValue("en-US,en", forHTTPHeaderField: "accept-language")
        URLSession.shared.dataTask(with: request) { data, response, error in
            if error != nil || data == nil {
                print(error as Any)
                return
            }
            do {
                let content = String(data: data!, encoding: .utf8) ?? ""
                //print(content)
                Extract().initial_player_response(watch_html: content)
//                guard let regData = content.range(of: #"ytInitialPlayerResponse\s*=\s*"#, options: .regularExpression) else {
//                    return
//                }
//                let startPoint = content.index(regData.lowerBound, offsetBy: 26)
//                //print(content[startPoint])
//                //print(startPoint)
//                let html = content[startPoint...content.index(before: content.endIndex)]
//                
//                if !["{", "["].contains(html[html.startIndex]) {
//                    
//                }
                //let full_obj = self.find_object_from_startpoint(html: String(html), start_point: startPoint)
                //let full_obj = self.parse_for_object(html: String(html), preceding_regex: <#T##String#>)(html: String(html), start_point: startPoint)
                //print(full_obj)
            }
        }.resume()
    }
    
    enum ParseError: Error {
        case invalidStartPoint(start: Character, context: String)
        case unmatchedBraces(context: String)
    }

    func findNestedObjectFastBytes(from html: String, startPoint: Int) throws -> String {
        // UTF-8 바이트 배열로 변환
        let bytes = Array(html.utf8)
        guard startPoint < bytes.count else {
            throw NSError(domain: "Invalid start point", code: -1, userInfo: nil)
        }
        
        //let openBraces: [UInt8: UInt8] = [UInt8(ascii: "{"): UInt8(ascii: "}"), UInt8(ascii: "["): UInt8(ascii: "]")]
//        guard let opener = openBraces[bytes[startPoint]] else {
//            throw NSError(domain: "Invalid start character", code: -1, userInfo: nil)
//        }
        let opener = UInt8(ascii: "{")
        let closer = UInt8(ascii: "}")
        
        // 스택 기반으로 중첩 구조 탐색
        var stack: [UInt8] = [bytes[startPoint]]
        var currentIndex = startPoint + 1
        
        while currentIndex < bytes.count {
            let currentChar = bytes[currentIndex]
            
            if currentChar == opener {
                stack.append(currentChar) // 새로운 중첩 시작
            } else if currentChar == closer {
                stack.popLast() // 중첩 끝
            }
            
            // 스택이 비면 전체 객체를 찾음
            if stack.isEmpty {
                let objectData = Data(bytes[startPoint...currentIndex])
                if let jsonString = String(data: objectData, encoding: .utf8) {
                    //print(jsonString)
                    return jsonString
                } else {
                    throw NSError(domain: "Failed to decode JSON", code: -1, userInfo: nil)
                }
            }
            
            currentIndex += 1
            //print(currentIndex)
        }
        print(stack.count)
        throw NSError(domain: "Unmatched braces", code: -1, userInfo: nil)
    }
    
    func findObjectOptimized(from html: String, startPoint: Int) throws -> String {
        guard startPoint >= 0 && startPoint < html.count else {
            throw ParseError.invalidStartPoint(start: " ", context: String(html.prefix(20)))
        }
        
        let startIndex = html.index(html.startIndex, offsetBy: startPoint)
        let subHtml = html[startIndex...]
        
        guard let firstChar = subHtml.first, ["{", "["].contains(firstChar) else {
            throw ParseError.invalidStartPoint(start: Character("0"), context: String(subHtml.prefix(20)))
        }
        
        var stack: [Character] = [firstChar]
        var lastChar: Character = firstChar
        var index = subHtml.index(after: subHtml.startIndex)
        let closers: [Character: Character] = ["{": "}", "[": "]", "\"": "\"", "/": "/"]
        
        while index < subHtml.endIndex {
            if stack.isEmpty { break }
            
            let currentChar = subHtml[index]
            
            if !currentChar.isWhitespace {
                lastChar = currentChar
            }
            
            if let closer = closers[stack.last!], currentChar == closer {
                stack.popLast()
            } else if closers.keys.contains(currentChar) {
                if !(currentChar == "/" && !["(", ",", "=", ":", "[", "!", "&", "|", "?", "{", "}", ";"].contains(lastChar)) {
                    stack.append(currentChar)
                }
            } else if stack.last == "\"" || stack.last == "/", currentChar == "\\" {
                index = subHtml.index(index, offsetBy: 2, limitedBy: subHtml.endIndex) ?? subHtml.endIndex
                continue
            }
            
            index = subHtml.index(after: index)
        }
        
        if !stack.isEmpty {
            throw ParseError.unmatchedBraces(context: String(subHtml.prefix(20)))
        }
        
        return String(subHtml[..<index])
    }
    
    func find_object_from_startpoint(html: String, start_point: String.Index) -> String.SubSequence {
        
        let html = html
        
        var last_char: Character = "{"
        var curr_char:Character = " "
        var stack = [html[html.startIndex]]
        var i = 1
        
        let context_closers:[Character:Character] = [
            "{" : "}",
            "[" : "]",
            "\"" : "\"",
            "/" : "/"
        ]
        
        while i < html.count {
            if stack.count == 0 {
                break
            }
            if ![" ", "\n"].contains(curr_char) {
                last_char = curr_char
            }
            
            curr_char = html[html.index(html.startIndex, offsetBy: i)]
            print(i)
            let curr_context = stack[stack.index(before: stack.endIndex)]
            
            if curr_char == context_closers[curr_context] {
                //print("here")
                //print(curr_char)
                stack.removeLast()
                //print("now")
                i += 1
                //print("!!")
                continue
            }
            if ["\"", "/"].contains(curr_context) {
                if curr_char == "\\"{
                    i += 2
                    continue
                }
            } else {
                if context_closers.keys.contains(curr_char){
                    if !(curr_char == "/" && !["(", ",", "=", ":", "[", "!", "&", "|", "?", "{", "}", ";"].contains(last_char)){
                        stack.append(curr_char)
                    }
                }
            }
            i += 1
        }
        let full_obj = html[html.startIndex...html.index(html.startIndex, offsetBy: i)]
        print(full_obj)
        return full_obj
    }
    
    func parse_for_object(html: String, preceding_regex: String) {
        /*
         Parses input html to find the end of a JavaScript object.

            :param str html:
                HTML to be parsed for an object.
            :param str preceding_regex:
                Regex to find the string preceding the object.
            :rtype dict:
            :returns:
                A dict created from parsing the object.
         */
        do {
            let regex = try NSRegularExpression(pattern: preceding_regex)
            print(regex)
            let range = NSRange(location: 0, length: html.count)
            print(range)
            if let matches = regex.firstMatch(in: html, options: [], range: range) {
                //let match = matches.first
                print("있음")
                let start = html.range(of: preceding_regex, options: .regularExpression)?.lowerBound//matches.range.upperBound
                //let startIndex = html.utf8.index(html.startIndex, offsetBy: start)
                //print(start)
                //let end = html.utf8.index(html.startIndex, offsetBy: start)
                var object = String(html[(start ?? html.startIndex)..<html.endIndex]).lowercased()
                let openCloser = object.range(of: #"{"#, options: .regularExpression)?.lowerBound
                let closeCloser = object.range(of: #"</script>"#, options: .regularExpression)?.lowerBound
                object = String(object[(openCloser ?? object.startIndex)..<(closeCloser ?? object.endIndex)])
                //print(object)
                let jsonString = try findNestedObjectFastBytes(from: object, startPoint: 0)
                //let info = try JSONDecoder().decode(TubeResponse.self, from: jsonString.data(using: .utf8) ?? Data())
                //print(info.streamingData.adaptiveFormats?.first?.signatureCipher!)
                //let json = try JSONSerialization.jsonObject(with: jsonString.data(using: .utf8) ?? Data()) as! [String: Any]
                let jsonConverted = try JSONDecoder().decode(TubeResponseBrowser.self, from: jsonString.data(using: .utf8) ?? Data())
                print(jsonConverted.streamingdata?.adaptiveformats?.first?.signaturecipher)
                let sig = jsonConverted.streamingdata?.adaptiveformats?.first?.signaturecipher
                let sOpen = sig?.ranges(of: #"s="#).first?.lowerBound
                let sClose = sig?.ranges(of: #"&"#).first?.lowerBound
                //let sRange = sOpen..<sClose
                let s = sig?.substring(with: sOpen!..<sClose!) ?? ""
                print(s)
                //print(json.keys)
                //let jsonStream = json["streamingdata"] as! NSDictionary
                //let adaptive = (jsonStream["adaptiveformats"] as! NSArray).firstObject as! NSDictionary
                //print(adaptive["signaturecipher"])
                //let streamData = try JSONSerialization.jsonObject(with: jsonStream) as! [String: Any]
                //print(json["streamingdata"] ?? "no Value")
                //find_object_from_startpoint(html: object, start_point: object.startIndex)
            }
        } catch {
            print(#function, error)
        }
    }
    
    func parseForObjectFromStartPoint() {
        
    }
}

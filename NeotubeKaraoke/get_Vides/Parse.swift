//
//  Parse.swift
//  NeotubeKaraoke
//
//  Created by 안병욱 on 10/10/23.
//

import Foundation
import JavaScriptCore

class Parse {
    
    var signature = ""
    var signUrl = ""
    
    func get_Parse(url: String, video: Bool = true, videoId: String = "", sigParam: [String:String] = [:]) {
        let watchUrl = URL(string: url)!
        var request = URLRequest(url: watchUrl)
        request.setValue("Mozilla/5.0", forHTTPHeaderField: "User-Agent")
        request.setValue("www.youtube.com", forHTTPHeaderField: "Host")
        request.setValue("*/*", forHTTPHeaderField: "Accept")
        request.setValue("gzip, deflate, br", forHTTPHeaderField: "Accept-Encoding")
        request.setValue("https://www.youtube.com/watch?v=\(videoId)", forHTTPHeaderField: "Referer")
        request.setValue("https://www.youtube.com/)", forHTTPHeaderField: "Origin")
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if error != nil || data == nil {
                print(error as Any)
                return
            }
            do {
                guard let data = data else { return print(#function, "Data Unwarpping Failed") }
                let content = String(data: data, encoding: .utf8) ?? ""
                //print(content)
                if video {
                    let extract = Extract()
                    extract.initial_player_response(watch_html: content)
                    //print(content)
                    
                } else {
                    //print(content)
                    if let funcName = Decipher().extractSignatureFunctionName(from: content),
                       let varCode = Decipher().signatureFunctionVaricode(from: content),
                       let funcCode = Decipher().extract_function_code(from: content, functionName: funcName, variableName: varCode[0])
                    {
                        print("Signature function name: \(funcName)")
                        
                        //print("Signature variable code: \(varCode)")
                        //print("Signature function code: \(funcCode)")
                        let context = JSContext()
                        print("✅✅✅✅✅✅✅✅✅✅✅✅")
                        print(varCode.last)
                        context?.evaluateScript(varCode.last)
                        for helper in funcCode {
                            print(helper)
                            context?.evaluateScript(helper)
                        }
                        let signature = sigParam["s"]
                        print(context?.debugDescription ?? "No Context")
                        
                        if let decrypted = context?.objectForKeyedSubscript(funcName) {
                            //let encryptedSignature = " // 암호화된 서명
                            print("✅", signature)
                            let result = decrypted.call(withArguments: [signature])
                            //result?.context.
                            print(funcName)
                            print("~~~~~", decrypted)
                            print("Decrypted signature: \(result?.toString() ?? "Error")")
                            let sigs = "&"+(sigParam["sp"] ?? "sig")+"="+((result?.toString() ?? "Error").addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")
                            let finalURL = (sigParam["url"] ?? "")+sigs
                            
                            print("Final URL", finalURL)
                        }
                        
                    } else {
                        print("Signature function name not found.")
                        
                    }
                    
                    
                    //let decrypt = Decipher().getMainFunction(jsFile: content, signature: self.signature, pattern: #"[\{\d\w\(\)\\.="]*?;(..\...\(.\,..?\);){3,}.*?\}"#, sig: true)
                    
                    //let nFunc = Decipher().getMainFunction(jsFile: content, signature: self.signature, pattern: #"(?:.get\("n"\)\)&&\(b=|(?:b=String\.fromCharCode\(110\)|(?:[a-zA-Z0-9_$.]+)&&\(b="nn"\[\+.+?\])(?:,[a-zA-Z0-9_$]+\(a\))?,c=a\.(?:get\(b\)|[a-zA-Z0-9_$]+\[b\]\|\|null)\)&&\(c=|\b(?:[a-zA-Z0-9_$]+)=)(?:[a-zA-Z0-9_$]+)(?:\[(?:\d+)\])?\([a-zA-Z]\)(?:,[a-zA-Z0-9_$]+\.set\((?:"n+"|[a-zA-Z0-9_$]+),([a-zA-Z0-9_$]+)\))"#, sig: false)
                                                             
                    //print(self.signUrl.removingPercentEncoding ?? "" + "&sig=\(decrypt)")
                    //print(self.signature)
                    //print(decrypt)
                    //print("\(self.signUrl.removingPercentEncoding ?? "")&sig=\(decrypt)")
                }
                //extract.get_ytplayer_config(watch_html: content)
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
            let lastStack = stack.last ?? " "
            if let closer = closers[lastStack], currentChar == closer {
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
            //print(regex)
            let range = NSRange(location: 0, length: html.count)
            //print(range)
            if let matches = regex.firstMatch(in: html, options: [], range: range) {
                //let match = matches.first
                print("있음")
                let start = html.range(of: preceding_regex, options: .regularExpression)?.lowerBound//matches.range.upperBound
                //print(html[html.range(of: preceding_regex, options: .regularExpression)!])
                //let startIndex = html.utf8.index(html.startIndex, offsetBy: start)
                //print(start)
                //let end = html.utf8.index(html.startIndex, offsetBy: start)
                var object = String(html[(start ?? html.startIndex)..<html.endIndex])
                if preceding_regex == #"ytInitialPlayerResponse\s*=\s*"#{
                    getSignature(object: object, html: html)
                } else {
                    getJs(object: object)
                }
            }
        } catch {
            print(#function, error)
        }
    }
    
    func parseForObjectFromStartPoint() {
        
    }
    
    func getSignature(object: String, html: String) {
        do {
            var object = object
            let openCloser = object.range(of: #"{"#, options: .regularExpression)?.lowerBound
            let closeCloser = object.range(of: #"</script>"#, options: .regularExpression)?.lowerBound
            object = String(object[(openCloser ?? object.startIndex)..<(closeCloser ?? object.endIndex)])
            //print(object)
            let jsonString = try findNestedObjectFastBytes(from: object, startPoint: 0)
            //let info = try JSONDecoder().decode(TubeResponse.self, from: jsonString.data(using: .utf8) ?? Data())
            //print(info.streamingData.adaptiveFormats?.first?.signatureCipher!)
            //let json = try JSONSerialization.jsonObject(with: jsonString.data(using: .utf8) ?? Data()) as! [String: Any]
            let jsonConverted = try JSONDecoder().decode(TubeResponse.self, from: jsonString.data(using: .utf8) ?? Data())
            //print(jsonConverted.streamingdata?.adaptiveformats?.first?.signaturecipher ?? "")
            let sig = jsonConverted.streamingData?.formats?.first?.signatureCipher ?? ""
            print(jsonConverted.streamingData?.formats.map{$0.map{$0.mimeType}})
            let sOpen = sig.index(sig.ranges(of: #"s="#).first?.lowerBound ?? sig.startIndex, offsetBy: 2)
            let urlOpen = sig.index(sig.ranges(of: #"url="#).first?.lowerBound ?? sig.startIndex, offsetBy: 4)
            //let sOpenOffset
            //let a = sig.ranges(of: #"s="#).first?.lowerBound
            guard let sClose = sig.ranges(of: #"&"#).first?.lowerBound else {return print(#function, "get signature sclose variable failed")}
            //let sRange = sOpen..<sClose
            self.signature = String(sig[sOpen..<sClose])//.replacingOccurrences(of: "%253D", with: "%3D").replacingOccurrences(of: "%3D", with: "=")
            self.signUrl = String(sig[urlOpen...])
            //print(signUrl.removingPercentEncoding)
            parse_for_object(html: html, preceding_regex: #"jsUrl":"(.*?)"#)
            
            print(self.signature)
            print(signUrl)
            //print(sig)
            //print(json.keys)
            //let jsonStream = json["streamingdata"] as! NSDictionary
            //let adaptive = (jsonStream["adaptiveformats"] as! NSArray).firstObject as! NSDictionary
            //print(adaptive["signaturecipher"])
            //let streamData = try JSONSerialization.jsonObject(with: jsonStream) as! [String: Any]
            //print(json["streamingdata"] ?? "no Value")
            //find_object_from_startpoint(html: object, start_point: object.startIndex)
            
        }
        catch {
            print(#function, error)
        }
    }
    
    func getJs(object: String) {
        do {
            var object = object
            let open = object.firstIndex(of: "/") ?? "".startIndex
            let close = object.range(of: "base.js", options: .regularExpression)?.lowerBound ?? "".endIndex
            //print(object[open!..<close!])
            //let jsUrl = "https://youtube.com\(object[open..<close])base.js"
            let jsUrl = "https://www.youtube.com/s/player/2f1832d2/player_ias.vflset/en_US/base.js"
            print(jsUrl)
            let jsFile = get_Parse(url: jsUrl, video: false)
            //print(jsFile)
            
        }
        catch {
            
        }
    }
}

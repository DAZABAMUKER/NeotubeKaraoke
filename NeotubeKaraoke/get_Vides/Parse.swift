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
                guard let regData = content.range(of: #"ytInitialPlayerResponse\s*=\s*"#, options: .regularExpression) else {
                    return
                }
                let startPoint = content.index(regData.lowerBound, offsetBy: 26)
                //print(content[startPoint])
                //print(startPoint)
                let html = content[startPoint...content.index(before: content.endIndex)]
                
                if !["{", "["].contains(html[html.startIndex]) {
                    
                }
                let full_obj = self.find_object_from_startpoint(html: String(html), start_point: startPoint)
                print(full_obj)
            }
        }.resume()
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
        //print(i)
        return full_obj
    }
    
    func parse_for_object(html: String, preceding_regex: String) {
        
    }
}

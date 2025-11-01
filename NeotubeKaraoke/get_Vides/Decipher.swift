//
//  Decipher.swift
//  NeotubeKaraoke
//
//  Created by 안병욱 on 11/30/24.
//

import Foundation
import JavaScriptCore

class JavaScriptFunctionExtractor {
    func extractFunctionFromCode(argNames: [String], code: String, globalStack: [String: Any] = [:]) -> String? {
        var localVars: [String: String] = [:]
        var code = code

        while let match = findFunctionDefinition(in: code) {
            let range = match.range
            guard let argsRange = Range(match.range(withName: "args"), in: code) else { break }
            
            let argsString = String(code[argsRange])
            let args = argsString.split(separator: ",").map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            
            // Extract the function body
            let bodyStartIndex = code.index(code.startIndex, offsetBy: range.upperBound - 1)
            guard let (body, remaining) = separateAtParen(from: String(code[bodyStartIndex...])) else { break }
            
            // Recursive call to extract nested functions
            if let functionName = extractFunctionFromCode(argNames: args, code: body, globalStack: localVars) {
                let functionReference = assignName(to: functionName, in: &localVars)
                // Replace the current function definition in the code
                let startIndex = code.index(code.startIndex, offsetBy: range.lowerBound)
                let endIndex = code.index(code.startIndex, offsetBy: range.upperBound)
                code.replaceSubrange(startIndex..<endIndex, with: functionReference + remaining)
            }
        }

        // Build the final function
        return buildFunction(argNames: argNames, code: code, localVars: localVars, globalStack: globalStack)
    }

    private func findFunctionDefinition(in code: String) -> NSTextCheckingResult? {
        let pattern = #"function\((.*?[^)]*)\)\s*\{"#
        guard let regex = try? NSRegularExpression(pattern: pattern) else { return nil }
        return regex.firstMatch(in: code, options: [], range: NSRange(code.startIndex..<code.endIndex, in: code))
    }

    func separateAtParen(from code: String) -> (body: String, remaining: String)? {
        var openParenCount = 0
        var body = ""
        var remaining = ""
        var isBodyComplete = false

        for char in code {
            if char == "{" { openParenCount += 1 }
            if char == "}" { openParenCount -= 1 }

            if openParenCount == 0, isBodyComplete {
                remaining += String(char)
            } else {
                body += String(char)
                if openParenCount == 0 { isBodyComplete = true }
            }
        }

        return openParenCount == 0 ? (body, remaining) : nil
    }

    private func assignName(to functionCode: String, in localVars: inout [String: String]) -> String {
        let functionName = "func_\(localVars.count)"
        localVars[functionName] = functionCode
        return functionName
    }

    private func buildFunction(argNames: [String], code: String, localVars: [String: String], globalStack: [String: Any]) -> String {
        var functions = ""
        for (name, functionCode) in localVars {
            functions += "function \(name)\(functionCode)\n"
        }
        return functions + code
    }
}


class Decipher {
    
    
    func extractFunctionCode(from code: String, for funcName: String) throws -> ([String], String) {
        let pattern = #"(?:function\s+?\#(funcName)|\s*?\#(funcName)\s*?=\S*?function|(?: var|const|let)\s*?\#(funcName)\s*?=\s*?function)\s*?\((.*?)\)\{.*\};"#
        print(pattern)
        
        guard let regex = try? NSRegularExpression(pattern: pattern, options: [.dotMatchesLineSeparators, .caseInsensitive]) else {
            throw NSError(domain: "Invalid regex pattern", code: 01, userInfo: nil)
        }
        
        guard let match = regex.firstMatch(in: code, options: [], range: NSRange(location: 0, length: code.utf16.count)) else {
            throw NSError(domain: "Could not find JS function \(funcName)", code: 02, userInfo: nil)
        }
        print(match)
        guard let argsRange = Range(match.range(at: 1), in: code) else {
            throw NSError(domain: "args Range Error", code: 03)
        }
        guard let codeRange = Range(match.range(at: 0), in: code) else {
            throw NSError(domain: "nFunction Range error", code: 04)
        }
        let argsString = String(code[argsRange])
        let bodyCode = String(code[codeRange])
        
        print(argsString)
        //let args = argsString.split(separator: ",").map { $0.trimmingCharacters(in: .whitespaces) }
        
        let patterns = #";\s*if\s*\(\s*typeof\s+[a-zA-Z0-9_$]+\s*===?\s*(["'])undefined\1\s*\)\s*return\s+\#(argsString);"#
        let fixup = bodyCode.replacingOccurrences(of: ";", with: pattern)
        //let args = argsString.split(separator: ",").map { $0.trimmingCharacters(in: .whitespaces) }
        
        return ([argsString], bodyCode)
    }
    
    
    
    func getMainFunction(jsFile: String, signature: String, pattern: String, sig: Bool) -> String {
        let pattern = pattern
        //[\{\d\w\(\)\\.="]*?;(..\...\(.,..?\);){3,}.*?\}
        do {
            let regex = try NSRegularExpression(pattern: pattern)
            let range = NSRange(location: 0, length: jsFile.count)
            guard let match = regex.firstMatch(in: jsFile, options: [], range: range) else { print("failed to finding"); return ""}
            let matchRange = match.range(at: 0)
            guard let stringRange = Range(matchRange, in: jsFile) else { return "" }
            let mainFunction = jsFile[stringRange]
            if sig {
                let mainIndex = mainFunction.index(mainFunction.ranges(of: #"="#).first?.lowerBound ?? mainFunction.startIndex, offsetBy: 0)
                let mainFunctionName = mainFunction[..<mainIndex]
                let functionNameRegex = try NSRegularExpression(pattern: #"(\w\w)\..."#)
                guard let functionNameMatchRange = functionNameRegex.firstMatch(in: String(mainFunction), options: [], range: NSRange(location: 0, length: mainFunction.count))?.range(at: 1) else { return "" }
                guard let functionNameRange = Range(functionNameMatchRange, in: mainFunction) else { return "" }
                let functionName = String(mainFunction[functionNameRange])
                let varRegexPattern = #"var \#(functionName)=\{.+?\};"# //(.|\n)*?\};
                print(varRegexPattern)
                let varRegex = try NSRegularExpression(pattern: varRegexPattern, options: [.dotMatchesLineSeparators])
                let ranges = NSRange(location: 0, length: jsFile.count)
                let varMatch = varRegex.matches(in: jsFile, options: [], range: ranges)
                let results = varMatch.compactMap { match in
                    Range(match.range, in: jsFile).map { String(jsFile[$0]) }
                }
                results.first
                //print(varMatch?.)
                //guard let varMatch = varRegex.firstMatch(in: jsFile, options: [], range: ranges)?.range(at: 0) else { print(#function, "errr"); return }
                //guard let varRange = Range(varMatch, in: jsFile) else { print("errrrr2"); return }
                //let fullFuntion = String(jsFile[varRange])
                print(mainFunction)
                print(results)
                //print(signature)
                //let signature = "2aq0aqSyOoJXtK73m-uME_jv7-pT15gOFC02RFkGMqWpzEICs69VdbwQ0LDp1v7j8xx92efCJlYFYb1sUkkBSPOlPmXgIARw8JQ0qOAOAA"//signature.removingPercentEncoding ?? ""
                var algoJS = mainFunction + ";" + results.joined()// + "var output = \(mainFunctionName)(" + "signature" + ");"
                //print(algoJS)
                
                //MARK: - JSContext
                
                let context = JSContext()
                //print(jsFile)
                print(mainFunctionName)
                context?.evaluateScript(String(algoJS))
                print(context?.globalObject.isUndefined)
                if let decrypted = context?.objectForKeyedSubscript(String(mainFunctionName)) {
                    //let encryptedSignature = " // 암호화된 서명
                    print("✅", signature)
                    let result = decrypted.call(withArguments: [signature])
                    //result?.context.
                    print(mainFunctionName)
                    print("~~~~~", decrypted)
                    print("Decrypted signature: \(result?.toString() ?? "Error")")
                    //print(signature)
                    return result?.toString() ?? "error failed to decrypt"
                    print(decrypted)
                }
            } else {
                
                //print(jsFile[stringRange])
                let nfunc = jsFile[stringRange]
                print("nfunc: ",nfunc)
                let mainIndex = nfunc.index(nfunc.ranges(of: #"="#).first?.lowerBound ?? nfunc.startIndex, offsetBy: 1)
                let mainIndesEnd = nfunc.index(nfunc.ranges(of: #"["#).first?.lowerBound ?? nfunc.startIndex, offsetBy: 0)
                let nfuncName = nfunc[mainIndex..<mainIndesEnd]
                print("nFunc Name: ",nfuncName)
                let mainIdxIndex = nfunc.index(nfunc.ranges(of: #"]"#).first?.lowerBound ?? nfunc.startIndex, offsetBy: -1)
                let mainIDX = nfunc[mainIndesEnd...mainIdxIndex]
                let nfuncRegox = #"var \#(nfuncName)\s*=\s*\[(.+?)\]\s*[,;]"#
                let nregex = try NSRegularExpression(pattern: nfuncRegox, options: [])
                guard let match = nregex.firstMatch(in: jsFile, options: [], range: range) else { return "failed" }
                let matchRange = match.range(at: 1)
                guard let stringRange = Range(matchRange, in: jsFile) else { return "" }
                let mainNfunc = jsFile[stringRange]
                print("main nfunc: ", mainNfunc)
                let jsCode = try extractFunctionCode(from: jsFile, for: String(mainNfunc))
                //print(try extractFunctionCode(from: jsFile, for: String(mainNfunc)))
                
                
                print(match.numberOfRanges)
                let context = JSContext()
                context?.evaluateScript(jsCode.1)
                if let decrypted = context?.objectForKeyedSubscript(String(mainNfunc)) {
                    //let encryptedSignature = " // 암호화된 서명
                    //print(decrypted.toString())
                    let result = decrypted.call(withArguments: ["YWt1qdbe8SAfkoPHW5d"])
                    //result?.context.
                    //print(decrypted)
                    print("Decrypted nfunc: \(result?.toString() ?? "Error")")
                    //print(signature)
                    return result?.toString() ?? "error failed to decrypt"
                    //print(decrypted)
                }
//                let functionNameRegex = try NSRegularExpression(pattern: #"(\w\w)\..."#)
//                guard let functionNameMatchRange = functionNameRegex.firstMatch(in: String(nfunc), options: [], range: NSRange(location: 0, length: nfunc.count))?.range(at: 1) else { return "" }
//                guard let functionNameRange = Range(functionNameMatchRange, in: nfunc) else { return "" }
//                let functionName = String(nfunc[functionNameRange])
//                let varRegexPattern = #"var \#(functionName)=\{.+?\};"# //(.|\n)*?\};
//                //print(varRegexPattern)
//                let varRegex = try NSRegularExpression(pattern: varRegexPattern, options: [.dotMatchesLineSeparators])
//                let ranges = NSRange(location: 0, length: jsFile.count)
//                let varMatch = varRegex.matches(in: jsFile, options: [], range: ranges)
//                let results = varMatch.compactMap { match in
//                    Range(match.range, in: jsFile).map { String(jsFile[$0]) }
//                }
            }
            
        }
        catch {
            print(#function, error)
        }
        return ""
    }
    func extractSignatureFunctionName(from jsCode: String) -> String? {
        let patterns = [
            #"(?<var>[a-zA-Z0-9_$]+)&&\(\k<var>=(?<sig>[a-zA-Z0-9_$]{2,})\(decodeURIComponent\(\k<var>\)\)"#,
                #"(?<sig>[a-zA-Z0-9_$]+)\s*=\s*function\(\s*(?<arg>[a-zA-Z0-9_$]+)\s*\)\s*\{\s*\k<arg>\s*=\s*\k<arg>\.split\(\s*""\s*\)\s*;\s*[^}]+;\s*return\s+\k<arg>\.join\(\s*""\s*\)"#,
//                # 이 패턴은 백레퍼런스 없음
//                # 가능한 패턴만 유효한 Swift 정규식으로 유지
//                # 3
//                # No capture group reference
//                # Swift에서는 괄호 매칭을 위해 너무 복잡하지 않게 써야 함
//                # (\b|[^a-zA-Z0-9_$])는 Swift에서도 사용 가능
                #"(?:(?:\b)|[^a-zA-Z0-9_$])(?<sig>[a-zA-Z0-9_$]{2,})\s*=\s*function\(\s*a\s*\)\s*\{\s*a\s*=\s*a\.split\(\s*""\s*\)(?:;[a-zA-Z0-9_$]{2}\.[a-zA-Z0-9_$]{2}\(a,\d+\))?"#,
//
//                # Old patterns (no group reference needed)
//                # 4
//                # 패턴 4~11은 모두 이름만 바꾸면 됨
//                # 즉, (?P<sig>...) → (?<sig>...)
//                # 그룹 참조는 없음
//                # 4
//                # \b[cs]... 부분은 모두 유효
//                # Python 전용 기능 없음
//                # 그대로 변환
//                # 4
//                # use `(?<sig>...)` only
//                # 4
//                # remaining patterns just rename groups
                #"\\b[cs]\\s*&&\\s*[adf]\\.set\\([^,]+\\s*,\\s*encodeURIComponent\\s*\\(\\s*(?<sig>[a-zA-Z0-9$]+)\\("#,
                #"\\b[a-zA-Z0-9]+\\s*&&\\s*[a-zA-Z0-9]+\\.set\\([^,]+\\s*,\\s*encodeURIComponent\\s*\\(\\s*(?<sig>[a-zA-Z0-9$]+)\\("#,
                #"\\bm=(?<sig>[a-zA-Z0-9$]{2,})\\(decodeURIComponent\\(h\\.s\\)\\)"#,
                #"(['\"])signature\\1\\s*,\\s*(?<sig>[a-zA-Z0-9$]+)\\("#,
                #"\\.sig\\|\\|(?<sig>[a-zA-Z0-9$]+)\\("#,
                #"yt\\.akamaized\\.net/\\)\\s*\\|\\|\\s*.*?\\s*[cs]\\s*&&\\s*[adf]\\.set\\([^,]+\\s*,\\s*(?:encodeURIComponent\\s*\\()?\\s*(?<sig>[a-zA-Z0-9$]+)\\("#,
                #"\\b[cs]\\s*&&\\s*[adf]\\.set\\([^,]+\\s*,\\s*(?<sig>[a-zA-Z0-9$]+)\\("#,
                #"\\bc\\s*&&\\s*[a-zA-Z0-9]+\\.set\\([^,]+\\s*,\\s*\\([^)]*\\)\\s*\\(\\s*(?<sig>[a-zA-Z0-9$]+)\\("#
            //"\\b([a-zA-Z0-9_$]+)&&\\(\\1=([a-zA-Z0-9_$]{2,})\\(decodeURIComponent\\(\\1\\)\\)",
//            #"\b(?<var>[a-zA-Z0-9_$]+)&&\(\1=(?<sig>[a-zA-Z0-9_$]{2,})\(decodeURIComponent\(\1\)\)"#,
//            #"**(?<sig>[a-zA-Z0-9_$]+)**\s*=\s*function\(\s* **(?<arg>[a-zA-Z0-9_$]+)** \s*\)\s*\{\s*\2\s*=\s*\2\.split\(\s*""\s*\)\s*;\s*[^}]+;\s*return\s+\2\.join\(\s*""\s*\)"#,
//            #"^(?:\b|[^a-zA-Z0-9_$])(?<sig>[a-zA-Z0-9_$]{2,})\s*=\s*function\(\s*a\s*\)\s*{\s*a\s*=\s*a\.split\(\s*""\s*\)(?:;[a-zA-Z0-9_$]{2}\.[a-zA-Z0-9_$]{2}\(a,\d+\))?"#,
//            //Old Pattern
//            
//            
//            //#"\b(?<var>[a-zA-Z0-9_$]+)&&\((?P=var)=(?<sig>[a-zA-Z0-9_$]{2,})\(decodeURIComponent\((?P=var)\)\)"#,
//            //#"(?:^|[^a-zA-Z0-9_$])(?<sig>[a-zA-Z0-9_$]{2,})\s*=\s*function\(\s*a\s*\)\s*{\s*a\s*=\s*a\.split\(\s*""\s*\)"#,
//            //#"\bm=(?<sig>[a-zA-Z0-9$]{2,})\(decodeURIComponent\(h\.s\)\)"#,
//            #"(?:"|')signature\1\s*,\s*(?<sig>[a-zA-Z0-9$]+)\("#,
//            #"\.sig\|\|(?<sig>[a-zA-Z0-9$]+)\("#
            // 필요한 다른 패턴도 추가 가능
        ]
        
        for pattern in patterns {
            if let regex = try? NSRegularExpression(pattern: pattern, options: []) {
                let range = NSRange(jsCode.startIndex..<jsCode.endIndex, in: jsCode)
                if let match = regex.firstMatch(in: jsCode, options: [], range: range),
                   let sigRange = Range(match.range, in: jsCode),
                   let Pvar = Range(match.range(withName: "var"), in: jsCode),
                   let Psig = Range(match.range(withName: "sig"), in: jsCode)
                {
                    
                    print("P<var> : ",jsCode[Pvar], "P<sig> : ",jsCode[Psig])
                    
                    
                    
                    return String(jsCode[Psig])
                }
            }
        }
        return "sig func not found"
    }
    
    func extract_nFunction(from jsCode: String, value: String, name: String)->[String]? {
        
        var nFuncArray: [String] = []
        
        let value = value.replacingOccurrences(of: "\'\"/[;{\'", with: "\"\"")
        print(value)
        if let data = value.data(using: .utf8) {
            let decoder = JSONDecoder()
            do {
                // Data를 [String] 타입으로 디코딩 시도
//                        let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String]
//                        print("⚙️⚙️", json)
                let stringArray = try decoder.decode([String].self, from: data)
                let nFuncReturn = stringArray.filter{$0.contains("-_w8_")}.first
                print(nFuncReturn ?? "")
                let nFuncGlobalVarIndex = stringArray.firstIndex(of: nFuncReturn ?? "")
                print(nFuncGlobalVarIndex)
                
            
        
        let patternN = #"(?x)\{\s*return\s+\#(NSRegularExpression.escapedPattern(for: name))\[\#(nFuncGlobalVarIndex ?? 39)\]\s*\+\s*(?<argname>[a-zA-Z0-9_$]+)\s*\}"#
        if let regexN = try? NSRegularExpression(pattern: patternN, options: []) {
            let rangeN = NSRange(jsCode.startIndex..<jsCode.endIndex, in: jsCode)
            if let matchN = regexN.firstMatch(in: jsCode, options: [], range: rangeN){
                let argname = String(jsCode[Range(matchN.range(withName: "argname"), in: jsCode)!]).reversed()
                let matchIndex = matchN.range(at: 0).location
                let index = jsCode.index(jsCode.startIndex, offsetBy: matchIndex)
                let jsCode_reversed = String(jsCode[..<index].reversed())
                let patternN2 = #"""
\{\s*\)\#(NSRegularExpression.escapedPattern(for: String(argname)))\(\s*
(?:
(?<funcnameA>[a-zA-Z0-9_$]+)\s*noitcnuf\s*
|
noitcnuf\s*=\s*(?<funcnameB>[a-zA-Z0-9_$]+)(?:\s+rav)?
)
[;\n]
"""#
                //let testRegex = try NSRegularExpression(pattern: patternN2, options: [.allowCommentsAndWhitespace])
                
                
                if let regexN2 = try? NSRegularExpression(pattern: patternN2, options: [.allowCommentsAndWhitespace]) {
                    let rangeN2 = NSRange(jsCode_reversed.startIndex..<jsCode_reversed.endIndex, in: jsCode_reversed)
                    if let matchN2 = regexN2.firstMatch(in: jsCode_reversed, options: [], range: rangeN2){
                        let nMatchRange = Range(matchN2.range(at: 0), in: jsCode_reversed)!
                        var NfuncName = ""
                        if let funcname_a = Range(matchN2.range(withName: "funcnameA"), in: jsCode_reversed) {
                            NfuncName = String(jsCode_reversed[funcname_a].reversed())
                        } else if let funcname_b = Range(matchN2.range(withName: "funcnameB"), in: jsCode_reversed) {
                            NfuncName = String(jsCode_reversed[funcname_b].reversed())
                        }
//                                        let funcname_a = String(jsCode_reversed[Range(matchN2.range(withName: "funcnameA"), in: jsCode_reversed)!])
//                                        let funcname_b = String(jsCode_reversed[Range(matchN2.range(withName: "funcnameB"), in: jsCode_reversed)!])
//                                        print("🔍", funcname_a, funcname_b)
                        print("🔍", NfuncName)
                        nFuncArray.append(NfuncName)
                        let nFuncCode = extract_function_code_for_n(from: jsCode, functionName: NfuncName, variableName: nil)
                        nFuncArray.append(nFuncCode ?? "")
                        
                        
                        
                        return nFuncArray
                    }
                } else{
                    print("아마 정규식 에러")
                }
                
                
            }
        }
            } catch {
                print("JSON 디코딩 오류: \(error)")
            }
        }
        return ["nFunction Not Found."]
    }
    
    
    
    
    
    func signatureFunctionVaricode(from jsCode: String)->[String]? {
        let pattern = #"['"]use\s+strict['"];\s*(?<code>var\s+(?<name>[A-Za-z0-9_$]+)\s*=\s*(?<value>(["'])(?:(?!\4).|\\.)+\4\.split\((["'])(?:(?!\5).)+\5\)|\[\s*(?:(["'])(?:(?!\6).|\\.)*\6\s*,?\s*)+\]))[;,]"#
        
        if let regex = try? NSRegularExpression(pattern: pattern, options: []) {
            let range = NSRange(jsCode.startIndex..<jsCode.endIndex, in: jsCode)
            if let match = regex.firstMatch(in: jsCode, options: [], range: range),
               let codeRaange = Range(match.range(withName: "code"), in: jsCode),
               let nameRange = Range(match.range(withName: "name"), in: jsCode),
               let valueRange = Range(match.range(withName: "value"), in: jsCode)
            {
                
                
                
                //print("funVarName : ",jsCode[nameRange], "funcVarValue : ",jsCode[valueRange])
                return [ String(jsCode[nameRange]), String(jsCode[codeRaange]), String(jsCode[valueRange])]
            }
        }
        return ["sig var not found"]
    }
    
    func extract_function_code(from jsCode: String, functionName: String, variableName: String?)->[String]? {
        let escapedName = functionName.escapedForRegex
        let pattern = #"(?x)(?s)(?:function\s+\#(escapedName)|[\{;,]\s*\#(escapedName)\s*=\s*function|(?:var|const|let)\s+\#(escapedName)\s*=\s*function)\s*\((?<args>[^)]*)\)\s*(?<code>\{.+?\})"#
        print(pattern)
        
        if let regex = try? NSRegularExpression(pattern: pattern, options: [.allowCommentsAndWhitespace, .dotMatchesLineSeparators]) {
            let range = NSRange(jsCode.startIndex..<jsCode.endIndex, in: jsCode)
            if let match = regex.firstMatch(in: jsCode, range: range) {
                let args = String(jsCode[Range(match.range(withName: "args"), in: jsCode)!])
                let code = String(jsCode[Range(match.range(withName: "code"), in: jsCode)!])
                let allCdoe = String(jsCode[Range(match.range, in: jsCode)!])
                print("✅ 인자: \(args)")
                print("✅ 코드: \(code)")
                
                if variableName != nil {
                    let helpers = extract_helper(from: code, args: args, variableName: variableName)
                    let helperFunc = extract_helper_code(from: jsCode, helpers: helpers)
                    var helps = [String(allCdoe)]
                    helps.append(contentsOf: helperFunc ?? [])
                    
                    return helps
                }
                return [String(allCdoe)]
            }
        } else {
            print("❌ 정규식 생성 오류")
        }
        
        return ["decrypt function code not found"]
    }
    
    func extract_function_code_for_n(from jsCode: String, functionName: String, variableName: String?)->String? {
        let escapedName = functionName.escapedForRegex
        let pattern = #"(?x)(?s)(?:function\s+\#(escapedName)|[\{;,]\s*\#(escapedName)\s*=\s*function|(?:var|const|let)\s+\#(escapedName)\s*=\s*function)\s*\((?<args>[^)]*)\)\s*"#
        print(pattern)
        
        if let regex = try? NSRegularExpression(pattern: pattern, options: [.allowCommentsAndWhitespace, .dotMatchesLineSeparators]) {
            let range = NSRange(jsCode.startIndex..<jsCode.endIndex, in: jsCode)
            if let match = regex.firstMatch(in: jsCode, range: range) {
                let args = String(jsCode[Range(match.range(withName: "args"), in: jsCode)!])
                
                guard let match_index = Range(NSRange(location: match.range.location, length: 0), in: jsCode)?.lowerBound else {return nil}
                //print(String(jsCode[match_index...]))
                guard let code = multiBrace(from: String(jsCode[match_index...])) else {return nil}
                print("✅ 인자: \(args)")
                print("✅ 코드: \(code)")
                
                return String(code)
            }
        } else {
            print("❌ 정규식 생성 오류")
        }
        
        return "decrypt N function code not found"
    }
    
    func multiBrace(from jsCode: String) -> String? {
        guard let braceStartIndex = jsCode.firstIndex(of: "{") else {
                return nil
            }

            var braceCount = 0
            var currentIndex = braceStartIndex

            while currentIndex < jsCode.endIndex {
                if jsCode[currentIndex] == "{" {
                    braceCount += 1
                } else if jsCode[currentIndex] == "}" {
                    braceCount -= 1
                    if braceCount == 0 {
                        // 중괄호 블록 끝 찾음
                        return String(jsCode[...jsCode.index(after: currentIndex)])
                    }
                }
                currentIndex = jsCode.index(after: currentIndex)
            }

            return nil
    }
    
    func extract_helper(from jsFunctionCode: String, args: String, variableName: String?)->[String]{
        let pattern = #"([$\w]+)\s*\["#
            
            do {
                let regex = try NSRegularExpression(pattern: pattern)
                let range = NSRange(jsFunctionCode.startIndex..<jsFunctionCode.endIndex, in: jsFunctionCode)
                
                var results = Set<String>()
                
                for match in regex.matches(in: jsFunctionCode, range: range) {
                    if let nameRange = Range(match.range(at: 1), in: jsFunctionCode) {
                        let objectName = String(jsFunctionCode[nameRange])
                        results.insert(objectName)
                        
                    }
                }
                results.remove(args)
                results.remove(variableName ?? "")
                
                
                
                return Array(results)
            } catch {
                print("❌ 정규식 오류: \(error)")
                return []
            }
    }

    func extract_helper_code(from jsCode: String, helpers: [String])->[String]?{
        
        var helperFunctions: [String] = []
        
        for helper in helpers{
            let objName = helper
            let funcNameRe = #"(?:[a-zA-Z$0-9]+|"[a-zA-Z$0-9]+"|'[a-zA-Z$0-9]+')"#

            let pattern = #"""
            (?x)
            (?<![a-zA-Z$0-9.])\#(NSRegularExpression.escapedPattern(for: objName))\s*=\s*\{\s*
            (?<fields>(
                (\#(funcNameRe)\s*:\s*function\s*\(.*?\)\s*\{.*?\}(?:,\s*)?)*
            ))
            \}\s*;
            """#

            let options: NSRegularExpression.Options = [.allowCommentsAndWhitespace, .dotMatchesLineSeparators]

            guard let regex = try? NSRegularExpression(pattern: pattern, options: options) else {
                print("❌ 정규식 생성 실패")
                return []
            }

            if let match = regex.firstMatch(in: jsCode, options: [], range: NSRange(jsCode.startIndex..., in: jsCode)) {
                if let fieldsRange = Range(match.range, in: jsCode) {
                    let fields = String(jsCode[fieldsRange])
                    helperFunctions.append(fields)
                    print("🎯 추출된 필드 영역:\n\(fields)")
                    
                }
            } else {
                print("❌ 대상 object '\(objName)'를 찾을 수 없습니다.")
            }
            
        }
        
        return helperFunctions
    }

}




extension String {
    var escapedForRegex: String {
        return NSRegularExpression.escapedPattern(for: self)
    }
}

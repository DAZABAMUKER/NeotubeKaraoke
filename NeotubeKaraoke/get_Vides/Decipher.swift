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

    private func separateAtParen(from code: String) -> (body: String, remaining: String)? {
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
            guard let match = regex.firstMatch(in: jsFile, options: [], range: range) else { return "" }
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
                let context = JSContext()
                //print(jsFile)
                print(mainFunctionName)
                context?.evaluateScript(String(algoJS))
                print(context?.globalObject.isUndefined)
                if let decrypted = context?.objectForKeyedSubscript(String(mainFunctionName)) {
                    //let encryptedSignature = " // 암호화된 서명
                    print(signature)
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
}

//
//  Decipher.swift
//  NeotubeKaraoke
//
//  Created by 안병욱 on 11/30/24.
//

import Foundation

class Decipher {
    func getMainFunction(jsFile: String) {
        let pattern = #"[\{\d\w\(\)\\.="]*?;(..\...\(.\,..?\);){3,}.*?\}"#
        do {
            let regex = try NSRegularExpression(pattern: pattern)
            let range = NSRange(location: 0, length: jsFile.count)
            guard let match = regex.firstMatch(in: jsFile, options: [], range: range) else { return }
            let matchRange = match.range(at: 0)
            guard let stringRange = Range(matchRange, in: jsFile) else { return }
            let mainFunction = jsFile[stringRange]
            print(mainFunction)
            
        }
        catch {
            print(#function, error)
        }
    }
}

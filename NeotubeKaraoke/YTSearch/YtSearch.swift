//
//  YtSearch.swift
//  NeotubeKaraoke
//
//  Created by 안병욱 on 2023/04/01.
//

import Foundation
import PythonKit
import PythonSupport

open class YtSearch: NSObject {
    public enum Error: Swift.Error {
        case noPythonModule
    }
    
    //internal let pythonObject: PythonObject
    
    public init(yt: String = "") throws {
        guard FileManager.default.fileExists(atPath: Bundle.main.url(forResource: "ytSR", withExtension: "py")!.deletingLastPathComponent().path) else {
            throw Error.noPythonModule
        }
        let sys = try Python.attemptImport("sys")
        if !(Array(sys.path) ?? []).contains(Bundle.main.url(forResource: "ytSR", withExtension: "py")!.path) {
            sys.path.insert(1, Bundle.main.url(forResource: "ytSR", withExtension: "py")!.deletingLastPathComponent().path)
        }
        
        runSimpleString("""
        class Pop:
            pass
        
        import subprocess
        subprocess.Popen = Pop
        """)
        
        let pythonModule = try Python.attemptImport("ytSR")
        let results = try pythonModule.YoutubeSearch.throwing.dynamicallyCall(withKeywordArguments: ["search_terms" : "", "max_results" : 1])
        print(results)
    }
    
}

//
//  VideoPlay.swift
//  NeotubeKaraoke
//
//  Created by 안병욱 on 2023/01/14.
//

import SwiftUI
import AVKit
import YoutubeDL
import PythonKit

struct VideoPlay: View {
    
    
    @State var player = AVPlayer()
    @State var indeterminateProgressKey: String?
    @State var progress: Progress?
    @State var youtubeDL: YoutubeDL?
    @State var info: Info?
    @State var format: [Format]?
    @State var url: URL? {
        didSet {
            guard let url = url else {
                return
            }
            
            extractInfo(url: url)
        }
    }
    @State var error: Error?
    @State var formatsSheet: ActionSheet?
        
    @State var isTranscodingEnabled = true
        
    @State var isRemuxingEnabled = true
        
    @State var showingFormats = false
    
    
    var videoId: String = ""
    
    init(videoId: String = "fSlqTX39CMM") {
        self.videoId = videoId
    }
    
    let ydl = try? YoutubeDL()
    func open(url: URL) {
            UIApplication.shared.open(url, options: [:]) {
                if !$0 {
                    //alert(message: "Failed to open \(url)")
                }
            }
        }
        
        func extractInfo(url: URL) {
            guard let youtubeDL = youtubeDL else {
                loadPythonModule()
                return
            }
            
            indeterminateProgressKey = "Extracting info..."
            DispatchQueue.global(qos: .userInitiated).async {
                do {
                    let (mp4, info) = try youtubeDL.extractInfo(url: url)
                    DispatchQueue.main.async {
                        indeterminateProgressKey = nil
                        self.info = info
                        self.format?.append(contentsOf: mp4)
                        let reqquest = mp4.last?.urlRequest
                    }
                }
                catch {
                    indeterminateProgressKey = nil
                    guard let pyError = error as? PythonError, case let .exception(exception, traceback: _) = pyError else {
                        self.error = error
                        return
                    }
                    if (String(exception.args[0]) ?? "").contains("Unsupported URL: ") {
                    }
                }
            }
        }
        
        func loadPythonModule() {
            guard FileManager.default.fileExists(atPath: YoutubeDL.pythonModuleURL.path) else {
                downloadPythonModule()
                return
            }
            indeterminateProgressKey = "Loading Python module..."
            DispatchQueue.global(qos: .userInitiated).async {
                do {
                    youtubeDL = try YoutubeDL()
                    DispatchQueue.main.async {
                        indeterminateProgressKey = nil
                        
                        url.map { extractInfo(url: $0) }
                    }
                }
                catch {
                    print(#function, error)
                    DispatchQueue.main.async {
                    }
                }
            }
        }
        
        func downloadPythonModule() {
            indeterminateProgressKey = "Downloading Python module..."
            YoutubeDL.downloadPythonModule { error in
                DispatchQueue.main.async {
                    indeterminateProgressKey = nil
                    guard error == nil else {
                        return
                    }

                    loadPythonModule()
                }
            }
        }
        
    
    var body: some View {
        //Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
        if info != nil {
            Text(info?.title ?? "nil")
            //Text(info?.formats.description ?? "nil")
        }
        VideoPlayer(player: player)
            .frame(width: 400, height: 300, alignment: .center)
            .onAppear() {
                url = URL(string: "https://www.youtube.com/watch?v=\(videoId)")
                //player = AVPlayer(url:URL(string: info.)
                //print(url)
            }
        
    }
}

struct Previews_VideoPlay_Previews: PreviewProvider {
    static var previews: some View {
        Text("HELLO")
    }
}

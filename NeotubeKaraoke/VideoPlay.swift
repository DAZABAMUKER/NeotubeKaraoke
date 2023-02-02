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
    @State var isiPad = false
    @State var que = false
    @State var player = AVPlayer()
    
    @State var indeterminateProgressKey: String?
    @State var youtubeDL: YoutubeDL?
    @State var info: Info?
    @State var url: URL? {
        didSet {
            guard let url = url else {
                return
            }
            
            extractInfo(url: url)
        }
    }
    @State var Urls = URL(string: "https://dazabamuker.tistory.com")!
    @Binding var TBisOn: Bool
    
    var videoId: String = ""
    
    init(videoId: String = "", TBisOn: Binding<Bool> = .constant(false)) {
        self.videoId = videoId
        _TBisOn = TBisOn
    }
    
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
                let (_, info) = try youtubeDL.extractInfo(url: url)
                DispatchQueue.main.async {
                    indeterminateProgressKey = nil
                    self.info = info
                    guard let formats = info?.formats else {
                        return
                    }
                    let best = formats.filter { !$0.isRemuxingNeeded && !$0.isTranscodingNeeded }.last
                    let reqquestUrl = best?.urlRequest?.url
                    guard let Url = reqquestUrl else {
                        return
                    }
                    self.Urls = Url
                    //print(self.Urls)
                    self.que = true
                }
            }
            catch {
                indeterminateProgressKey = nil
                guard let pyError = error as? PythonError, case let .exception(exception, traceback: _) = pyError else {
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
        GeometryReader { geometry in
            VStack{
                if self.que == true {
                    VideoPlayer(player: player)
                        .frame(width: geometry.size.width, height: UIDevice.current.orientation == .portrait ? geometry.size.width/(192/108) : isiPad ?  geometry.size.height - 50 : geometry.size.height+geometry.safeAreaInsets.bottom, alignment: .center)
                        .onAppear() {
                            player = AVPlayer(url: Urls)
                            player.play()
                        }
                        
                }
            }
            .onAppear() {
                url = URL(string: "https://www.youtube.com/watch?v=\(videoId)")
                if UIDevice.current.model == "iPad" {
                    self.isiPad = true
                }
                if TBisOn && !isiPad {
                   TBisOn = false
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                if info != nil {
                    ToolbarItem(placement: .principal){
                        LinearGradient(colors: [
                            Color(red: 1, green: 112 / 255.0, blue: 0),
                            Color(red: 226 / 255.0, green: 247 / 255.0, blue: 5 / 255.0)
                        ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                    )
                        .mask(alignment: .center) {
                            Text(info?.title ?? "노래방")
                                .bold()
                        }
                    }
                }
            }
        }
    }
}

struct Previews_VideoPlay_Previews: PreviewProvider {
    static var previews: some View {
        Text("HELLO")
    }
}
let av1CodecPrefix = "av01."
extension Format {
    var isRemuxingNeeded: Bool { isVideoOnly || isAudioOnly }
    
    var isTranscodingNeeded: Bool {
        self.ext == "mp4"
            ? (self.vcodec ?? "").hasPrefix(av1CodecPrefix)
            : self.ext != "m4a"
    }
}


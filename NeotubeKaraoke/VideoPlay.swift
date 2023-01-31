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
    
    @State var que = false
    
    @State var player = AVPlayer()
    @State var indeterminateProgressKey: String?
    @State var progress: Progress?
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
    @State var Urls = URL(string: "http://www.naver.com")!
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
                    let (format, info) = try youtubeDL.extractInfo(url: url)
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
                        print(self.Urls)
                        self.que = true
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
            if info != nil {
                Text(info?.title ?? "nil")
                //Text(info?.formats.description ?? "nil")
            }
            if self.que == true {
                VideoPlayer(player: player)
                    .frame(width: 400, height: 300, alignment: .center)
                    .onAppear() {
                        player = AVPlayer(url: Urls)
                        /*player = AVPlayer(url: URL(string: "https://rr8---sn-3u-20ne.googlevideo.com/videoplayback?expire=1675146677&ei=VWHYY-pOi6CAB_XKpZAI&ip=37.120.218.86&id=o-AIYqTqD87OWnlvkXmPkWsQ06JoK6T1WBZbB0H9UgV_s7&itag=18&source=youtube&requiressl=yes&spc=H3gIhjHC4ZVlZV27MzPcWtNrzIebqaQ&vprv=1&mime=video%2Fmp4&ns=xsdUzXu1idDvO0h1_JcVHHUL&cnr=14&ratebypass=yes&dur=231.781&lmt=1673297589342717&fexp=24007246&c=WEB&txp=5530434&n=pVnELDCy8K1zww&sparams=expire%2Cei%2Cip%2Cid%2Citag%2Csource%2Crequiressl%2Cspc%2Cvprv%2Cmime%2Cns%2Ccnr%2Cratebypass%2Cdur%2Clmt&sig=AOq0QJ8wRQIgD8xZVpXymvjd_w8E1M6KGZb1lOJbhxrjR6yPWCuXS3MCIQDYVTcCsYMyksuB5de7fQ64vxwHDWRX96DllS3R7EKiWw%3D%3D&redirect_counter=1&rm=sn-5hnelr7e&req_id=155fd8792a4ea3ee&cms_redirect=yes&cmsv=e&ipbypass=yes&mh=Av&mip=59.22.159.5&mm=31&mn=sn-3u-20ne&ms=au&mt=1675127370&mv=m&mvi=8&pcm2cms=yes&pl=16&lsparams=ipbypass,mh,mip,mm,mn,ms,mv,mvi,pcm2cms,pl&lsig=AG3C_xAwRgIhAIlyFZZkEwP0zcdnB3FSMJLhwqZAe7o6An0eDFu0q79sAiEA9EGQTWeb5eFxuHkSVPI-cOoUl7OCvP0E4lbywWZgcJs%3D")!)*/
                        //print(url)
                    }
            }
        }
        .onAppear() {
            url = URL(string: "https://www.youtube.com/watch?v=\(videoId)")
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


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
    @State var isAppear = false
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
    
    @StateObject var audioManager = AudioManager()
    @State var tone: Float = 0.0
    @State var itemUrl: URL!
    
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
                    //print(formats)
                    let best = formats.filter {!$0.isTranscodingNeeded && !$0.isTranscodingNeeded}.last
                    let bestAudio = formats.filter { $0.isAudioOnly && $0.ext == "m4a" }.last
                    print(bestAudio)
                    let reqquestUrl = bestAudio?.urlRequest?.url
                    guard let Url = reqquestUrl else {
                        return
                    }
                    self.Urls = Url
                    //print(self.Urls)
                    self.que = true
                    loadAVAssets(url: Urls)
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
    
    func loadAVAssets(url: URL) {
        /*DispatchQueue.global(qos: .background).async {
            Task{
                do {
                    
                    let assets = AVURLAsset(url: url)
                    let mAssets = AVAsset(url: Bundle.main.url(forResource: "sample", withExtension: "mp3")!)
                    await print(try mAssets.loadMetadata(for: .isoUserData))
                    let outputURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
                    //try! FileManager.default.createDirectory(at: outputURL, withIntermediateDirectories: true, attributes: nil)
                    
                    let fileURL = outputURL.appendingPathComponent("videoplayback.m4a")
                    // These settings will encode using H.264.
                    let preset = AVAssetExportPresetAppleM4A
                    let outFileType = AVFileType.m4a
                    AVAssetExportSession.determineCompatibility(ofExportPreset: preset, with: assets, outputFileType: outFileType) { isCompatible in
                        guard isCompatible else { return }
                        // Compatibility check succeeded, continue with export.
                        print("success")
                    }
                    guard let exportSession = AVAssetExportSession(asset: mAssets, presetName: preset) else { return }
                    exportSession.outputFileType = outFileType
                    exportSession.outputURL = outputURL
                    exportSession.exportAsynchronously(completionHandler: {
                        switch exportSession.status {
                        case AVAssetExportSession.Status.completed:
                                        print("export complete")
                        case  AVAssetExportSession.Status.failed:
                                        print("export failed \(exportSession.error)")
                        case AVAssetExportSession.Status.cancelled:
                                        print("export cancelled \(exportSession.error)")
                                    default:
                                        print("export complete")
                                    }
                    })
                    //urlData?.write(toFile: filePath, atomically: true)
                    
                    self.que = true
                    
                    //let audio_track = try await assets.loadTracks(withMediaType: .audio)
                    //let things = audio_track.first?.description
                    //print(things ?? "nil")
                } catch {
                }
            }
        }*/
        let task = URLSession.shared.downloadTask(with: url) { tempUrl, urlResponse, error in
            do {
                let doc = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
                let fileUrl = doc.appendingPathComponent("audio.m4a")
                if FileManager.default.fileExists(atPath: fileUrl.path()) {
                                try FileManager.default.removeItem(at: fileUrl)
                            }
                try FileManager.default.copyItem(at: tempUrl!, to: fileUrl)
                audioManager.setEngine(file: fileUrl, frequency: [32, 63, 125, 250, 500, 1000, 2000, 4000, 8000, 16000], tone: 0.0)
            }
            catch {
                
            }
        }.resume()
        
    }
    
    var body: some View {
        GeometryReader { geometry in
            ZStack{
                
                if self.que == true {
                    HStack{
                        Button("-pitch") {
                            self.tone += 1
                            audioManager.pitchChange(tone: self.tone)
                        }
                        Button("PLAY"){
                            audioManager.play()
                        }
                        Button("-pitch") {
                            self.tone -= 1
                            audioManager.pitchChange(tone: self.tone)
                        }
                    }
                 /*
                    VideoPlayer(player: player)
                        .frame(width: geometry.size.width, height: UIDevice.current.orientation == .portrait ? geometry.size.width/(192/108) : isiPad ?  geometry.size.width/(192/108): geometry.size.height+geometry.safeAreaInsets.bottom, alignment: .center)
                        .padding(.top, -15)
                        .onAppear() {
                            if !isAppear {
                                player = AVPlayer(url: Urls)
                                player.play()
                                self.isAppear = true
                            }
                        }*/
                    
                    VStack{}.onAppear(){
                        //audioManager.setEngine(file: Urls, frequency: [32, 63, 125, 250, 500, 1000, 2000, 4000, 8000, 16000], tone: 0.0)
                        self.isAppear = true
                        
                    }
                }
                
                if !isAppear{
                    ProgressView()
                        .scaleEffect(1.5)
                        .progressViewStyle(CircularProgressViewStyle(tint: .blue))
                        .frame(width: geometry.size.width, height: geometry.size.height)
                }
                 
            }
            .onAppear() {
                if !isAppear {
                    url = URL(string: "https://www.youtube.com/watch?v=\(videoId)")
                    if UIDevice.current.model == "iPad" {
                        self.isiPad = true
                    }
                    if TBisOn && !isiPad {
                        TBisOn = false
                    }
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



//
//  VideoPlay.swift
//  NeotubeKaraoke
//
//  Created by 안병욱 on 2023/01/14.
//

import SwiftUI
import AVKit
import PythonKit
import UIKit

struct VideoPlay: View {
    //@Environment(\.scenePhase) var scenePhase
    @Environment(\.dismiss) private var dismiss
    @AppStorage("micPermission") var micPermission: Bool = UserDefaults.standard.bool(forKey: "micPermission")
    @AppStorage("moveFrameTime") var goBackTime: Double = UserDefaults.standard.double(forKey: "moveFrameTime")
    @EnvironmentObject var envPlayer: EnvPlayer
    
    @State var isiPad = false
    @State var que = false
    @ObservedObject var player = VideoPlayers()
    //@State var indeterminateProgressKey: String?
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
    //@State var audioUrl = URL(string: "https://dazabamuker.tistory.com")!
    //@State var videoUrl = URL(string: "https://dazabamuker.tistory.com")!
    @ObservedObject var audioManager = AudioManager()
    @StateObject var downloadManager = MultiPartsDownloadTask()
    @State var tone: Float = 0.0 {
        didSet {
            if tone > 24.0 {
                tone = oldValue
            } else if tone < -24.0 {
                tone = oldValue
            }
        }
    }
    @State var tempo: Float = 1.0 {
        didSet {
            if tempo > 24.0 {
                tone = oldValue
            } else if tempo < -24.0 {
                tempo = oldValue
            }
        }
    }
    //@State var itemUrl: URL!
    var videoId: String = ""
    @State var tap = false
    //@State var isPlaying = false
    @State private var isLoading = false
    @State var closes = false
    @Binding var vidFull: Bool
    @Binding var vidEnd: Bool
    @State var isAppear: Bool = false
    @Binding var isReady: Bool
    @State var isBle: Bool = false
    @Binding var resolution: Resolution
    @Binding var isLandscape: Bool
    
    @State var session: AVAudioSession!
    @State var recorder: AVAudioRecorder!
    @State var record: Bool = false
    @State var sample = [Float]()
    @State var isMicOn = false
    @State var vidSync = 0.0
    @Binding var score: Int
    
    private let tempoString: LocalizedStringKey = "Tempo"
    
    func rotateLandscape() {
        if !isLandscape {
            if #available(iOS 16.0, *) {
                let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene
                windowScene?.requestGeometryUpdate(.iOS(interfaceOrientations: .landscapeRight))
                self.isLandscape = true
            } else {
                let value = UIInterfaceOrientation.landscapeLeft.rawValue
                UIDevice.current.setValue(value, forKey: "orientation")
                self.isLandscape = true
            }
        } else {
            if #available(iOS 16.0, *) {
                let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene
                windowScene?.requestGeometryUpdate(.iOS(interfaceOrientations: .portrait))
                self.isLandscape = false
            } else {
                let value = UIInterfaceOrientation.portrait.rawValue
                UIDevice.current.setValue(value, forKey: "orientation")
                self.isLandscape = false
            }
        }
    }
    
    func close() {
        player.close()
        audioManager.close()
    }
    
    func extractInfo(url: URL) {
        guard let youtubeDL = youtubeDL else {
            loadPythonModule()
            return
        }
        DispatchQueue.global(qos: .userInitiated).async {
            do {
                let info = try youtubeDL.extractInfo(url: url)
                DispatchQueue.main.async {
                    self.info = info
                    self.isAppear = false
                    //self.isReady = false
                    //print(isReady)
                    guard let formats = info?.formats else {
                        return
                    }
                    var bestVideo: Format?
                    var isOk = false
                    //print(info?.format?.url)
                    if resolution == .ultra {
                        isOk = true
                        let vids = formats.filter { $0.isVideoOnly && !$0.isTranscodingNeeded}
                        if !vids.isEmpty {
                            bestVideo = formats.filter { $0.isVideoOnly && !$0.isTranscodingNeeded}.last
                            isOk = true
                        } else {
                            bestVideo = formats.filter {!$0.isRemuxingNeeded && !$0.isTranscodingNeeded}.last
                        }
                    } else if resolution == .high {
                        let vids = formats.filter { $0.isVideoOnly && !$0.isTranscodingNeeded}
                        if !vids.isEmpty && (vids.last?.height)! >= 1080 {
                            bestVideo = formats.filter { $0.isVideoOnly && !$0.isTranscodingNeeded && $0.height == 1080}.last
                            isOk = true
                        } else {
                            bestVideo = formats.filter {!$0.isRemuxingNeeded && !$0.isTranscodingNeeded}.last
                        }
                    } else if resolution == .low {
                        bestVideo = formats.filter{!$0.isRemuxingNeeded && !$0.isTranscodingNeeded}.first
                    } else {
                        bestVideo = formats.filter {!$0.isRemuxingNeeded && !$0.isTranscodingNeeded}.last
                    }
                    let bestAudio = formats.filter {!$0.isRemuxingNeeded && !$0.isTranscodingNeeded}.first
                    //let bestVideo = formats.filter { $0.isVideoOnly && !$0.isTranscodingNeeded && $0.height == 1080}.last
                    //let bestVideo = formats.filter { $0.isVideoOnly && !$0.isTranscodingNeeded }.last
                    let onlyAudio = formats.filter { $0.isAudioOnly && $0.ext == "m4a" }.last
                    print(bestAudio!, bestVideo!)
                    //print(self.info!)
                    guard let aUrl = bestAudio?.url else { return }
                    guard let vUrl = bestVideo?.url else { return }
                    guard let onlyAudioUrl = onlyAudio?.url else { return }
                    //print(vUrl)
                    //self.audioUrl = aUrl
                    //self.videoUrl = vUrl
                    //print(self.audioUrl)
                    //let size = try? onlyAudioUrl.resourceValues(forKeys: [.totalFileSizeKey]).totalFileSize
                    //print(size)
                    //print(bestVideo?.filesize ?? 0)
                    //print(bestAudio?.filesize ?? 0)
                    player.prepareToPlay(url: vUrl, audioManager: audioManager, fileSize: bestVideo?.filesize ?? 0, isOk: isOk)
                    envPlayer.player = self.player
                    envPlayer.isOn = true
                    //loadAVAssets(url: aUrl, size: onlyAudio?.filesize ?? 0, aUrl: onlyAudioUrl)
                    self.downloadManager.createDownloadParts(url: onlyAudioUrl, size: onlyAudio?.filesize ?? 0)
                }
            }
            catch {
                guard let pyError = error as? PythonError, case let .exception(exception, traceback: _) = pyError else {
                    return
                }
                //self.vidEnd = true
                //self.vidFull = false
                if (String(exception.args[0]) ?? "").contains("Unsupported URL: ") {
                }
            }
        }
    }
    
    
    
    func loadPythonModule() {
        DispatchQueue.global(qos: .default).async {
            do {
                youtubeDL = try YoutubeDL()
                //guard youtubeDL?.version < 2023.
                DispatchQueue.main.async {
                    url.map { extractInfo(url: $0) }
                }
                //print("loads")
            }
            catch {
                print(#function, error)
                DispatchQueue.main.async {
                }
            }
        }
    }
    
    func audioEngineSet() {
        let doc = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let fileUrl = doc.appendingPathComponent("audio.m4a")
        audioManager.setEngine(file: fileUrl, frequency: [32, 63, 125, 250, 500, 1000, 2000, 4000, 8000, 16000], tone: 0.0)
        self.isAppear = true
        self.isReady = true
    }
    func loadAVAssets(url: URL, size: Int64, aUrl: URL) {
        print("sizes:",size)
        var urlToUse = url
//        if size < 6000000 {
//            urlToUse = aUrl
//        }
        var request = URLRequest(url: urlToUse)
        request.httpMethod = "GET"
        let task = URLSession(configuration: .default).dataTask(with: request) { data, urlResponse, error in
            let doc = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            let fileUrl = doc.appendingPathComponent("audio.mp4")
            do {
                if FileManager.default.fileExists(atPath: fileUrl.path()) {
                    try FileManager.default.removeItem(at: fileUrl)
                }
                //try FileManager.default.copyItem(at: tempUrl!, to: fileUrl)
                try data?.write(to: fileUrl)
                //print(fileUrl)
                extractAudio(docUrl: doc)
            }
            catch {
                print(error)
                return
            }
        }
        task.resume()
    }
    
    func extractAudio(docUrl: URL) {
        let composition = AVMutableComposition()
        let fileUrl = docUrl.appendingPathComponent("audio.mp4")
        let outputUrl = docUrl.appendingPathComponent("audio.m4a")
        if FileManager.default.fileExists(atPath: outputUrl.path) {
            try? FileManager.default.removeItem(atPath: outputUrl.path)
        }
        Task{
            do {
                let asset = AVURLAsset(url: fileUrl)
                //guard let audioAssetTrack = asset.tracks(withMediaType: AVMediaType.audio).first else { return }
                if FileManager.default.fileExists(atPath: outputUrl.path) {
                    try? FileManager.default.removeItem(atPath: outputUrl.path)
                }
                let audiotrack = try await asset.loadTracks(withMediaType: AVMediaType.audio)
                guard let audioCompositionTrack = composition.addMutableTrack(withMediaType: AVMediaType.audio, preferredTrackID: kCMPersistentTrackID_Invalid) else { return }
                try await audioCompositionTrack.insertTimeRange( audiotrack.first!.load(.timeRange), of: audiotrack.first!, at: .zero)
                await export(video: composition, withPreset: AVAssetExportPresetAppleM4A, toFileType: .m4a , atURL: outputUrl)
                let _: () = Service.shared.buffer(url: outputUrl, samplesCount: 300) { results in
                    self.sample = results
                }
                audioManager.setEngine(file: outputUrl, frequency: [32, 63, 125, 250, 500, 1000, 2000, 4000, 8000, 16000], tone: 0.0)
                
                self.isAppear = true
                self.isReady = true
            } catch {
                print(error)
            }
        }
        
    }
    
    func export(video: AVAsset,
                withPreset preset: String = AVAssetExportPresetHighestQuality,
                toFileType outputFileType: AVFileType = .mov,
                atURL outputURL: URL) async {
        
        // Check the compatibility of the preset to export the video to the output file type.
        guard await AVAssetExportSession.compatibility(ofExportPreset: preset,
                                                       with: video,
                                                       outputFileType: outputFileType) else {
            print("The preset can't export the video to the output file type.")
            return
        }
        
        // Create and configure the export session.
        guard let exportSession = AVAssetExportSession(asset: video,
                                                       presetName: preset) else {
            print("Failed to create export session.")
            return
        }
        exportSession.outputFileType = outputFileType
        exportSession.outputURL = outputURL
        
        // Convert the video to the output file type and export it to the output URL.
        await exportSession.export()
    }

    //MARK: - 뷰 바디 여기 있음
    var body: some View {
        NavigationStack{
            GeometryReader { geometry in
                ZStack{
                    if self.downloadManager.que {
                        VStack{}.onAppear(){
                            self.audioEngineSet()
                        }
                    }
                    if !self.player.isMuted {
                        VStack{}.onAppear(){
                            self.player.isMuted = true
                        }
                    }
                    if !isLandscape {
                        VStack{}.onAppear(){
                            self.tap = true
                        }
                    }
                    if closes {
                        VStack{}.onAppear(){
                            print("종료")
                            player.close()
                            audioManager.close()
                        }
                    }
                    if player.end {
                        VStack{}.onAppear(){
                            self.vidEnd = true
                            self.vidFull = false
                            if isMicOn {
                                self.recorder.stop()
                                let url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
                                let recordFile = url.appendingPathComponent("recoredForScore.m4a")
                                let _: () = Service.shared.buffer(url: recordFile, samplesCount: 300) { results in
                                    var scoreArray = [Float]()
                                    var results = results
                                    self.score = 0
                                    let sampleNonInf = self.sample.filter{ !$0.isInfinite }
                                    let sampleAve = sampleNonInf.reduce(0) { Int(Float($0) + $1) } / 300
                                    self.sample = self.sample.map{$0.isInfinite ? Float(sampleAve) : $0}
                                    let resultsNonInf = results.filter{ !$0.isInfinite }
                                    let resultsAve = resultsNonInf.reduce(0) { Int(Float($0) + $1) } / 300
                                    results = results.map{$0.isInfinite ? Float(resultsAve) : $0}
                                    //print("sample: ", sampleDiff, self.sample.max() ?? 0, self.sample.min() ?? 0)
                                    //print("results: ", resultsDiff, results.max()!, results.min()!)
                                    let result = results.map{ $0 * (sample.max() ?? 0) / (results.max() ?? 0) }
                                    
                                    for index in 0..<result.count {
                                        var diff = self.sample[index] - result[index]
                                        if diff < 0 {
                                            diff *= -1
                                        }
                                        scoreArray.append(diff)
                                    }
                                    self.score = 110 - (scoreArray.reduce(0) { Int(Float($0) + $1) } / scoreArray.count) * 100 / Int(self.sample.max()!)
                                    print("score: ",score)
                                    if score > 100 {
                                        score = 100
                                    } else if score < 50 {
                                        score = 50
                                    }
                                }
                            }
                        }
                    }
                    if isAppear {
                        VStack(spacing: 0){
                            /*
                            LinearGradient(colors: [
                                Color(red: 1, green: 112 / 255.0, blue: 0),
                                Color(red: 226 / 255.0, green: 247 / 255.0, blue: 5 / 255.0)
                            ],
                                           startPoint: .topLeading,
                                           endPoint: .bottomTrailing
                            )
                            .frame(width: geometry.size.width, height: 45)
                            .mask(alignment: .center) {
                                Text(info?.title ?? "노래방")
                                    .bold()
                            }
                             */
                            Text(info?.title ?? "노래방")
                                .frame(width: geometry.size.width, height: 45)
                                .bold()
                                .foregroundColor(.orange)
                                .background(Color(red: 44/255, green: 54/255, blue: 51/255))
                                .onTapGesture {
                                    self.vidFull.toggle()
                                    print("vidFull: ", vidFull)
                                    print("landscape: ", isLandscape)
                                }
                            .DragVid(vidFull: $vidFull)
                            .opacity(isLandscape && vidFull ? 0 : 1)
                            ZStack(alignment: .top){
                                PlayerViewController(player: player.player!)
                                    .frame(width: isiPad ? geometry.size.width : (isLandscape && vidFull) ? (geometry.size.height + geometry.safeAreaInsets.bottom) * 16/9 : geometry.size.width, height: isiPad ? !isLandscape ? geometry.size.width*9/16 : vidFull ? geometry.size.height : geometry.size.width*9/16 : isLandscape ? vidFull ? (geometry.size.height + geometry.safeAreaInsets.bottom) : geometry.size.width*9/16 : geometry.size.width*9/16)
                                    .padding(.top, (isLandscape && vidFull) ? 20 : 0)
                                    .DragVid(vidFull: $vidFull)
                                    .navigationBarTitleDisplayMode(.inline)
                                    .onAppear(){
                                        player.plays()
                                    }
                                
                                //.edgesIgnoringSafeArea(.bottom)
                                HStack{
                                    VStack{}
                                        .frame(width: 120, height: geometry.size.width*9/16)
                                        .background(.black.opacity(0.01))
                                        .onTapGesture(count: 2) {
                                            player.moveFrame(to: -10.0)
                                        }
                                    Spacer()
                                    VStack{}
                                        .frame(width: 120, height: geometry.size.width*9/16)
                                        .background(.black.opacity(0.01))
                                        .onTapGesture(count: 2) {
                                            player.moveFrame(to: 10.0)
                                        }
                                }
                                //.border(.green)
                                
                                    if tap && vidFull{
                                        VStack{
                                            if !isLandscape{
                                                Spacer()
                                                    .frame(width: geometry.size.width, height: geometry.size.width*9/16 + 85)
                                            }
                                            ZStack(alignment: .leading){
                                                Rectangle()
                                                    .frame(width: geometry.size.width, height: 10)
                                                    .foregroundColor(.secondary)
                                                Rectangle()
                                                    .frame(width: player.currents < 0.9 ? 0 : (geometry.size.width - 15) * player.currents/player.intervals, height: 10)
                                                    .foregroundColor(.green)
                                                Image(systemName: "rectangle.portrait.fill")
                                                    .scaleEffect(1.5)
                                                    .frame(width: player.currents < 0.9 ? 10 : (geometry.size.width) * player.currents/player.intervals, alignment: .trailing)
                                                    .vidSlider(duartion: player.intervals, width: geometry.size.width, player: player)
                                            }
                                            .padding(.top, 4)
                                            HStack(spacing: 2){
                                                LinearGradient(colors: [
                                                    Color.blue,
                                                    Color(red: 48 / 255.0, green: 227 / 255.0, blue: 223 / 255.0)
                                                ],
                                                               startPoint: .leading,
                                                               endPoint: .trailing
                                                )
                                                .frame(height: 30)
                                                .mask(alignment: .trailing) {
                                                    if self.tone < 0 {
                                                        HStack(spacing: 3){
                                                            ForEach(0..<Int(self.tone)*(-1), id: \.self){ _ in
                                                                Rectangle()
                                                                    .cornerRadius(10)
                                                                    .frame(width: 5, height: 20)
                                                            }
                                                        }
                                                    }
                                                }
                                                Text(String(self.tone)).padding(10).shadow(radius: 20)
                                                LinearGradient(colors: [
                                                    Color(red: 48 / 255.0, green: 227 / 255.0, blue: 223 / 255.0),
                                                    Color(red: 249/255, green: 74 / 255.0, blue: 41/255)
                                                ],
                                                               startPoint: .topLeading,
                                                               endPoint: .bottomTrailing
                                                )
                                                .frame(height: 30)
                                                .mask(alignment: .leading) {
                                                    
                                                    if self.tone > 0 {
                                                        HStack(spacing: 3){
                                                            ForEach(0..<Int(self.tone), id: \.self){ _ in
                                                                Rectangle()
                                                                    .cornerRadius(10)
                                                                    .frame(width: 5, height: 20)
                                                            }
                                                        }
                                                    }
                                                }
                                                
                                            }.frame(width: geometry.size.width)
                                            if isLandscape {
                                                HStack{
                                                    Spacer()
                                                    VStack{
                                                        Button {
                                                            self.vidFull = false
                                                        } label: {
                                                            Image(systemName: "window.shade.closed")
                                                                .padding()
                                                                .tint(.white)
                                                                .background {
                                                                    Circle()
                                                                        .frame(width: 50, height: 50)
                                                                        .foregroundColor(.secondary)
                                                                }
                                                                .opacity(0.5)
                                                        }
                                                        
                                                        Button {
                                                            rotateLandscape()
                                                        } label: {
                                                            Image(systemName: "rotate.right")
                                                                .padding()
                                                                .tint(.white)
                                                                .background {
                                                                    Circle()
                                                                        .frame(width: 50, height: 50)
                                                                        .foregroundColor(.secondary)
                                                                }
                                                                .opacity(0.5)
                                                        }
                                                    }
                                                }
                                            }
                                            Spacer()
                                        }
                                        .frame(height: isLandscape ? geometry.size.height : geometry.size.width*9/16)
                                        .padding(.top, isLandscape ? 20 : 0)
                                        //.border(.white)
                                        VStack{
                                            if !isLandscape {
                                                Spacer()
                                                    .frame(width: geometry.size.width, height: geometry.size.width*9/16 + 220)
                                                    //.offset(x: 0, y: geometry.size.width*9/32)
                                                    //.border(.blue)
                                            }
                                            HStack{
                                                Button {
                                                    if !isLandscape {
                                                        player.moveFrame(to: self.goBackTime * -1)
                                                    }
                                                } label: {
                                                    if !isLandscape {
                                                        Image(systemName: "gobackward.\(Int(self.goBackTime))")
                                                            .resizable()
                                                            .scaledToFit()
                                                            .frame(height: 30)
                                                            .opacity(0.8)
                                                            .padding(.horizontal ,10)
                                                    }
                                                }
                                                Button {
                                                    if isLandscape {
                                                        self.tone -= 1
                                                        audioManager.pitchChange(tone: self.tone)
                                                    } else {
                                                        player.moveFrame(to: -10)
                                                    }
                                                } label: {
                                                    if isLandscape {
                                                        Image("KeyDown")
                                                            .resizable()
                                                            .scaledToFit()
                                                            .frame(height: 100)
                                                    } else {
                                                        Image(systemName: "gobackward.10")
                                                            .resizable()
                                                            .scaledToFit()
                                                            .frame(height: 40)
                                                            .opacity(0.8)
                                                            .padding(.horizontal ,10)
                                                    }
                                                }
                                                Button{
                                                    audioManager.play()
                                                    player.plays()
                                                    if !self.record  {
                                                        if isMicOn {
                                                            do {
                                                                let url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
                                                                let recordFile = url.appendingPathComponent("recoredForScore.m4a")
                                                                if FileManager.default.fileExists(atPath: recordFile.path) {
                                                                    try? FileManager.default.removeItem(atPath: recordFile.path)
                                                                }
                                                                let settings = [AVFormatIDKey: Int(kAudioFormatMPEG4AAC), AVSampleRateKey: 12000, AVNumberOfChannelsKey: 1, AVEncoderAudioQualityKey: AVAudioQuality.medium.rawValue]
                                                                self.recorder = try AVAudioRecorder(url: recordFile, settings: settings)
                                                                self.recorder.record()
                                                                self.record = true
                                                            }
                                                            catch {
                                                                print("setting recorder: ", error)
                                                            }
                                                        }
                                                    }
                                                } label: {
                                                    Image(systemName: player.isplaying ? "pause.circle.fill" : "play.circle.fill")
                                                        .resizable()
                                                        .scaledToFit()
                                                        .frame(height: 60)
                                                        //.border(.red)
                                                }
                                                .padding(.horizontal ,20)
                                                Button {
                                                    if isLandscape {
                                                        self.tone += 1
                                                        audioManager.pitchChange(tone: self.tone)
                                                    } else {
                                                        player.moveFrame(to: 10)
                                                    }
                                                } label: {
                                                    if isLandscape {
                                                        Image("KeyUp")
                                                            .resizable()
                                                            .scaledToFit()
                                                            .frame(height: 100)
                                                    } else {
                                                        Image(systemName: "goforward.10")
                                                            .resizable()
                                                            .scaledToFit()
                                                            .frame(height: 40)
                                                            .opacity(0.8)
                                                            .padding(.horizontal ,10)
                                                    }
                                                }
                                                Button {
                                                    if !isLandscape {
                                                        player.moveFrame(to: self.goBackTime)
                                                    }
                                                } label: {
                                                    if !isLandscape {
                                                        Image(systemName: "goforward.\(Int(self.goBackTime))")
                                                            .resizable()
                                                            .scaledToFit()
                                                            .frame(height: 30)
                                                            .opacity(0.8)
                                                            .padding(.horizontal ,10)
                                                    }
                                                }
                                            }
                                            .tint(.white)
                                            .shadow(color: !isLandscape ? .pink : .black, radius: 10)
                                            .frame(height: isLandscape ? geometry.size.height : geometry.size.width*9/16)
                                            .padding(.top, isLandscape ? 20 : 0)
                                            .scaleEffect(isiPad ? 1.2 : 1.0)
                                        }
                                        VStack{
                                            if vidFull {
                                                if !isLandscape {
                                                    Spacer()
                                                        .frame(width: geometry.size.width, height: geometry.size.width*9/16  + 100)
                                                        //.border(.red)
                                                } else {
                                                    Spacer()
                                                        .frame(width: geometry.size.width, height: geometry.size.height*2/3)
                                                }
//                                                Spacer()
//                                                    .frame(width: 50, height: isLandscape ? geometry.size.height * 4/5 : geometry.size.width*9/20)
//                                                    .border(.green)
                                                HStack(spacing: 60){
                                                    Button {
                                                        self.tempo -= 0.02
                                                        player.tempo(spd: tempo)
                                                        audioManager.tempo(spd: tempo)
                                                    } label: {
                                                        HStack{
                                                            Text(self.tempoString)
                                                            Image(systemName: "arrowtriangle.down.fill")
                                                                .opacity(0.8)
                                                                .font(.title2)
                                                        }
                                                        .background {
                                                            VStack{}
                                                                .frame(width: 90, height: 40)
                                                                .background(.thinMaterial.opacity(0.7))
                                                                .cornerRadius(10)
                                                                .shadow(color: !isLandscape ? .white : .clear, radius: 5)
                                                        }
                                                    }
                                                    HStack(spacing: 0){
                                                        Text(self.tempoString)
                                                        Text(": x")
                                                            .font(.caption)
                                                        Text(String(format: "%.2f", self.tempo))
                                                    }
                                                    .background {
                                                        VStack{}
                                                            .frame(width: 110, height: 40)
                                                            .background(.thinMaterial.opacity(0.7))
                                                            .cornerRadius(10)
                                                            .shadow(color: !isLandscape ? .white : .clear, radius: 5)
                                                    }
                                                    Button {
                                                        self.tempo += 0.02
                                                        player.tempo(spd: tempo)
                                                        audioManager.tempo(spd: tempo)
                                                    } label: {
                                                        HStack{
                                                            Text(self.tempoString)
                                                            Image(systemName: "arrowtriangle.up.fill")
                                                                .opacity(0.8)
                                                                .font(.title2)
                                                        }
                                                        .background {
                                                            VStack{}
                                                                .frame(width: 90, height: 40)
                                                                .background(.thinMaterial.opacity(0.7))
                                                                .cornerRadius(10)
                                                                .shadow(color: !isLandscape ? .white : .clear, radius: 5)
                                                        }
                                                    }
                                                }
                                                HStack(spacing: 45){
                                                    if !isLandscape {
                                                        Button {
                                                            self.tone -= 1.0
                                                            audioManager.pitchChange(tone: self.tone)
                                                        } label: {
                                                            Text("KeyDown")
                                                                .opacity(0.8)
                                                                .font(.title3)
                                                                .background {
                                                                    VStack{}
                                                                        .frame(width: 100, height: 60)
                                                                        .background(.thinMaterial.opacity(0.7))
                                                                        .cornerRadius(10)
                                                                        .shadow(color: !isLandscape ? .green : .clear, radius: 5)
                                                                }
                                                        }
                                                    }
                                                    Button {
                                                        audioManager.playClap()
                                                    } label: {
                                                        Image(systemName: "hands.clap.fill")
                                                            .opacity(0.8)
                                                            .font(.title2)
                                                            .background {
                                                                VStack{}
                                                                    .frame(width: 60, height: 60)
                                                                    .background(.thinMaterial.opacity(0.7))
                                                                    .cornerRadius(10)
                                                                    .shadow(color: !isLandscape ? .white : .clear, radius: 5)
                                                            }
                                                    }
                                                    if isLandscape {
                                                        Button {
                                                            self.vidSync -= 0.1
                                                            audioManager.vidSync = self.vidSync
                                                        } label: {
                                                            Text("-0.1s")
                                                                .opacity(0.8)
                                                                .font(.title3)
                                                                .background {
                                                                    VStack{}
                                                                        .frame(width: 100, height: 40)
                                                                        .background(.thinMaterial.opacity(0.7))
                                                                        .cornerRadius(10)
                                                                        .shadow(color: !isLandscape ? .white : .clear, radius: 5)
                                                                }
                                                        }
                                                        HStack {
                                                            Text(String(format: "%.2f", self.vidSync))
                                                            Text("s")
                                                        }
                                                        .frame(width: 80, height: 40)
                                                        .background(.thinMaterial.opacity(0.7))
                                                        .cornerRadius(10)
                                                        .shadow(color: !isLandscape ? .white : .clear, radius: 5)
                                                        Button {
                                                            self.vidSync += 0.1
                                                            audioManager.vidSync = self.vidSync
                                                        } label: {
                                                            Text("+0.1s")
                                                                .opacity(0.8)
                                                                .font(.title3)
                                                                .background {
                                                                    VStack{}
                                                                        .frame(width: 100, height: 40)
                                                                        .background(.thinMaterial.opacity(0.7))
                                                                        .cornerRadius(10)
                                                                        .shadow(color: !isLandscape ? .white : .clear, radius: 5)
                                                                }
                                                        }
                                                    }
                                                    Button {
                                                        audioManager.playCrowd()
                                                    } label: {
                                                        Image(systemName: "shareplay")
                                                            .opacity(0.8)
                                                            .font(.title2)
                                                            .background {
                                                                VStack{}
                                                                    .frame(width: 60, height: 60)
                                                                    .background(.thinMaterial.opacity(0.7))
                                                                    .cornerRadius(10)
                                                                    .shadow(color: !isLandscape ? .white : .clear, radius: 5)
                                                            }
                                                    }
                                                    if !isLandscape {
                                                        Button {
                                                            self.tone += 1.0
                                                            audioManager.pitchChange(tone: self.tone)
                                                        } label: {
                                                            Text("KeyUp")
                                                                .opacity(0.8)
                                                                .font(.title3)
                                                                .background {
                                                                    VStack{}
                                                                        .frame(width: 80, height: 60)
                                                                        .background(.thinMaterial.opacity(0.7))
                                                                        .cornerRadius(10)
                                                                        .shadow(color: !isLandscape ? .orange : .clear, radius: 5)
                                                                }
                                                        }
                                                    }
                                                }
                                                .padding(.top, 30)
                                                HStack(spacing: 60) {
                                                    if !isLandscape {
                                                        Button {
                                                            self.vidSync -= 0.1
                                                            audioManager.vidSync = self.vidSync
                                                        } label: {
                                                            Text("-0.1s")
                                                                .opacity(0.8)
                                                                .font(.title3)
                                                                .background {
                                                                    VStack{}
                                                                        .frame(width: 100, height: 40)
                                                                        .background(.thinMaterial.opacity(0.7))
                                                                        .cornerRadius(10)
                                                                        .shadow(color: !isLandscape ? .white : .clear, radius: 5)
                                                                }
                                                        }
                                                        HStack {
                                                            Text(String(format: "%.2f", self.vidSync))
                                                            Text("s")
                                                        }
                                                        .frame(width: 80, height: 40)
                                                        .background(.thinMaterial.opacity(0.7))
                                                        .cornerRadius(10)
                                                        .shadow(color: !isLandscape ? .white : .clear, radius: 5)
                                                        Button {
                                                            self.vidSync += 0.1
                                                            audioManager.vidSync = self.vidSync
                                                        } label: {
                                                            Text("+0.1s")
                                                                .opacity(0.8)
                                                                .font(.title3)
                                                                .background {
                                                                    VStack{}
                                                                        .frame(width: 100, height: 40)
                                                                        .background(.thinMaterial.opacity(0.7))
                                                                        .cornerRadius(10)
                                                                        .shadow(color: !isLandscape ? .white : .clear, radius: 5)
                                                                }
                                                        }
                                                    }
                                                }
                                                .padding(.top, 20)
//                                                Spacer()
//                                                    .frame(height: 70)
                                            }
                                        }
                                        .tint(.white)
                                        .scaleEffect(isiPad ? 1.5 : 1)
                                        //.frame(height: isLandscape ? geometry.size.height : geometry.size.width*9/16)
                                        //.border(.yellow)
                                        if player.progress {
                                            VStack(alignment: .center){
                                                Circle()
                                                    .trim(from: 0, to: 0.5)
                                                    .stroke(Color.white, lineWidth: 5)
                                                    .frame(width: 70)
                                                    .rotationEffect(Angle(degrees: isLoading ? 360 : 0))
                                                    .animation(Animation.default.repeatForever(autoreverses: false).speed(0.3), value: isLoading)
                                                    .onAppear() {
                                                        self.isLoading = true
                                                    }
                                            }
                                            .frame(width: geometry.size.width, height: geometry.size.width*9/16, alignment: .center)
                                        }
                                    }
                                    
                            }
                            //.frame(width: geometry.size.width, height: geometry.size.height - 65)
                            .offset(y: isLandscape && vidFull ? -65 : 0)
                            .onTapGesture {
                                if isLandscape {
                                    self.tap.toggle()
                                } else {
                                    self.tap = true
                                }
                            }
                            

                        }
                        
                        
                    }
                    if !isAppear{
                        ProgressView()
                            .scaleEffect(1.5)
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            .frame(width: geometry.size.width, height: geometry.size.height)
                            .background(Color(red: 44/255, green: 54/255, blue: 51/255))
                            .onAppear() {
                                //self.isReady = false
                                if !isAppear {
                                    url = URL(string: "https://www.youtube.com/watch?v=\(videoId)")
                                    self.vidEnd = false
                                    if UIDevice.current.model == "iPad" {
                                        self.isiPad = true
                                    }
                                    if self.micPermission {
                                        do {
                                            self.session = AVAudioSession.sharedInstance()
                                            try self.session.setCategory(AVAudioSession.Category.playAndRecord, mode: AVAudioSession.Mode.default, options: [.defaultToSpeaker, .allowBluetoothA2DP])
                                            self.session.requestRecordPermission { (status) in
                                                if !status {
                                                    self.isMicOn = false
                                                    print("Need permisson for use microphone")
                                                } else {
                                                    self.isMicOn = true
                                                }
                                            }
                                        }
                                        catch {
                                            print("Microphone Permission: ", error)
                                        }
                                    }
                                }
                            }
                    }
                    
                }
                .onDisappear(){
                    close()
                }
            }
        }
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


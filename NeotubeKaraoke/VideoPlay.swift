//
//  VideoPlay.swift
//  NeotubeKaraoke
//
//  Created by 안병욱 on 2023/01/14.
//

import SwiftUI
import AVKit
import PythonKit

struct VideoPlay: View {
    
    @Environment(\.dismiss) private var dismiss
    
    @State var isiPad = false
    @State var que = false
    @StateObject var player = VideoPlayers()
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
    @StateObject var audioManager = AudioManager()
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
    @State var tap = true
    //@State var isPlaying = false
    @State private var isLoading = false
    @State var closes = false
    @Binding var vidFull: Bool
    @Binding var vidEnd: Bool
    @State var isAppear: Bool = false
    @Binding var isReady: Bool
    @State var isBle: Bool = false
    
    private let tempoString: LocalizedStringKey = "Tempo"
    
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
                    //print(info?.format?.url)
                    let bestVideo = formats.filter {!$0.isRemuxingNeeded && !$0.isTranscodingNeeded}.last
                    //let bestVideo = formats.filter { $0.isVideoOnly && !$0.isTranscodingNeeded && $0.height == 1080}.last
                    //let bestVideo = formats.filter { $0.isVideoOnly && !$0.isTranscodingNeeded }.last
                    let bestAudio = formats.filter { $0.isAudioOnly && $0.ext == "m4a" }.last
                    print(bestAudio!, bestVideo!)
                    //print(self.info!)
                    guard let aUrl = bestAudio?.url else { return }
                    guard let vUrl = bestVideo?.url else { return }
                    print(aUrl)
                    //self.audioUrl = aUrl
                    //self.videoUrl = vUrl
                    //print(self.audioUrl)
                    
                    player.prepareToPlay(url: vUrl, audioManager: audioManager, fileSize: bestVideo?.filesize ?? 0)
                    loadAVAssets(url: aUrl, size: bestAudio?.filesize ?? 0)
                }
            }
            catch {
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
        DispatchQueue.global(qos: .userInitiated).async {
            do {
                youtubeDL = try YoutubeDL()
                DispatchQueue.main.async {
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
        YoutubeDL.downloadPythonModule { error in
            DispatchQueue.main.async {
                guard error == nil else {
                    return
                }
                loadPythonModule()
            }
        }
    }
    
    func loadAVAssets(url: URL, size: Int64) {
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.allHTTPHeaderFields?["Range"] = "bytes=0-\(size)"
        let task = URLSession(configuration: .default).dataTask(with: request) { data, urlResponse, error in
            let doc = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            let fileUrl = doc.appendingPathComponent("audio.m4a")
            do {
                if FileManager.default.fileExists(atPath: fileUrl.path()) {
                    try FileManager.default.removeItem(at: fileUrl)
                }
                //try FileManager.default.copyItem(at: tempUrl!, to: fileUrl)
                try data?.write(to: fileUrl)
                print(fileUrl)
                audioManager.setEngine(file: fileUrl, frequency: [32, 63, 125, 250, 500, 1000, 2000, 4000, 8000, 16000], tone: 0.0)
                self.isAppear = true
                self.isReady = true
            }
            catch {
                print(error)
                return
            }
        }
        //task.countOfBytesClientExpectsToReceive = size
        //task.priority = URLSessionTask.highPriority
        task.resume()
    }
    
    var body: some View {
        NavigationStack{
            GeometryReader { geometry in
                ZStack{
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
                        }
                    }
                    if isAppear {
                        VStack(spacing: 0){
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
                            .background(Color(red: 44/255, green: 54/255, blue: 51/255))
                            .onTapGesture {
                                self.vidFull.toggle()
                                print("vidFull")
                            }
                            .DragVid(vidFull: $vidFull)
                            .opacity(UIDevice.current.orientation.isLandscape || UIDevice.current.orientation == .portraitUpsideDown && vidFull ? 0.01 : 1)
                            ZStack(alignment: .top){
                                PlayerViewController(player: player.player!)
                                    .frame(width: isiPad ? geometry.size.width : UIDevice.current.orientation.isLandscape ? (geometry.size.height + geometry.safeAreaInsets.bottom) * 16/9 : geometry.size.width, height:isiPad ? !UIDevice.current.orientation.isLandscape ? geometry.size.width*9/16 : geometry.size.height : UIDevice.current.orientation.isLandscape ? (geometry.size.height + geometry.safeAreaInsets.bottom) : geometry.size.width*9/16)
                                    //.border(.red, width: 1)
                                    //.edgesIgnoringSafeArea(.all)
                                    .padding(.top, UIDevice.current.orientation.isLandscape ? 20 : 0)
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
                                
                                    if tap {
                                        VStack{
                                            if !UIDevice.current.orientation.isLandscape {
                                                Spacer()
                                                    .frame(width: geometry.size.width, height: geometry.size.width*9/16 + 85)
                                            }
                                            ZStack(alignment: .leading){
                                                Rectangle()
                                                    .frame(width: geometry.size.width, height: 10)
                                                    .foregroundColor(.secondary)
                                                Rectangle()
                                                    .frame(width: player.currents < 0.9 ? 0 : (geometry.size.width - 15) * player.currents/CMTimeGetSeconds((player.player?.currentItem!.duration)!)/**2*/, height: 10)
                                                    .foregroundColor(.green)
                                                Image(systemName: "rectangle.portrait.fill")
                                                    .scaleEffect(1.5)
                                                    .frame(width: player.currents < 0.9 ? 10 : (geometry.size.width) * player.currents/CMTimeGetSeconds((player.player?.currentItem!.duration)!), alignment: .trailing)
                                                    .vidSlider(duartion: CMTimeGetSeconds( (player.player?.currentItem!.duration)!), width: geometry.size.width, player: player)
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
                                            if UIDevice.current.orientation.isLandscape {
                                                HStack{
                                                    Spacer()
                                                    Button {
                                                        self.vidFull = false
                                                    } label: {
                                                        Image(systemName: "window.shade.closed")
                                                            .padding()
                                                            .tint(.white)
                                                            .background {
                                                                Circle()
                                                                    .frame(width: 30, height: 30)
                                                                    .foregroundColor(.secondary)
                                                            }
                                                    }
                                                    
                                                }
                                            }
                                            Spacer()
                                        }
                                        .frame(height: UIDevice.current.orientation.isLandscape ? geometry.size.height : geometry.size.width*9/16)
                                        .padding(.top, UIDevice.current.orientation.isLandscape ? 20 : 0)
                                        //                                    .onAppear(){
                                        //                                        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 5) {
                                        //                                            self.tap = false
                                        //                                        }
                                        //                                    }
                                        //.border(.red, width: 3.0)
                                        VStack{
                                            if !UIDevice.current.orientation.isLandscape {
                                                Spacer()
                                                    .frame(width: geometry.size.width, height: geometry.size.width*9/16 + 160)
                                            }
                                            
                                            HStack{
                                                Spacer()
                                                Button {
                                                    if UIDevice.current.orientation.isLandscape {
                                                        self.tone -= 1
                                                        audioManager.pitchChange(tone: self.tone)
                                                    } else {
                                                        player.moveFrame(to: -20)
                                                    }
                                                } label: {
                                                    if UIDevice.current.orientation.isLandscape {
                                                        Image("KeyDown")
                                                            .resizable()
                                                            .scaledToFit()
                                                            .frame(height: 100)
                                                    } else {
                                                        Image(systemName: "backward.fill")
                                                            .resizable()
                                                            .scaledToFit()
                                                            .frame(height: 30)
                                                            .opacity(0.8)
                                                    }
                                                }
                                                Spacer()
                                                Button{
                                                    audioManager.play()
                                                    player.plays()
                                                } label: {
                                                    Image(systemName: player.isplaying ? "pause.circle.fill" : "play.circle.fill")
                                                        .resizable()
                                                        .scaledToFit()
                                                        .frame(height: 50)
                                                }
                                                Spacer()
                                                Button {
                                                    if UIDevice.current.orientation.isLandscape {
                                                        self.tone += 1
                                                        audioManager.pitchChange(tone: self.tone)
                                                    } else {
                                                        player.moveFrame(to: 20)
                                                    }
                                                } label: {
                                                    if UIDevice.current.orientation.isLandscape {
                                                        Image("KeyUp")
                                                            .resizable()
                                                            .scaledToFit()
                                                            .frame(height: 100)
                                                    } else {
                                                        Image(systemName: "forward.fill")
                                                            .resizable()
                                                            .scaledToFit()
                                                            .frame(height: 30)
                                                            .opacity(0.8)
                                                    }
                                                }
                                                Spacer()
                                            }
                                            .tint(.white)
                                            .shadow(color: !UIDevice.current.orientation.isLandscape ? .pink : .black, radius: 10)
                                            .frame(height: UIDevice.current.orientation.isLandscape ? geometry.size.height : geometry.size.width*9/16)
                                            .padding(.top, UIDevice.current.orientation.isLandscape ? 20 : 0)
                                            
                                        }
                                        VStack{
                                            if vidFull {
                                                if !UIDevice.current.orientation.isLandscape {
                                                    Spacer()
                                                        .frame(width: geometry.size.width, height: geometry.size.width*9/16 + 120)
                                                }
                                                Spacer()
                                                    .frame(height: UIDevice.current.orientation.isLandscape ? geometry.size.height * 4/5 : geometry.size.width*9/20)
                                                HStack(spacing: 50){
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
                                                                .frame(width: 90, height: 60)
                                                                .background(.thinMaterial.opacity(0.7))
                                                                .cornerRadius(10)
                                                                .shadow(color: !UIDevice.current.orientation.isLandscape ? .white : .clear, radius: 5)
                                                        }
                                                    }
                                                    HStack(spacing: 0){
                                                        Text(self.tempoString)
                                                        Text(": x")
                                                            .font(.caption)
                                                        Text(String(self.tempo))
                                                    }
                                                    .background {
                                                        VStack{}
                                                            .frame(width: 110, height: 60)
                                                            .background(.thinMaterial.opacity(0.7))
                                                            .cornerRadius(10)
                                                            .shadow(color: !UIDevice.current.orientation.isLandscape ? .white : .clear, radius: 5)
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
                                                                .frame(width: 90, height: 60)
                                                                .background(.thinMaterial.opacity(0.7))
                                                                .cornerRadius(10)
                                                                .shadow(color: !UIDevice.current.orientation.isLandscape ? .white : .clear, radius: 5)
                                                        }
                                                    }
                                                }
                                                HStack(spacing: 40){
                                                    if !UIDevice.current.orientation.isLandscape {
                                                        Button {
                                                            self.tone -= 1
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
                                                                        .shadow(color: !UIDevice.current.orientation.isLandscape ? .green : .clear, radius: 5)
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
                                                                    .shadow(color: !UIDevice.current.orientation.isLandscape ? .white : .clear, radius: 5)
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
                                                                    .shadow(color: !UIDevice.current.orientation.isLandscape ? .white : .clear, radius: 5)
                                                            }
                                                    }
                                                    if !UIDevice.current.orientation.isLandscape {
                                                        Button {
                                                            self.tone += 1
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
                                                                        .shadow(color: !UIDevice.current.orientation.isLandscape ? .orange : .clear, radius: 5)
                                                                }
                                                        }
                                                    }
                                                }
                                                .padding(.top, 40)
                                                Spacer()
                                            }
                                        }
                                        .tint(.white)
                                        .frame(height: UIDevice.current.orientation.isLandscape ? geometry.size.height : geometry.size.width*9/16)
                                        
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
                                            /*
                                             ProgressView()
                                             .scaleEffect(4)
                                             .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                             .frame(width: geometry.size.width, height: geometry.size.width*9/16, alignment: .center)
                                             */
                                        }
                                    }
                                    
                            }
                            //.frame(width: geometry.size.width, height: geometry.size.height - 65)
                            .offset(y: UIDevice.current.orientation.isLandscape && vidFull ? -65 : 0)
                            .onTapGesture {
                                if UIDevice.current.orientation.isLandscape {
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


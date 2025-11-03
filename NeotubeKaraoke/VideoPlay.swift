//
//  VideoPlay.swift
//  NeotubeKaraoke
//
//  Created by 안병욱 on 2023/01/14.
//

import SwiftUI
import AVKit
import VLCKitSPM
//import PythonKit
//import UIKit

struct VideoPlay: View {
    //MARK: - 변수들
    //@AppStorage("micPermission") var micPermission: Bool = UserDefaults.standard.bool(forKey: "micPermission")
    @AppStorage("moveFrameTime") var goBackTime: Double = 15.0 //UserDefaults.standard.double(forKey: "moveFrameTime")
    @AppStorage("colorMode") var colorMode: String = (UserDefaults.standard.string(forKey: "colorMode") ?? "auto")
    @AppStorage("colorSchemeOfSystem") var colorSchemeOfSystem: String = "light"
    @EnvironmentObject var envPlayer: EnvPlayer
    
    //@State var isiPad = false
    //@State var que = false
    @StateObject var player: vlcPlayerController = vlcPlayerController()
    @StateObject var audioManager = AudioManager()
    @StateObject var downloadManager = MultiPartsDownloadTask()
    @State var tone: Float = 0.0 {
        didSet {
            if tone > 24.0 {
                tone = oldValue
            } else if tone < -24.0 {
                tone = oldValue
            } else {}
            audioManager.pitchChange(tone: self.tone)
        }
    }
    @State var tones: Int = 0 {
        didSet {
            if tones != oldValue && abs(tones - oldValue) < 3 && pitchPressed == true {
                if tones > oldValue {
                    tone += 1
                } else {
                    tone -= 1
                }
                HapticManager.instance.impact(style: .light)
            } else {}
        }
    }
    @State var tempo: Float = 1.0 {
        didSet {
            if tempo > 10.0 {
                tempo = oldValue
            } else if tempo < 0.1 {
                tempo = oldValue
            } else {}
            player.tempo(spd: tempo)
            audioManager.tempo(spd: tempo)
        }
    }
    @State var tempos: Int = 1 {
        didSet {
            if tempos != oldValue && abs(tempos - oldValue) < 3 && tempoPressed == true {
                if tempos > oldValue {
                    tempo += 0.02
                } else {
                    tempo -= 0.02
                }
                HapticManager.instance.impact(style: .light)
            } else {}
        }
    }
    @Binding var videoId: String
    @StateObject var innertube = InnerTube()
    
    @State var tap = false
    @Binding var vidFull: Bool
    @Binding var vidEnd: Bool {
        didSet {
            if vidEnd == true {
                self.vidFull = false
                self.isAppear = false
            }
        }
    }
    @State var isAppear: Bool = false
    @Binding var resolution: Resolution
    @Binding var isLandscape: Bool
    
    //@State var session: AVAudioSession!
    //@State var recorder: AVAudioRecorder!
    //@State var record: Bool = false
    //@State var sample = [Float]()
    //@State var isMicOn = false
    //@State var vidSync = 0.0
    //@Binding var score: Int
    //@State var lowVideoUrl: URL?
    
    @State var scWidth = 0.0
    @State var scHeight = 0.0
    
    @State var pitchPressed = false
    @State var tempoPressed = false
    @State var ringAngle: Double = 0.0
    @Binding var clickVid: Bool
    @State var playing: Bool = false
    //@State var isPlaying: Bool = false
//   @State var vidurl: URL?
    @State var vidLength: Double = 0.1
//    @State var time: Double = 0.0
//    @State var forawardOrRewind: String = ""
//    //@State var setTime: Int32 = 0 {
//        didSet {
//            self.player.time = VLCTime(int: setTime)
//        }
//    }
    
    //@Binding var canPlay: Bool
    
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) var colorScheme
    
    //MARK: - 뷰 바디 여기 있음
    var body: some View {
        ZStack{
            // 화면 크기 파악
            GeometryReader{ geometry in
                ZStack{ //무조건 있는 뷰임으로 다크모드 라이트 모드 설정
                    if colorMode == "dark" {
                        Spacer()
                            .preferredColorScheme(.dark)
                    } else if colorMode == "light" {
                        Spacer()
                            .preferredColorScheme(.light)
                    } else {
                        Spacer()
                            .preferredColorScheme(colorSchemeOfSystem == "dark" ? .dark : .light)
                    }
                    Spacer()
                }.onAppear() {
                    self.scHeight = geometry.size.height
                    self.scWidth = geometry.size.width
                    //self.vidFull = true // 전체 화면
                    //self.innertube.initialWebPageData(videoId: videoId) //MARK: !!!!!!!!!!영상 정보 함수 실행
                    self.vidEnd = false // 영상 종료 아님 확인
                    //print(geometry.size.height)
                }
                .onChange(of: geometry.size) { _ in // 뷰 사이즈는 계속 변화함으로
                    self.scHeight = geometry.size.height
                    self.scWidth = geometry.size.width
//                    print(geometry.size.height)
//                    print(geometry.size.width)
                    
                }
                .onReceive(NotificationCenter.default.publisher(for: UIDevice.orientationDidChangeNotification), perform: { _ in // 방향 전환 감지
                    self.scHeight = 0
                    self.scWidth = 0
                })
            }
            .ignoresSafeArea(.all)
            .background(colorScheme == .dark ? Color(red: 0.13, green: 0.13, blue: 0.13) : Color(red: 0.9412, green: 0.9255, blue: 0.8980))
//            .background(Color(red: 0.9412, green: 0.9255, blue: 0.8980))
            .brightness(-0.02)
            
            //MARK: - 각종 매니저 및 엔진 코드 변화감지
            // 영상정보 준비됨
            if innertube.infoReady {
                Spacer().onAppear(){
                    getTubeInfo()
                }
            }
            // 영상 오디오 다운 완료
            if self.downloadManager.que {
                Spacer().onAppear(){
                    self.audioEngineSet()
                }
            }
            //비디오 종료 시
            if self.player.vidEnd {
                Spacer().onAppear(){
                    self.vidEnd = true
                    self.vidFull = false
                    self.isAppear = false
                }
            }
            //MARK: - 진짜 보이는 뷰
            VStack(spacing: 0.0){
                if scWidth < scHeight { //세로 보드 영상 제목 뷰
                    HStack{
                        Spacer()
                        Text(self.innertube.info?.videoDetails?.title ?? "노래방")
                            .lineLimit(2)
                            .foregroundStyle(colorScheme == .dark ? .white : .black)
                            .bold()
                            .padding()
                        Spacer()
                    }
                    //.background(.background)
                    .DragVid(vidFull: $vidFull, tap: $tap)
                    .onTapGesture {
                        self.vidFull.toggle()
                    }
                }
                //Text("\(self.scWidth)\(self.scHeight)")
                //영상 플레이어 뷰
                ZStack{
                    //PlayerViewController(player: player.player ?? AVPlayer())
                    VLCView(player: player)
                    //VLCPlayerView(url: $vidurl, audioManager: audioManager, vidLength: $vidLength, time: $time, end: $vidEnd, isPlaying: $isPlaying, tempo: $tempo, forawardOrRewind: $forawardOrRewind, setTIme: $setTime)
                        .DragVid(vidFull: $vidFull, tap: $tap)
                        .ignoresSafeArea(.container)
                        .onTapGesture(count: 2, perform: { dot in //더블 탭 건너뛰기
                            if dot.x > scWidth * 0.66  {
                                //player.moveFrame(to: self.goBackTime, spd: self.tempo) // 앞으로 15초
                                //self.forawardOrRewind = "+"
                                self.player.moveFrame(to: Int32(self.goBackTime))
                            } else if dot.x < scWidth * 0.33 {
                                //player.moveFrame(to: -1 * self.goBackTime, spd: self.tempo) // 뒤로 15초
                                //self.forawardOrRewind = "-"
                                self.player.moveFrame(to: Int32(-self.goBackTime))
                            }
                        })
                        .simultaneousGesture(
                            TapGesture(count: 1).onEnded{
                                
                                tap.toggle()
                                print("Tap")
                            }
                        )
                    
                    if !self.player.ready && self.vidFull && !self.envPlayer.isOn {
                            AsyncImage(url: URL(string: self.innertube.info?.videoDetails?.thumbnail?.thumbnails?.last?.url ?? "")){ image in
                                if self.scWidth < self.scHeight {
                                    image
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: self.scWidth, height: scWidth*9/16)
                                        .clipShape(
                                            RoundedRectangle(cornerRadius: 0)
                                                .size(width: self.scWidth, height: scWidth*27/64)
                                                .offset(x: 0, y: scWidth*9/128)
                                        )
                                        .scaleEffect(4/3)
                                        .DragVid(vidFull: $vidFull, tap: $tap)
                                } else {
                                    image
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: self.scHeight*16/9, height: self.scHeight)
                                        .clipShape(
                                            RoundedRectangle(cornerRadius: 0)
                                                .size(width: self.scHeight*27/64, height: self.scHeight*3/4)
                                                .offset(x: 0, y: self.scHeight/8)
                                        )
                                        .scaleEffect(4/3)
                                        .DragVid(vidFull: $vidFull, tap: $tap)
                                        .border(.red, width: 3.0)
                                }
                                    
                                    //.frame(width: self.scWidth, height: self.scWidth*9/16)
                                //.shadow(color: .black,radius: 10, x: 0, y: 10)
                            } placeholder: {
                                ZStack{
                                    Rectangle()
                                        .foregroundStyle(Color(red: 1, green: 112 / 255.0, blue: 0))
                                        .aspectRatio(16/9, contentMode: .fill)
                                        .scaledToFit()
                                        .cornerRadius(8)
                                        .frame(height: 60)
                                    Image(systemName: "music.note.tv")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(height: 40)
                                        .foregroundColor(Color.white)
                                }
                                .frame(height: 90)
                                .padding(.leading,7)
                                .DragVid(vidFull: $vidFull, tap: $tap)
                            }
                            .aspectRatio(16/12, contentMode: .fit)
                            
                        } else if !self.player.isPlaying && !self.vidFull {
                            //AVPlayer 준비 전 사각형 하나 그려줌(플레이어로 속이는 용도)
                            Rectangle()
                                .foregroundStyle(.background)
                                .brightness(-0.3)
                        }
                    if self.envPlayer.isOn && self.vidFull {
                        Image(systemName: "display")
                            .resizable()
                            .scaledToFit()
                            .frame(
                                width: self.scWidth < self.scHeight ? self.scWidth : self.scHeight*27/64,
                                height:  self.scWidth < self.scHeight ? self.scWidth*27/64 : self.scHeight*3/4
                            )
                            .foregroundStyle(.gray)
                    }
                        //                        .onAppear(){
                        //                            player.player?.play()
                        //
                    }
//                }
                if scWidth < scHeight && vidFull { // 화면 세로 모드 및 플레이어 뷰 전체 화면일 경우
                    buttons(scLength: scWidth, radius: scWidth/scHeight > 0.5 ? 0.38 : 0.55)
                        .onAppear(){
                            tap = false
                            print("화면비", scWidth/scHeight)
                        }
                }
            }
            if scWidth > scHeight && tap {
                buttons(scLength: scHeight, radius: 0.4)
            }
            // 플레이어 뷰 최소화시 제목 보여줌
            VStack{
                if !vidFull {
                    HStack{
                        Spacer()
                        Text(self.innertube.info?.videoDetails?.title ?? "선곡해주세요")
                            .foregroundStyle(colorScheme == .dark ? .white : .black)
                            .bold()
                            .padding()
                        //MARK: - 처음 시작
                            .onChange(of: self.videoId) { _ in
                                self.playing = false
                                self.vidEnd = false
                                self.audioManager.pause()
                                self.isAppear = false
                                //self.isReady = false
                                self.downloadManager.reset()
                                self.innertube.infoReady = false
                                
                                self.innertube.player(videoId: videoId)
                                //self.innertube.initialWebPageData(videoId: self.videoId)
                                //Parse().get_Parse(url:"https://youtube.com/watch?v=\(self.videoId)")
                                self.clickVid = false
                            }
                        Spacer()
                        Button{
                            audioManager.play()
                            self.player.plays()
                        } label: {
                            Image(systemName: self.player.ready ? "pause.circle.fill" : "play.circle.fill")
                                .resizable()
                                .scaledToFit()
                                .frame(height: 30)
                                .padding(.horizontal, 5)
                        }
                        .disabled(!isAppear)
                        .tint(Color.orange)
                    }
                    .background(colorScheme == .dark ? Color(red: 0.13, green: 0.13, blue: 0.13) : Color(red: 0.9412, green: 0.9255, blue: 0.8980))
                    .onTapGesture {
                        self.vidFull.toggle()
                    }
//                    .gesture(
//                        DragGesture()
//                            .onEnded({ gesture in
//                                if gesture.translation.width < -150 {
//                                    vidEnd = true
//                                    audioManager.play()
//                                    player.plays()
//                                }
//                            })
//                    )
                }
            }
        }
    }
}
//MARK: 뷰
extension VideoPlay {
    func buttons(scLength: Double, radius: Double = 0.55) -> some View {
        VStack{
            //비디오 상태 표시 줄
            ZStack(alignment: .leading){
                Rectangle()
                    .frame(width: scWidth > scHeight ? scLength*16/9 > scWidth ? scWidth : scLength*16/9 : scLength, height: 10)
                    .foregroundColor(.secondary)
                if self.player.ready{
                    Rectangle()
                        .frame(
                            width: self.player.currentTIme < 0.9 ? 0 : (scWidth > scHeight ? scLength*16/9 > scWidth ? scWidth :  scLength*16/9 : scLength - 15) * self.player.currentTIme/self.vidLength,
                            height: 10
                        )
                        .foregroundColor(.green)
                        .onAppear() {
                            print("interval: ", self.vidLength)
                        }
                    Image(systemName: "rectangle.portrait.fill")
                        .scaleEffect(1.5)
                        .frame(
                            width: self.player.currentTIme < 0.9 ? 10 : (scWidth > scHeight ? scLength*16/9 > scWidth ? scWidth :  scLength*16/9 : scLength) * self.player.currentTIme/self.vidLength,
                            alignment: .trailing
                        )
                        .vidSlider(duartion: self.vidLength,width: scWidth > scHeight ? (scLength*16/9 > scWidth ? scWidth :  scLength*16/9) : scLength, player: self.player)
                        .foregroundStyle(.white)
                }
            }
            .padding(.top, 3)
            // 음정 뷰
            pitchView(scLength: scWidth > scHeight ?scLength*16/9 > scWidth ? scWidth :  scLength*16/9 : scLength)
            // 템포 숫자 보여줌
            HStack(spacing: 0){
                Text("템포: x")
                Text(String(format: "%.2f", self.tempo))
            }
            .foregroundStyle((colorScheme == .light && scWidth < scHeight  ) ? .black : .white)
            .shadow(color: scWidth < scHeight ? .clear : .black, radius: /*@START_MENU_TOKEN@*/10/*@END_MENU_TOKEN@*/)
            ZStack{
                // 휠 누르면 그라데이션으로 변경
                AngularGradient(
                    gradient: Gradient(colors: tempoPressed || pitchPressed ? [.white, .red, .blue, .white] : [.white]),
                    center: .bottom,
                    angle: .degrees(90))
                .mask{
                    Circle()
                        .stroke(lineWidth: (0.6 > scWidth/scHeight && scWidth/scHeight > 0.5) ? 40 : 60)
                        .frame(width: scLength*radius)
                        .shadow(radius: 8, y: 5)
                }
                .rotationEffect(.degrees(ringAngle))
                .shadow(radius: 8, y: 5)
                .frame(
                    width: scWidth > scHeight ? scLength * 0.55 : scWidth/scHeight > 0.5 ? scLength * 0.55 : scLength,
                    height: scWidth > scHeight ? scLength * 0.55 : scWidth/scHeight > 0.5 ? scLength * 0.55 : scLength * 0.8
                )
                // 휠 돌릴 때 생기든 도형
                RoundedRectangle(cornerRadius: 10)
                    .frame(width: 10, height: 70)
                    .foregroundStyle(.white)
                    .opacity(tempoPressed || pitchPressed ? 1.0 : 0.0)
                    .offset(y: scLength * radius / 2)
                    .rotationEffect(.degrees(ringAngle))
                ZStack{
                    // 템포 버튼
                    Text("템포")
                        .frame(width: 80, height: 40, alignment: .center)
                        .offset(y: -scLength * radius / 2)
                        .foregroundStyle(tempoPressed ? .white : .gray)
                        .opacity(pitchPressed ? 0.0 : 1.0)
                        .gesture(
                            DragGesture(minimumDistance: 0)
                                .onChanged({ dot in
                                    if isAppear{
                                        tempoPressed = true
                                        change(location: dot.location)
                                    }
                                })
                                .onEnded({ _ in
                                    tempoPressed = false
                                    self.tempos = 1
                                })
                        )
                    
//                            Spacer()
//                                .frame(height: 160)
//                                .foregroundStyle(.foreground)
                    // 음정 버튼
                    Text("음정")
                        .frame(width: 80, height: 40, alignment: .center)
                        .offset(y: scLength * radius / 2)
                        .foregroundStyle(pitchPressed ? .white : .gray)
                        .opacity(tempoPressed ? 0.0 : 1.0)
                        .gesture(
                            DragGesture(minimumDistance: 0)
                            .onChanged({ dot in
                                if isAppear{
                                    pitchPressed = true
                                    change(location: dot.location)
                                }
                            })
                            .onEnded({ _ in
                                pitchPressed = false
                                self.tones = 0
                            })
                        )
                    // 뒤로 15초
                    Button {
                        HapticManager.instance.impact(style: .light)
                        //player.moveFrame(to: -1 * self.goBackTime, spd: self.tempo)
                        //self.forawardOrRewind = "+"
                        self.player.moveFrame(to: Int32(-self.goBackTime))
                    } label: {
                        Image(systemName: "gobackward.\(Int(self.goBackTime))")
                            .resizable()
                            .scaledToFit()
                            .frame(height: 30)
                            .foregroundStyle(tempoPressed || pitchPressed ? .clear : .gray)
                    }
                    .offset(x: -scLength * radius / 2)
                    .disabled(!isAppear)
                    // 앞으로 15초
                    Button {
                        HapticManager.instance.impact(style: .light)
                        //self.forawardOrRewind = "+"
                        self.player.moveFrame(to: Int32(self.goBackTime))
                    } label: {
                        Image(systemName: "goforward.\(Int(self.goBackTime))")
                            .resizable()
                            .scaledToFit()
                            .frame(height: 30)
                            .foregroundStyle(tempoPressed || pitchPressed ? .clear : .gray)
                    }
                    .offset(x: scLength * radius / 2)
                    .disabled(!isAppear)
                }
                
                //재생 정지 버튼
                Button{
                    audioManager.play()
                    self.player.plays()
                } label: {
                    ZStack{
                        Circle()
                            .foregroundStyle(.white)
                            .frame(height: (0.6 > scWidth/scHeight && scWidth/scHeight > 0.5) ? 70 : 90)
                            .shadow(radius: 8, y: 5)
                        Image(systemName: self.player.vidState == .playing ? "pause.fill" : "play.fill")
                            .resizable()
                            .scaledToFit()
                            .frame(height: 40)
                            .offset(x: self.player.vidState == .playing ? 0 : 5)
                            .foregroundStyle(.red)
                    }
                }
                .padding(.horizontal ,20)
                .disabled(!isAppear)
            }
            HStack{
                Spacer()
                Button {
                    audioManager.playClap()
                } label: {
                    Image(systemName: "hands.clap.fill")
                        .opacity(0.8)
                        .font(.title)
                }
                .disabled(!isAppear)
                Spacer()
                Button {
                    rotateLandscape()
                } label: {
                    Image(systemName: "rectangle.landscape.rotate")
                        .opacity(0.8)
                        .font(.title)
                }
                .disabled(!isAppear)
                Spacer()
                Button {
                    audioManager.playCrowd()
                } label: {
                    Image(systemName: "person.2.wave.2.fill")
                        .opacity(0.8)
                        .font(.title)
                }
                .disabled(!isAppear)
                Spacer()
            }
            .foregroundStyle((colorScheme == .light && scWidth < scHeight  ) ? .gray : .white)
                .shadow(color: scWidth < scHeight ? .clear : .black, radius: /*@START_MENU_TOKEN@*/10/*@END_MENU_TOKEN@*/)
        }
    }
    // 음정 뷰
    func pitchView(scLength: Double) -> some View {
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
                } else {}
            }
            
            //텍스트
            Text("음정: \(Int(self.tone))")
                .padding(10)
                .shadow(radius: 20)
                .foregroundStyle((colorScheme == .light && scWidth < scHeight  ) ? .black : .white)
                .shadow(color: scWidth < scHeight ? .clear : .black, radius: /*@START_MENU_TOKEN@*/10/*@END_MENU_TOKEN@*/)
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
                } else {}
            }
            
        }.frame(width: scLength)
        
    }
}

//MARK: 함수들
extension VideoPlay {
    // 화면 가로 세로
    func rotateLandscape() {
        if !isLandscape {
            if #available(iOS 16.0, *) {
                let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene
                windowScene?.requestGeometryUpdate(.iOS(interfaceOrientations: .landscapeRight))
                self.isLandscape = true
                self.tap = false
            } else {
                let value = UIInterfaceOrientation.landscapeLeft.rawValue
                UIDevice.current.setValue(value, forKey: "orientation")
                self.isLandscape = true
                self.tap = false
            }
        } else {
            if #available(iOS 16.0, *) {
                let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene
                windowScene?.requestGeometryUpdate(.iOS(interfaceOrientations: .portrait))
                self.isLandscape = false
                self.tap = false
            } else {
                let value = UIInterfaceOrientation.portrait.rawValue
                UIDevice.current.setValue(value, forKey: "orientation")
                self.isLandscape = false
                self.tap = false
            }
        }
    }
    // 유튜브 영상 정보 가져와서 세팅
    func getTubeInfo() {
        if !playing {
            //let hd720 = self.innertube.info?.streamingData?.formats?.filter{$0.qualityLabel ?? "" == "720p"}.last
            //let hd360 = self.innertube.info?.streamingData?.formats?.filter{$0.qualityLabel ?? "" == "360p"}.last
            let hd1080 = self.innertube.info?.streamingData?.adaptiveFormats?.filter{$0.qualityLabel ?? "" == "1080p"}.last
            let hd720 = self.innertube.info?.streamingData?.adaptiveFormats?.filter{$0.qualityLabel ?? "" == "720p"}.last
            let hd360 = self.innertube.info?.streamingData?.adaptiveFormats?.filter{$0.qualityLabel ?? "" == "360p"}.last
            var selectedVideo = /*TubeFormats(audioQuality: "")*/ TubeAdaptiveFormats()
            if resolution == .low || hd720 == nil {
                selectedVideo = hd360 ?? /*TubeFormats(audioQuality: "")*/ TubeAdaptiveFormats(audioQuality: "")
            } else if resolution == .basic {
                selectedVideo = hd720 ?? /*TubeFormats(audioQuality: "")*/ TubeAdaptiveFormats(audioQuality: "")
            } else {
                selectedVideo = hd1080 ?? /*TubeFormats(audioQuality: "")*/ TubeAdaptiveFormats(audioQuality: "")
            }
//            let audio = self.innertube.info?.streamingData?.adaptiveFormats?.filter{$0.audioQuality == "AUDIO_QUALITY_MEDIUM"}.first
            print("🙏🙏🙏🙏🙏🙏🙏🙏🙏", self.innertube.info?.streamingData?.adaptiveFormats?.map { $0 })
            guard let audio = self.innertube.info?.streamingData?.adaptiveFormats?.filter{$0.mimeType?.contains("audio") ?? true && $0.mimeType?.contains("mp4") ?? true}.last else {return}
            print("🙏🙏🙏🙏🙏🙏🙏🙏🙏",audio.mimeType)
            self.downloadManager.createDownloadParts(url: URL(string: audio.url ?? "")!, size: Int(audio.contentLength ?? "") ?? 0, video: false )
            //self.player.prepareToPlay(url: URL(string: selectedVideo.url ?? "http://www.youtube.com")!, audioManager: audioManager, fileSize: Int(selectedVideo.contentLength ?? "") ?? 0, isOk: true)
            let length = Double(self.innertube.info?.videoDetails?.lengthSeconds ?? "0") ?? 0
            self.vidLength = length
            let vidurl = URL(string: selectedVideo.url ?? "http://www.youtube.com")
            print(selectedVideo.url)
            self.player.loadVideo(url: vidurl, vidLength: length, audioManager: self.audioManager)
            envPlayer.player = self.player
            if envPlayer.isConnected {
                envPlayer.isOn = true
            }
        }
    }
    // 오디오 세팅
    func audioEngineSet() {
        let doc = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let fileUrl = doc.appendingPathComponent("audio.m4a")
        audioManager.setEngine(file: fileUrl, frequency: [32, 63, 125, 250, 500, 1000, 2000, 4000, 8000, 16000], tone: 0.0, views: "VideoPlay View - audio engine set")
        //self.tone = 0.0
        //self.tempo = 1.0
        self.isAppear = true
        //self.isReady = true
        self.vidFull = true
        self.playing = true
        self.vidEnd = false
    }
    // 휠 돌아감 측정
    private func change(location: CGPoint) {
        let vector = CGVector(dx: location.x - 40, dy: location.y - 20)
        //print("loca", location.x, location.y)
        let radian = atan2(vector.dy , vector.dx)
        let angle = radian * 180 / .pi - 75
        self.ringAngle = angle > 0 ? angle : angle + 360
        if pitchPressed {
            self.tones = Int(Float(ringAngle) / 30)
        } else if tempoPressed {
            self.tempos = Int(Float(ringAngle) / 30) - 5
        }
    }
}


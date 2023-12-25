//
//  VideoPlay.swift
//  NeotubeKaraoke
//
//  Created by 안병욱 on 2023/01/14.
//

import SwiftUI
import AVKit
//import PythonKit
import UIKit

struct VideoPlay: View {
    //MARK: - 변수들
    @AppStorage("micPermission") var micPermission: Bool = UserDefaults.standard.bool(forKey: "micPermission")
    @AppStorage("moveFrameTime") var goBackTime: Double = UserDefaults.standard.double(forKey: "moveFrameTime")
    @AppStorage("colorMode") var colorMode: String = (UserDefaults.standard.string(forKey: "colorMode") ?? "auto")
    @AppStorage("colorSchemeOfSystem") var colorSchemeOfSystem: String = "light"
    @EnvironmentObject var envPlayer: EnvPlayer
    
    @State var isiPad = false
    @State var que = false
    @ObservedObject var player = VideoPlayers()
    @ObservedObject var audioManager = AudioManager()
    @StateObject var downloadManager = MultiPartsDownloadTask()
    @State var tone: Float = 0.0 {
        didSet {
            if tone > 24.0 {
                tone = oldValue
            } else if tone < -24.0 {
                tone = oldValue
            } else {}
        }
    }
    @State var tones: Int = 0 {
        didSet {
            if tones != oldValue {
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
        }
    }
    @State var tempos: Int = 1 {
        didSet {
            if tempos != oldValue {
                if tempos > oldValue {
                    tempo += 0.1
                } else {
                    tempo -= 0.1
                }
                HapticManager.instance.impact(style: .light)
            } else {}
        }
    }
    var videoId: String = ""
    @StateObject var innertube = InnerTube()
    
    @State var tap = false
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
    @State var lowVideoUrl: URL?
    
    @State var scWidth = 0.0
    @State var scHeight = 0.0
    
    @State var pitchPressed = false
    @State var tempoPressed = false
    @State var ringAngle: Double = 0.0
    
//    @Binding var colorMode: String
//    @Binding var colorSchemeOfSystem: ColorScheme
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) var colorScheme
    
    //MARK: - 뷰 바디 여기 있음
    /*var body: some View {
        NavigationStack{
            GeometryReader { geometry in
                
                ZStack{
                    
                    if self.downloadManager.que {
                        VStack{}.onAppear(){
                            self.audioEngineSet()
                        }
                    } else {}
                    if !self.player.isMuted {
                        VStack{}.onAppear(){
                            self.player.isMuted = true
                        }
                    } else {}
                    if !isLandscape {
                        VStack{}.onAppear(){
                            self.tap = true
                        }
                    } else {}
                    if closes {
                        VStack{}.onAppear(){
                            print("종료")
                            player.close()
                            audioManager.close()
                        }
                    } else {}
                    if innertube.infoReady {
                        VStack{}.onAppear(){
                            getTubeInfo()
                        }
                    } else {}
                    
                    
                    //비디오 종료시 실향할 함수
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
                                        } else {}
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
                            } else {}
                        }
                    } else {}
                    
                    if isAppear {
                        VStack(spacing: 0){
                            //MARK: 영상 제목 뷰
                            Text(self.innertube.info?.videoDetails.title ?? "노래방")
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
                            //MARK: 비디오
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
                                //MARK: 건너뛰기 버튼
                                HStack{
                                    VStack{}
                                        .frame(width: 120, height: geometry.size.width*9/16)
                                        .background(.black.opacity(0.01))
                                        .onTapGesture(count: 2) {
                                            player.moveFrame(to: -10.0)
                                        }
                                        .DragVid(vidFull: $vidFull)
                                    Spacer()
                                    VStack{}
                                        .frame(width: 120, height: geometry.size.width*9/16)
                                        .background(.black.opacity(0.01))
                                        .onTapGesture(count: 2) {
                                            player.moveFrame(to: 10.0)
                                        }
                                        .DragVid(vidFull: $vidFull)
                                }
                                //.border(.green)
                                
                                //MARK: 비디오 조작 버튼
                                    if tap && vidFull{
                                        VStack{
                                            if !isLandscape{
                                                Spacer()
                                                    .frame(width: geometry.size.width, height: geometry.size.width*9/16 + 85)
                                            } else {}
                                            //비디오 상태 표시 줄
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
                                            
                                            //MARK: 음정 표시 뷰
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
                                                    } else {}
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
                                                        /*
                                                        Button {
                                                            player.changeVideo(url: self.lowVideoUrl!)
                                                        } label: {
                                                            Image(systemName: "swift")
                                                                .padding()
                                                                .tint(.white)
                                                                .background {
                                                                    Circle()
                                                                        .frame(width: 50, height: 50)
                                                                        .foregroundColor(.secondary)
                                                                }
                                                                .opacity(0.5)
                                                        }
                                                         */
                                                    }
                                                }
                                            } else {}
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
                                            } else {}
                                            HStack{
                                                Button {
                                                    if !isLandscape {
                                                        player.moveFrame(to: self.goBackTime * -1)
                                                    } else {}
                                                } label: {
                                                    if !isLandscape {
                                                        Image(systemName: "gobackward.\(Int(self.goBackTime))")
                                                            .resizable()
                                                            .scaledToFit()
                                                            .frame(height: 30)
                                                            .opacity(0.8)
                                                            .padding(.horizontal ,10)
                                                    } else {}
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
                                                                } else {}
                                                                let settings = [AVFormatIDKey: Int(kAudioFormatMPEG4AAC), AVSampleRateKey: 12000, AVNumberOfChannelsKey: 1, AVEncoderAudioQualityKey: AVAudioQuality.medium.rawValue]
                                                                self.recorder = try AVAudioRecorder(url: recordFile, settings: settings)
                                                                self.recorder.record()
                                                                self.record = true
                                                            }
                                                            catch {
                                                                print("setting recorder: ", error)
                                                            }
                                                        } else {}
                                                    } else {}
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
                                                    } else {}
                                                } label: {
                                                    if !isLandscape {
                                                        Image(systemName: "goforward.\(Int(self.goBackTime))")
                                                            .resizable()
                                                            .scaledToFit()
                                                            .frame(height: 30)
                                                            .opacity(0.8)
                                                            .padding(.horizontal ,10)
                                                    } else {}
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
                                                } else {
                                                    Spacer()
                                                        .frame(width: geometry.size.width, height: geometry.size.height*2/3)
                                                }
                                                HStack(spacing: 60){
                                                    Button {
                                                        self.tempo -= 0.02
                                                        player.tempo(spd: tempo)
                                                        audioManager.tempo(spd: tempo)
                                                    } label: {
                                                        HStack{
                                                            Text("템포")
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
                                                        Text("템포: x")
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
                                                            Text("템포")
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
                                                    } else {}
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
                                                    } else {}
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
                                                    } else {}
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
                                                    } else {}
                                                }
                                                .padding(.top, 20)
//                                                Spacer()
//                                                    .frame(height: 70)
                                            } else {}
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
                                        } else {}
                                    } else {}
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
                    } else {}
                    //MARK: - 처음 시작
                    if !isAppear{
                        if innertube.HLSManifest {
                            Text("지원되지 않는 형식 입니다.")
                        } else {
                            ProgressView()
                                .scaleEffect(1.5)
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                .frame(width: geometry.size.width, height: geometry.size.height)
                                .background(Color(red: 44/255, green: 54/255, blue: 51/255))
                                .onAppear() {
                                    //self.isReady = false
                                    if !isAppear {
                                        self.innertube.player(videoId: videoId)
                                        self.vidEnd = false
                                        if UIDevice.current.model == "iPad" {
                                            self.isiPad = true
                                        } else {}
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
                                        } else {}
                                    } else {}
                                }
                        }
                    } else {}
                }
                .onDisappear(){
                    close()
                }
            }
        }
    }*/
    var body: some View {
        ZStack{
            // 화면 크기 파악
            GeometryReader{ geometry in
                ZStack{
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
                    self.vidFull = true
                    //print(geometry.size.height)
                }
                .onChange(of: geometry.size) { _ in
                    self.scHeight = geometry.size.height
                    self.scWidth = geometry.size.width
                    print(geometry.size.height)
                    print(geometry.size.width)
                    
                }
                .onReceive(NotificationCenter.default.publisher(for: UIDevice.orientationDidChangeNotification), perform: { _ in
                    self.scHeight = 0
                    self.scWidth = 0
                })
            }
            
            .ignoresSafeArea(.all)
            .background(colorScheme == .dark ? Color(red: 0.13, green: 0.13, blue: 0.13) : Color(red: 0.9412, green: 0.9255, blue: 0.8980))
//            .background(Color(red: 0.9412, green: 0.9255, blue: 0.8980))
            .brightness(-0.02)
            VStack(spacing: 0.0){
                if scWidth < scHeight {
                    HStack{
                        Spacer()
                        Text(self.innertube.info?.videoDetails.title ?? "노래방")
                            .foregroundStyle(.orange)
                            .bold()
                            .padding()
                        Spacer()
                    }
                    //.background(.background)
                    .onTapGesture {
                        self.vidFull.toggle()
                    }
                }
                PlayerViewController(player: player.player ?? AVPlayer())
                    //.preferredColorScheme(colorScheme)
//                    .frame(
//                        height: scHeight > scWidth ? scWidth * 9 / 16 : scHeight
//                        
//                    )
                    //.opacity(0.0)
                    .border(Color.red)
                    .ignoresSafeArea(.container)
                if scWidth < scHeight {
                    
                    self.pitchView
                    HStack(spacing: 0){
                        Text("템포: x")
                        Text(String(format: "%.2f", self.tempo))
                    }
                    ZStack{
//                        LinearGradient(
//                            colors: !isPressed ? [.gray.opacity(0.2)] : [.red, .blue],
//                            startPoint: .bottomLeading,
//                            endPoint: .bottomTrailing
//                        )
                        AngularGradient(
                            gradient: Gradient(colors: tempoPressed || pitchPressed ? [.white, .red, .blue, .white] : [.white]),
                            center: .bottom,
                            angle: .degrees(90))
                        .mask{
                            Circle()
                                .stroke(lineWidth: 60)
                                .frame(width: scWidth*0.55)
                            //.brightness(0.3)
                                .shadow(radius: 8, y: 5)
                        }
                        .rotationEffect(.degrees(ringAngle))
                        .shadow(radius: 8, y: 5)
                        .frame(width: scWidth, height: scWidth*0.8)
                        //.border(Color.black)
                        RoundedRectangle(cornerRadius: 10)
                            .frame(width: 10, height: 70)
                            .foregroundStyle(.white)
                            .opacity(tempoPressed || pitchPressed ? 1.0 : 0.0)
                            .offset(y: scWidth * 0.55 / 2)
                            .rotationEffect(.degrees(ringAngle))
                            .gesture(
                                DragGesture()
                                    .onChanged({ dot in
                                        change(location: dot.location)
                                    })
                            )
                        ZStack{
                            Text("템포")
                                .frame(width: 80, height: 40, alignment: .center)
                                .offset(y: -scWidth * 0.55 / 2)
                                .foregroundStyle(tempoPressed ? .white : .gray)
                                .opacity(pitchPressed ? 0.0 : 1.0)
                                .gesture(
                                    DragGesture(minimumDistance: 0)
                                        .onChanged({ dot in
                                            tempoPressed = true
                                            change(location: dot.location)
                                        })
                                        .onEnded({ _ in
                                            tempoPressed = false
                                        })
                                )
                            
//                            Spacer()
//                                .frame(height: 160)
//                                .foregroundStyle(.foreground)
                            Text("음정")
                                .frame(width: 80, height: 40, alignment: .center)
                                .offset(y: scWidth * 0.55 / 2)
                                .foregroundStyle(pitchPressed ? .white : .gray)
                                .opacity(tempoPressed ? 0.0 : 1.0)
                                .gesture(
                                    DragGesture(minimumDistance: 0)
                                    .onChanged({ dot in
                                        pitchPressed = true
                                        change(location: dot.location)
                                    })
                                    .onEnded({ _ in
                                        pitchPressed = false
                                    })
                            )
                        }
                        Button{
                            audioManager.play()
                            player.plays()
                            
                        } label: {
                            ZStack{
                                Circle()
                                    .foregroundStyle(.white)
                                    .frame(height: 90)
                                    .shadow(radius: 8, y: 5)
                                Image(systemName: "play.fill")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(height: 40)
                                    .offset(x: 5)
                                    .foregroundStyle(.red)
                            }
//                            Image(systemName: player.isplaying ? "pause.circle.fill" : "play.circle.fill")
//                                .resizable()
//                                .scaledToFit()
//                                .frame(height: 90)
//                                .foregroundStyle(.red)
//                                .shadow(radius: 10)
                            //.border(.red)
                        }
                        .padding(.horizontal ,20)
                    }
                    Spacer()
                        .frame(height: 100)
                }
            }
        }
    }
}
//MARK: 뷰
extension VideoPlay {
    var pitchView: some View {
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
            Text(String(Int(self.tone)))
                .padding(10)
                .shadow(radius: 20)
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
            
        }.frame(width: self.scWidth)
    }
}

//MARK: 함수들
extension VideoPlay {
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
    
    func getTubeInfo() {
        let hd720 = self.innertube.info?.streamingData.formats?.filter{$0.qualityLabel ?? "" == "720p"}.last
        let hd360 = self.innertube.info?.streamingData.formats?.filter{$0.qualityLabel ?? "" == "360p"}.last
        var selectedVideo = TubeFormats(audioQuality: "")
        if resolution == .low || hd720 == nil {
            selectedVideo = hd360 ?? TubeFormats(audioQuality: "")
        } else {
            selectedVideo = hd720 ?? TubeFormats(audioQuality: "")
        }
        let audio = self.innertube.info?.streamingData.adaptiveFormats?.filter{$0.audioQuality == "AUDIO_QUALITY_MEDIUM"}.first
        self.downloadManager.createDownloadParts(url: URL(string: audio?.url ?? "http://www.youtube.com")!, size: Int(audio?.contentLength ?? "") ?? 0, video: false )
        player.prepareToPlay(url: URL(string: selectedVideo.url ?? "http://www.youtube.com")!, audioManager: audioManager, fileSize: Int(selectedVideo.contentLength ?? "") ?? 0, isOk: false)
        envPlayer.player = self.player
        envPlayer.isOn = true
        
    }
    func audioEngineSet() {
        let doc = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let fileUrl = doc.appendingPathComponent("audio.m4a")
        audioManager.setEngine(file: fileUrl, frequency: [32, 63, 125, 250, 500, 1000, 2000, 4000, 8000, 16000], tone: 0.0, views: "VideoPlay View audio engine set")
        self.isAppear = true
        self.isReady = true
        self.vidFull = true
    }
    private func change(location: CGPoint) {
        let vector = CGVector(dx: location.x - 40, dy: location.y - 20)
        //print("loca", location.x, location.y)
        let radian = atan2(vector.dy , vector.dx)
        var angle = radian * 180 / .pi - 90
        self.ringAngle = angle > 0 ? angle : angle + 360
        //print("ring", self.ringAngle)
        if pitchPressed {
            self.tones = Int(Float(ringAngle) / 30)
        } else if tempoPressed {
            self.tempos = Int(Float(ringAngle) / 30)
        }
    }
}

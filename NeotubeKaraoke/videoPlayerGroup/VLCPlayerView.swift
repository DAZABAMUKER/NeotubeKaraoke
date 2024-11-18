//
//  VLCPlayerView.swift
//  NeotubeKaraoke
//
//  Created by 안병욱 on 11/16/24.
//

import SwiftUI
import MobileVLCKit

struct VLCPlayerView: UIViewRepresentable {

    typealias UIViewType = UIView
    @AppStorage("moveFrameTime") var goBackTime: Double = 15.0 //UserDefaults.standard.double(forKey: "moveFrameTime")
    
    @Binding var url: URL? {
        didSet {
            if url != oldValue {
                guard let url = self.url else { return }
                player.media = VLCMedia(url: url)
                player.audio?.isMuted = true
                player.play()
            }
        }
    }
    var audioManager: AudioManager?
    @Binding var vidLength: Double
    @Binding var time: Double
    @Binding var end: Bool
    @Binding var isPlaying: Bool {
        didSet {
            plays()
        }
    }
    @Binding var tempo: Float {
        didSet {
            self.tempo(spd: tempo)
        }
    }
    @Binding var forawardOrRewind: String {
        didSet {
            if forawardOrRewind == "+" {
                moveFrame(to: Int32(self.goBackTime))
            } else if forawardOrRewind == "-" {
                moveFrame(to: Int32(-self.goBackTime))
            }
        }
    }
    @Binding var setTIme: Int32 {
        didSet {
            self.player.time = VLCTime(int: setTIme)
        }
    }
    //@Binding var spd: Float?
    @State var player: VLCMediaPlayer = VLCMediaPlayer()
    
    func makeUIView(context: Context) -> UIView {
        let view = UIView()
        player.drawable = view
        NotificationCenter.default.post(name: Notification.Name(rawValue: "time"), object: nil)
        NotificationCenter.default.post(name: Notification.Name(rawValue: "state"), object: nil)
//        self.player.removeObserver(self.player.time, forKeyPath: "timeObserver")
        //self.player.addObserver(self.player.time, forKeyPath: "timeObserver", options:[.old, .new] , context: nil)
        //player.audio?.isMuted = false
        NotificationCenter.default.addObserver(forName: Notification.Name(rawValue: "time"), object: self.player, queue: .main) { value in
//            if self.player.state != .playing {
//                return
//            } else {
            print(self.time)
                if self.vidLength < Double(truncating: player.media?.length.value ?? 0) {
                    self.time = Double(truncating: player.time.value ?? 0) / 2000
                } else {
                    self.time = Double(truncating: player.time.value ?? 0) / 1000
                }
//                if self.vidLength - time < 0.05 {
//                    self.player.pause()
//                    self.end = true
//                }
                
//            }
        }
        
        NotificationCenter.default.addObserver(forName: Notification.Name(rawValue: "state"), object: self.player, queue: .main) { value in
            if self.player.state == .opening {
                //print("플레이 기다리는 중")
            } else if self.player.state == .playing {
                audioManager?.controlFrame(jump: self.time)
            } else {
                
            }
        }
        
        
        
        
        return view
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {
        guard let url = self.url else { return }
        player.media = VLCMedia(url: url)
        player.audio?.isMuted = true
        player.play()
        print(player.time)
        
        //guard let spd = self.spd else { return }
//        guard let path = Bundle.main.url(forResource: "videoplayback", withExtension: "mp4") else {
//            print("Failed!!!!!")
//            return
//        }
        //player.media = VLCMedia(url: path)
        //player.audio?.isMuted = false
        

    }
    
    func tempo(spd: Float) {
        player.rate = spd
    }
    
    func moveFrame(to: Int32 = 15, spd: Float = 1.0) {
        //let jump: Double = CMTimeGetSeconds( (self.player?.currentItem?.currentTime())!)
        //self.audiomanager?.controlFrame(jump: jump + 15)
        player.pause()
        if to > 0 {
            player.jumpForward(to)
        } else {
            player.jumpBackward(to)
        }
        player.play()
        tempo(spd: spd)
        
        //player.time = VLCTime(int: Int32(to)) + player.time
        
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator()
    }
    
    func plays() {
        if self.player.state == .playing {
            player.pause()
        } else {
            player.play()
        }
    }
    
    class Coordinator: NSObject {
        override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
            if keyPath == "timeObserver", let change = change, let newValue = change[NSKeyValueChangeKey.newKey] as? Int {
                
            }
        }
    }
    
}


//
//  vlcselfController.swift
//  NeotubeKaraoke
//
//  Created by 안병욱 on 11/17/24.
//

import SwiftUI
import MobileVLCKit

class vlcPlayerController: VLCMediaPlayer, ObservableObject {
    //@Published var player: VLCMediaPlayer?
    var audioManager: AudioManager?
    @Published var currentTIme: Double = 0.0
    @Published var vidEnd: Bool = false
    @Published var length: Double = 0.0
    
    func loadVideo(url: URL?, vidLength: Double, audioManager: AudioManager) {
        guard let url = url else { return }
        self.audioManager = audioManager
        self.media = VLCMedia(url: url)
        print(self.state == .playing ? "playing" : "not playing")
        self.audio?.isMuted = true
        if vidLength < Double(truncating: self.media?.length.value ?? 0) {
            self.length = Double(truncating: self.media?.length.value ?? 0) / 2000
        } else {
            self.length = Double(truncating: self.media?.length.value ?? 0) / 1000
        }
        self.addObserver(self, forKeyPath: "time",options: [.old, .new], context: nil)
        self.addObserver(self, forKeyPath: "state",options: [.old, .new], context: nil)
        //NotificationCenter.default.post(name: Notification.Name(rawValue: "timeObserver"), object: self)
        //NotificationCenter.default.post(name: Notification.Name(rawValue: "vlccState"), object: self)
        self.plays()
    }
    
    func tempo(spd: Float) {
        self.rate = spd
    }
    
    func moveFrame(to: Int32 = 15, spd: Float = 1.0) {
        //let jump: Double = CMTimeGetSeconds( (self.player?.currentItem?.currentTime())!)
        //self.audiomanager?.controlFrame(jump: jump + 15)
        self.pause()
        if to > 0 {
            self.jumpForward(to)
        } else {
            self.jumpBackward(to)
        }
        self.play()
        tempo(spd: spd)
        
        //self.time = VLCTime(int: Int32(to)) + self.time
        
    }
    
    func plays() {
//        self.play()
//        print(self.state.rawValue)
//        self.pause()
//        print(self.state.rawValue)
//        self.stop()
//        print(self.state.rawValue)
        if self.state == .buffering {
            print("buffer(2)\(self.state.rawValue)")
            self.play()
        } else if self.state == .ended {
            print("ended\(self.state.rawValue)")
        } else if self.state == .error {
            print("error\(self.state.rawValue)")
        } else if self.state == .esAdded {
            print("add(7)\(self.state.rawValue)")
        } else if self.state == .opening {
            print("open(1)\(self.state.rawValue)")
        } else if self.state == .paused {
            self.play()
            print("pause(6)\(self.state.rawValue)")
        } else if self.state == .playing {
            self.pause()
            print("play(5)\(self.state.rawValue)")
        } else if self.state == .stopped {
            print("stop(0)\(self.state.rawValue)")
            self.play()
        } else if self.state == .none {
            print("none\(self.state.rawValue)")
        }
        
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "time" {
            print(Double(truncating: self.time.value ?? 0)/2000)
            if self.length < Double(truncating: self.media!.length.value ?? 0) {
                        self.currentTIme = Double(truncating: self.time.value ?? 0) / 2000
                    } else {
                        self.currentTIme = Double(truncating: self.time.value ?? 0) / 1000
                    }
//                    if self.length - self.currentTIme < 0.05 {
//                        self.pause()
//                        self.vidEnd = true
//                    }
                
                
            
        }
        if keyPath == "state", let change = change, let newValue = change[NSKeyValueChangeKey.newKey] as? Int , let oldValue = change[NSKeyValueChangeKey.oldKey] as? Int {
            if oldValue == 5 {
                self.pause()
            }
            if self.state == .buffering {
                print("플레이 기다리는 중")
            } else if self.state == .playing {
                self.audioManager?.controlFrame(jump: self.currentTIme)
                print("playyyyy")
                self.play()
            } else if self.state == .paused {
                //self.audioManager?.controlFrame(jump: self.currentTIme)
                self.currentTIme = Double(truncating: self.time.value ?? 0) / 1000
                print("pauseeeee")
                self.pause()
            } else if self.state == .opening {
                print("open\(self.state.rawValue)")
            } else {
                print("QWER\(self.state.rawValue)")
                print(self.state.rawValue)
            }
            if self.state == .buffering {
                print("buffer(2)\(self.state.rawValue)")
            } else if self.state == .ended {
                print("ended\(self.state.rawValue)")
            } else if self.state == .error {
                print("error\(self.state.rawValue)")
            } else if self.state == .esAdded {
                print("add\(self.state.rawValue)")
            } else if self.state == .opening {
                print("open\(self.state.rawValue)")
            } else if self.state == .paused {
                print("pause(6)\(self.state.rawValue)")
            } else if self.state == .playing {
                print("play(5)\(self.state.rawValue)")
            } else if self.state == .stopped {
                print("stop(0)\(self.state.rawValue)")
            } else if self.state == .none {
                print("none\(self.state.rawValue)")
            }
        }
    }
}


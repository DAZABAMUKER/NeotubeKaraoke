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
    @Published var vidState: VLCMediaPlayerState? = nil
    @Published var ready: Bool = false
    
    
    
    func loadVideo(url: URL?, vidLength: Double, audioManager: AudioManager) {
        self.stop()
        guard let url = url else { return }
        self.audioManager = audioManager
        self.media = VLCMedia(url: url)
        print(self.state == .playing ? "playing" : "not playing")
        self.audio?.isMuted = true
        self.length = vidLength
        self.addObserver(self, forKeyPath: "time",options: [.old, .new], context: nil)
        self.addObserver(self, forKeyPath: "state",options: [.old, .new], context: nil)
        //NotificationCenter.default.post(name: Notification.Name(rawValue: "timeObserver"), object: self)
        //NotificationCenter.default.post(name: Notification.Name(rawValue: "vlccState"), object: self)
        self.play()
        
    }
    
    func tempo(spd: Float) {
        self.rate = spd
    }
    
    func moveFrame(to: Int32 = 15, spd: Float = 1.0) {
        //let jump: Double = CMTimeGetSeconds( (self.player?.currentItem?.currentTime())!)
        //self.audiomanager?.controlFrame(jump: jump + 15)
        print(to)
        self.pause()
        if to > 0 {
            self.jumpForward(2*to)
        } else {
            self.jumpBackward(-2*to)
        }
        self.play()
        tempo(spd: spd)
        
        //self.time = VLCTime(int: Int32(to)) + self.time
        
    }
    
    func progressSlider(to: Int32) {
        self.time = VLCTime(int: to)
    }
    
    func plays() {
        if self.isPlaying {
            self.pause()
        } else {
            self.play()
        }
//        self.play()
//        print(self.state.rawValue)
//        self.pause()
//        print(self.state.rawValue)
//        self.stop()
//        print(self.state.rawValue)
//        if self.state == .buffering {
//            print("Button-buffer(2)\(self.state.rawValue)")
//            //self.play()
//        } else if self.state == .ended {
//            print("Button-ended(3)\(self.state.rawValue)")
//        } else if self.state == .error {
//            print("Button-error\(self.state.rawValue)")
//        } else if self.state == .esAdded {
//            print("Button-add(7)\(self.state.rawValue)")
//        } else if self.state == .opening {
//            print("Button-open(1)\(self.state.rawValue)")
//        } else if self.state == .paused {
//            self.play()
//            print("Button-pause(6)\(self.state.rawValue)")
//        } else if self.state == .playing {
//            self.pause()
//            print("Button-play(5)\(self.state.rawValue)")
//        } else if self.state == .stopped {
//            print("Button-stop(0)\(self.state.rawValue)")
//            //self.play()
//        } else if self.state == .none {
//            print("Button-none\(self.state.rawValue)")
//        }
        
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "time" {
            self.vidState = .playing
            if !ready {
                
                if self.audioManager?.ready ?? false {
                    self.play()
                    self.ready = true
                    self.audioManager?.play()
                    self.rate = 1.0
                } else {
                    self.rate = 0.001
                }
            }
            //print(Double(truncating: self.time.value ?? 0)/2000)
            if self.length * 1.1 < Double(truncating: self.media?.length.value ?? 0)/1000 {
                self.currentTIme = Double(truncating: self.time.value ?? 0) / 2000
            } else {
                self.currentTIme = Double(truncating: self.time.value ?? 0) / 1000
            }
            if self.audioManager?.ready ?? false && (self.length - currentTIme > 5.0) {
                self.audioManager?.checkVidTime(vidTime: currentTIme)
            }
            
            
            //print("차이: ",self.length, self.currentTIme)
//            if (self.length - self.currentTIme < 0.05) && self.state == .playing {
//                        self.pause()
//                        self.vidEnd = true
//                    }
                
                
            
        }
        if keyPath == "state", let change = change, let newValue = change[NSKeyValueChangeKey.newKey] as? Int , let oldValue = change[NSKeyValueChangeKey.oldKey] as? Int {
            if oldValue == 5 {
                self.length = Double(truncating: self.media?.length.value ?? 0)/1000
                
                //self.pause()
                //self.audioManager?.pause()
                
                //self.pause()
                //self.audioManager?.pause()
            }
            if self.state == .buffering {
                print("플레이 기다리는 중")
                self.ready = false
                self.audioManager?.pause()
                self.vidState = .buffering
                //self.play()
                //self.audioManager?.play()
            } else if self.state == .playing {
                if self.length * 1.1 < Double(truncating: self.media?.length.value ?? 0)/1000 {
                    self.currentTIme = Double(truncating: self.time.value ?? 0) / 2000
                } else {
                    self.currentTIme = Double(truncating: self.time.value ?? 0) / 1000
                }
                self.audioManager?.controlFrame(jump: self.currentTIme)
                print("playyyyy")
                self.play()
            } else if self.state == .paused {
                //self.audioManager?.controlFrame(jump: self.currentTIme)
                self.currentTIme = Double(truncating: self.time.value ?? 0) / 1000
                self.audioManager?.pause()
                self.vidState = .paused
                print("pauseeeee")
                //self.pause()
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
                print("동영상 완전히 끝")
                self.audioManager?.close()
                self.stop()
                self.vidState = .ended
                self.vidEnd = true
                self.ready = false
                self.removeObserver(self, forKeyPath: "time")
                self.removeObserver(self, forKeyPath: "state")
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
                print("동영상 stop")
            } else if self.state == .none {
                print("none\(self.state.rawValue)")
            }
        }
    }
}


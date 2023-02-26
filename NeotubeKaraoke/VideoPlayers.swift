//
//  VideoPlayer.swift
//  NeotubeKaraoke
//
//  Created by 안병욱 on 2023/02/16.
//

import Foundation
import SwiftUI
import AVKit

class VideoPlayers: AVPlayer, ObservableObject {
    
    @Published var player: AVPlayer?
    @Published var currents: Double = 0.0
    @Published var progress = true
    @Published var end = false
    var currrnts: Double {
        let jump: Double = CMTimeGetSeconds( (self.player?.currentItem?.currentTime())!)
        return jump
    }
    var audiomanager: AudioManager?
    
    func plays(){
        if self.player?.timeControlStatus == .playing {
            self.player?.pause()
        } else {
            self.player?.play()
        }
    }
    
    func moveFrame(to: Double) {
        player?.seek(to: CMTime(seconds: to, preferredTimescale: 1) + (player?.currentTime())!)
    }
    
    func prepareToPlay(url: URL,  audioManager: AudioManager) {
        self.audiomanager = audioManager
        self.player?.removeObserver(self, forKeyPath: "timeControlStatus")
        let controller = AVPlayerViewController()
        controller.player = player
        controller.showsPlaybackControls = false
        
        //controller.modal
        self.player = AVPlayer(url: url)
        self.player?.addObserver(self, forKeyPath: "timeControlStatus",options: [.old, .new], context: nil)
        self.player?.addPeriodicTimeObserver(forInterval: CMTime(seconds: 1, preferredTimescale: 1), queue: .global(qos: .background), using: { _ in
            if self.player?.timeControlStatus == .playing {
                let jump: Double = CMTimeGetSeconds( (self.player?.currentItem?.currentTime())!)
                DispatchQueue.main.async {
                    self.currents = jump
                }
                if CMTimeGetSeconds( (self.player?.currentItem!.duration)!)/2 - jump < 1 {
                    self.player?.pause()
                    DispatchQueue.main.async {
                        self.end = true
                    }
                } else {
                    DispatchQueue.main.async {
                        self.end = false
                    }
                }
                self.audiomanager?.checkVidTime(vidTime: jump)
            }
        })
        
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "timeControlStatus", let change = change, let newValue = change[NSKeyValueChangeKey.newKey] as? Int, let oldValue = change[NSKeyValueChangeKey.oldKey] as? Int {
            let oldStatus = AVPlayer.TimeControlStatus(rawValue: oldValue)
            let newStatus = AVPlayer.TimeControlStatus(rawValue: newValue)
            if newStatus == .waitingToPlayAtSpecifiedRate {
                audiomanager?.pause()
                
                DispatchQueue.main.async {
                    print("플레이 기다리는 중")
                    self.progress = true
                }
                
            } else if newStatus == .playing {
                let jump: Double = CMTimeGetSeconds( (self.player?.currentItem?.currentTime())!)
                print("플레잉",CMTimeGetSeconds( (player?.currentItem!.duration)!))
                audiomanager?.controlFrame(jump: jump)
                DispatchQueue.main.async {
                    self.progress = false
                }
            }
        }
    }
}



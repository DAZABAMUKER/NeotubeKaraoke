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
    @Published var progress: Bool = true 
    @Published var end = false
    @Published var isAppears = false
    @Published var isplaying = false
    
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
    
    func close() {
        self.player?.pause()
    }
    
    func moveFrame(to: Double) {
        player?.seek(to: CMTime(seconds: to, preferredTimescale: 1) + (player?.currentTime())!)
        player?.play()
    }
    
    func progressSlider(to: Double) {
        player?.seek(to: CMTime(seconds: to, preferredTimescale: 1))
        player?.play()
    }
    
    func prepareToPlay(url: URL,  audioManager: AudioManager, fileSize: Int64) {
        self.audiomanager = audioManager
        self.player?.removeObserver(self, forKeyPath: "timeControlStatus")
        self.player?.removeObserver(self, forKeyPath: "status")
        let controller = AVPlayerViewController()
        controller.player = player
        controller.showsPlaybackControls = false
        
        //controller.modal
        //let vidAsset = AVURLAsset(url: url)
        //let vidAssetItem = AVPlayerItem(asset: vidAsset)
        
        //downloadVidonlyFile(url: url, fileSize: fileSize)
        self.player = AVPlayer(url: url)
        self.player?.isMuted = true
        self.player?.addObserver(self, forKeyPath: "timeControlStatus",options: [.old, .new], context: nil)
        self.player?.currentItem?.addObserver(self, forKeyPath: "status", options: .new, context: nil)
        self.player?.addPeriodicTimeObserver(forInterval: CMTime(seconds: 1, preferredTimescale: 1), queue: .global(qos: .background), using: { _ in
            if self.player?.timeControlStatus == .playing {
                let jump: Double = CMTimeGetSeconds( (self.player?.currentItem?.currentTime())!)
                DispatchQueue.main.async {
                    self.currents = jump
                }
                if CMTimeGetSeconds( (self.player?.currentItem!.duration)!)/*/2*/ - jump < 1 {
                    self.player?.pause()
                    DispatchQueue.main.async {
                        self.end = true
                    }
                } else {
//                    DispatchQueue.main.async {
//                        self.end = false
//                    }
                }
                self.audiomanager?.checkVidTime(vidTime: jump)
            }
        })
        
    }
    /*
    func downloadVidonlyFile(url: URL, fileSize: Int64) {
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.allHTTPHeaderFields?["Range"] = "bytes=0-\(fileSize)"
        let task: URLSessionDownloadTask = URLSession(configuration: .default).downloadTask(with: request) { tempUrl, urlResponse, error in
            
            do {
                let doc = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
                let fileUrl = doc.appendingPathComponent("video.mp4")
                if FileManager.default.fileExists(atPath: fileUrl.path()) {
                    try FileManager.default.removeItem(at: fileUrl)
                }
                try FileManager.default.copyItem(at: tempUrl!, to: fileUrl)
                DispatchQueue.main.async {
                    self.player = AVPlayer(url: fileUrl)
                    self.isAppears = true
                }
            }
            catch {
                
            }
        }
        task.priority = URLSessionTask.highPriority
        task.resume()
    }
    */
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "timeControlStatus", let change = change, let newValue = change[NSKeyValueChangeKey.newKey] as? Int, let oldValue = change[NSKeyValueChangeKey.oldKey] as? Int {
            
            let oldStatus = AVPlayer.TimeControlStatus(rawValue: oldValue)
            let newStatus = AVPlayer.TimeControlStatus(rawValue: newValue)
            
            if newStatus == .waitingToPlayAtSpecifiedRate {
                audiomanager?.pause()
                
                DispatchQueue.main.async {
                    print("플레이 기다리는 중")
                    self.progress = true
                    self.isplaying = false
                }
                
            } else if newStatus == .playing {
                let jump: Double = CMTimeGetSeconds( (self.player?.currentItem?.currentTime())!)
                print("플레잉",CMTimeGetSeconds( (player?.currentItem!.duration)!))
                audiomanager?.controlFrame(jump: jump)
                DispatchQueue.main.async {
                    self.progress = false
                    self.isplaying = true
                }
            } else {
                DispatchQueue.main.async {
                    self.isplaying = false
                }
            }
        }
        if keyPath == "status", let change = change, let newVal = change[NSKeyValueChangeKey.newKey] as? Int {
            if newVal == 1 {
                DispatchQueue.main.async {
                    self.progress = false
                }
            }
        }
    }
}



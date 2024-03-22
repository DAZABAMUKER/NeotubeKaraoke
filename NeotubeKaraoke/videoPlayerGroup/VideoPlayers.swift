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
    @Published var intervals = 0.0
    private var timeObserver: Any?
    var vidSync = 0.0
    
    var currrnts: Double {
        let jump: Double = CMTimeGetSeconds( (self.player?.currentItem?.currentTime())!)
        return jump
    }
    var audiomanager: AudioManager?
    
    func plays(){
        if self.player?.timeControlStatus == .playing {
            self.player?.pause()
            self.isplaying = false
        } else {
            self.player?.play()
            self.isplaying = true
            if audiomanager?.audioEngine.isRunning == false {
                audiomanager?.reconnect(vidTime: self.currents)
            }
        }
    }
    
    func close() {
        self.player = AVPlayer()
        self.player?.pause()
        self.audiomanager?.pause()
        self.isplaying = false
    }
    
    func moveFrame(to: Double = 15, spd: Float) {
        //let jump: Double = CMTimeGetSeconds( (self.player?.currentItem?.currentTime())!)
        //self.audiomanager?.controlFrame(jump: jump + 15)
        player?.pause()
        player?.seek(to: CMTime(seconds: to, preferredTimescale: 1) + (player?.currentTime())!)
        player?.play()
        tempo(spd: spd)
    }
    
    func progressSlider(to: Double) {
        player?.pause()
        player?.seek(to: CMTime(seconds: to, preferredTimescale: 1))
        player?.play()
    }
    
    func tempo(spd: Float) {
        player?.rate = spd
    }
    
//    func changeVideo(url: URL) {
//        let item = AVPlayerItem(url: url)
//        let cTime = player?.currentTime()
//        self.player?.replaceCurrentItem(with: item)
//        self.player?.seek(to: cTime!)
//    }
//    
    func prepareToPlay(url: URL,  audioManager: AudioManager, fileSize: Int, isOk: Bool) {
        self.audiomanager = audioManager
        //self.player?.removeObserver(self, forKeyPath: "timeControlStatus")
        //self.player?.removeObserver(self, forKeyPath: "status")
        let controller = AVPlayerViewController()
        controller.player = player
        controller.showsPlaybackControls = false
        
        //controller.modal
        //let vidAsset = AVURLAsset(url: url)
        //let vidAssetItem = AVPlayerItem(asset: vidAsset)
        
        //downloadVidonlyFile(url: url, fileSize: fileSize)
        let asset = AVAsset(url: url)
        let item = AVPlayerItem(asset: asset)
        self.player = AVPlayer(playerItem: item)
        self.player?.isMuted = true
        self.player?.currentItem?.audioTimePitchAlgorithm  = AVAudioTimePitchAlgorithm.spectral
        self.player?.usesExternalPlaybackWhileExternalScreenIsActive = true
//        NotificationCenter.default.addObserver(forName: Notification.Name.AVAudioEngineConfigurationChange, object: nil, queue: nil) { notification in
//            audioManager.reconnect(vidTime: self.currents)
//            print("reconnect")
//            //self.player?.pause()
//        }
        self.player?.addObserver(self, forKeyPath: "timeControlStatus",options: [.old, .new], context: nil)
        //self.player?.currentItem?.addObserver(self, forKeyPath: "status", options: .new, context: nil)
        timeObserver =  self.player?.addPeriodicTimeObserver(forInterval: CMTime(seconds: 1, preferredTimescale: 2), queue: .global(qos: .background), using: { _ in
            if !self.isplaying {
                //self.audiomanager?.pause()
                return
            }
            if self.player?.timeControlStatus == .playing {
                let jump: Double = CMTimeGetSeconds( (self.player?.currentItem?.currentTime()) ?? CMTime.zero)
                DispatchQueue.main.async {
                    self.currents = jump
                    self.intervals = CMTimeGetSeconds((self.player?.currentItem?.duration) ?? CMTime.zero)
                    self.player?.isMuted = true
                    if isOk {
                        self.intervals = self.intervals/2
                    }
                    if self.intervals - jump < 0.1 {
                        self.player?.pause()
                        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1) {
                                self.end = true
                            guard let timeObserver = self.timeObserver else { return }
                            
                            self.player?.removeTimeObserver(timeObserver)
                            self.timeObserver = nil
                                //self.player?.removeObserver(self, forKeyPath: "status")
                                return
                        }
                    } else {
                        //                    DispatchQueue.main.async {
                        //                        self.end = false
                        //                    }
                    }
                    //self.audiomanager?.checkVidTime(vidTime: jump)
                }
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
        if keyPath == "timeControlStatus", let change = change, let newValue = change[NSKeyValueChangeKey.newKey] as? Int /*, let oldValue = change[NSKeyValueChangeKey.oldKey] as? Int*/ {
            
            //let oldStatus = AVPlayer.TimeControlStatus(rawValue: oldValue)
            let newStatus = AVPlayer.TimeControlStatus(rawValue: newValue)
            
            if newStatus == .waitingToPlayAtSpecifiedRate {
                if audiomanager?.audioEngine.isRunning == true {
                    audiomanager?.pause()
                }
                DispatchQueue.main.async {
                    print("플레이 기다리는 중")
                    self.progress = true
                    self.isplaying = false
                }
                
            } else if newStatus == .playing {
                let jump: Double = CMTimeGetSeconds( (self.player?.currentItem?.currentTime())!)
                //print("플레잉",CMTimeGetSeconds( (player?.currentItem!.duration)!))
                print("플레잉", jump)
                audiomanager?.controlFrame(jump: jump)
                DispatchQueue.main.async {
                    self.progress = false
                    self.isplaying = true
                }
            } else {
                DispatchQueue.main.async {
                    self.isplaying = false
                    //self.audiomanager?.pause()
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



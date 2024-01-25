//
//  AudioManager.swift
//  NeotubeKaraoke
//
//  Created by 안병욱 on 2023/02/13.
//

import Foundation
import AVFoundation

class AudioManager: ObservableObject {
    
    var vidSync = 0.0
    let playerNode = AVAudioPlayerNode()
    let clapNode = AVAudioPlayerNode()
    let crowdNode = AVAudioPlayerNode()
    let audioEngine = AVAudioEngine()
    var pitchNode: AVAudioUnitTimePitch!
    var EQNode: AVAudioUnitEQ!
    var audioFileBuffer: AVAudioPCMBuffer!
    var audioFile: AVAudioFile!
    var clap: AVAudioFile!
    var crowd: AVAudioFile!
    var audioFileLength: AVAudioFramePosition = 0
    var offsetFrame: Double = 0
    var intervalLimit: Double = 0.1
    var currentFrame: AVAudioFramePosition {
        guard
            let lastRenderTime = playerNode.lastRenderTime,
            let playerTime = playerNode.playerTime(forNodeTime: lastRenderTime)
        else {
            return 0
        }
        //print("매니저",Double(playerTime.sampleTime)/44100.0)
        
        return playerTime.sampleTime
    }
    var jumpFrame: AVAudioFramePosition = 0
    
    init(file: URL, frequency: [Int], tone: Float, views: String){
        setEngine(file: file, frequency: frequency, tone: tone, views: views)
    }
    
    
    
    init(){
        //setEngine(file: Bundle.main.url(forResource: "clap", withExtension: "wav")!, frequency: [32, 63, 125, 250, 500, 1000, 2000, 4000, 8000, 16000], tone: 0.0)
    }
//    
//    deinit{
//        print("deinit")
//    }
//    
    func close() {
        playerNode.pause()
        playerNode.stop()
        audioEngine.stop()
    }
    
    func play(){
        if playerNode.isPlaying {
            playerNode.pause()
        } else {
            playerNode.play()
        }
    }
    func pause() {
        playerNode.pause()
    }
    
    func pitchChange(tone: Float){
        pitchNode.pitch = tone * 100
    }
    
    func tempo(spd: Float) {
        pitchNode.rate = spd
    }
    
    func reconnect(vidTime: Double) {
        audioEngine.reset()
        print("reconnected")
        self.intervalLimit = 0.2
        self.playerNode.pause()
        self.playerNode.stop()
        self.audioEngine.pause()
        self.audioEngine.stop()
        let mixer = audioEngine.mainMixerNode
        audioEngine.connect(crowdNode, to: mixer, format: mixer.outputFormat(forBus: 0))
        audioEngine.connect(clapNode, to: mixer, format: mixer.outputFormat(forBus: 0))
        audioEngine.connect(playerNode, to: pitchNode, format: mixer.outputFormat(forBus: 0))
        audioEngine.connect(pitchNode, to: EQNode, format: mixer.outputFormat(forBus: 0))
        audioEngine.connect(EQNode, to: mixer, format: mixer.outputFormat(forBus: 0))
        audioEngine.connect(mixer, to: audioEngine.outputNode, format: mixer.outputFormat(forBus: 0))
        audioEngine.prepare()
        do {
            try audioEngine.start()
        } catch {
            assertionFailure("failed to audioEngine start. Error: \(error)")
        }
        //controlFrame(jump: vidTime)
    }
        
    
    func setEngine(file: URL, frequency: [Int], tone: Float, views: String) {
        do {
            audioEngine.reset()
            try AVAudioSession.sharedInstance().setCategory(.playback)
            print("실행중")
            /*guard let musicUrl = Bundle.main.url(forResource: "sample", withExtension: "mp3") else {
                print(" 파일 안나오잖아")
                return
            }*/
            let clapSound = Bundle.main.url(forResource: "clap", withExtension: "wav")
            let crowdSound = Bundle.main.url(forResource: "crowd", withExtension: "wav")
            self.audioFile = try AVAudioFile(forReading: file)
            self.clap = try AVAudioFile(forReading: clapSound!)
            self.crowd = try AVAudioFile(forReading: crowdSound!)
            offsetFrame = 0
            //audioFileBuffer = AVAudioPCMBuffer(pcmFormat: audioFile.processingFormat, frameCapacity: UInt32(audioFile.length))
            //try audioFile.read(into: audioFileBuffer)
        }
        catch{
            print("오류남")
            print(error)
            return
        }
        
        audioFileLength = audioFile.length 
        print(views)
        print("오디오 파일 길이",audioFileLength/44100)
        pitchNode = AVAudioUnitTimePitch()
        pitchNode.overlap = 3.0
        pitchNode.pitch = tone * 100
        //pitchNode.rate = 1.0
        
        EQNode = AVAudioUnitEQ(numberOfBands: frequency.count)
        EQNode.globalGain = 1
        for i in 0...(EQNode.bands.count-1) {
            EQNode.bands[i].frequency  = Float(frequency[i])
            EQNode.bands[i].gain       = 0
            EQNode.bands[i].bypass     = false
            EQNode.bands[i].filterType = .parametric
        }
        
        
        audioEngine.attach(EQNode)
        audioEngine.attach(playerNode)
        audioEngine.attach(pitchNode)
        audioEngine.attach(clapNode)
        audioEngine.attach(crowdNode)
        
        let mixer = audioEngine.mainMixerNode
        audioEngine.connect(crowdNode, to: mixer, format: mixer.outputFormat(forBus: 0))
        audioEngine.connect(clapNode, to: mixer, format: mixer.outputFormat(forBus: 0))
        audioEngine.connect(playerNode, to: pitchNode, format: mixer.outputFormat(forBus: 0))
        audioEngine.connect(pitchNode, to: EQNode, format: mixer.outputFormat(forBus: 0))
        audioEngine.connect(EQNode, to: mixer, format: mixer.outputFormat(forBus: 0))
        audioEngine.connect(mixer, to: audioEngine.outputNode, format: audioEngine.outputNode.outputFormat(forBus: 0))
        playerNode.scheduleFile(audioFile, at: nil, completionHandler: nil)
        audioEngine.prepare()
        do {
            try audioEngine.start()
        } catch {
            assertionFailure("failed to audioEngine start. Error: \(error)")
        }
        //print("제발 되라")
    }
    
    public func controlFrame(jump: Double) {
        print("오디오",jump)
        playerNode.pause()
        let jump = jump + self.vidSync
        guard let audioFile = audioFile else { print("오디오 파일 에러"); return }
        let frameLocaition = AVAudioFramePosition(jump * audioFile.processingFormat.sampleRate)
        //jumpFrame = currentFrame + frameLocaition
        jumpFrame = frameLocaition
        jumpFrame = max(jumpFrame, 0)
        jumpFrame = min(jumpFrame, audioFileLength)
        offsetFrame = jump
        playerNode.stop()
        
        var numberFrames = AVAudioFrameCount(audioFileLength - jumpFrame)
        if !(numberFrames > 0) {
            numberFrames =  1
        }
        playerNode.scheduleSegment(audioFile, startingFrame: jumpFrame, frameCount: numberFrames, at: nil) {
            print("did well")
        }
        
        playerNode.play()
        print("played")
    }
    
    func playClap() {
        //clapNode.stop()
        clapNode.scheduleFile(clap, at: nil, completionHandler: nil)
        clapNode.play()
    }
    
    func playCrowd() {
        //clapNode.stop()
        crowdNode.scheduleFile(crowd, at: nil, completionHandler: nil)
        crowdNode.play()
    }
    
    public func checkVidTime(vidTime: Double) {
        let audiTime = offsetFrame + Double(currentFrame)/44100.0
        var interval = audiTime - vidTime - self.vidSync
        //print(interval)
        if interval < 0 {
            interval *= -1
        }
        if Double(audioFileLength / 44100) - audiTime < 1 {
            playerNode.stop()
            //audioEngine.stop()
        }
        //print("체크",vidTime, audiTime, interval)
        if interval > self.intervalLimit {
            playerNode.pause()
            controlFrame(jump: vidTime)
        }
    }
}

//
//  AudioManager.swift
//  NeotubeKaraoke
//
//  Created by 안병욱 on 2023/02/13.
//

import Foundation
import AVFoundation

class AudioManager: ObservableObject {
    
    let playerNode = AVAudioPlayerNode()
    let audioEngine = AVAudioEngine()
    var pitchNode: AVAudioUnitTimePitch!
    var EQNode: AVAudioUnitEQ!
    var audioFileBuffer: AVAudioPCMBuffer!
    var audioFile: AVAudioFile!
    var audioFileLength: AVAudioFramePosition = 0
    var offsetFrame: Double = 0
    var currentFrame: AVAudioFramePosition {
        guard
            let lastRenderTime = playerNode.lastRenderTime,
            let playerTime = playerNode.playerTime(forNodeTime: lastRenderTime)
        else {
            return 0
        }
        print("매니저",Double(playerTime.sampleTime)/44100.0)
        
        return playerTime.sampleTime
    }
    var jumpFrame: AVAudioFramePosition = 0
    
    init(file: URL, frequency: [Int], tone: Float){
        setEngine(file: file, frequency: frequency, tone: tone)
    }
    
    init(){
        
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
    
    func setEngine(file: URL, frequency: [Int], tone: Float) {
        do {
            print("실행중")
            /*guard let musicUrl = Bundle.main.url(forResource: "sample", withExtension: "mp3") else {
                print(" 파일 안나오잖아")
                return
            }*/
            self.audioFile = try AVAudioFile(forReading: file)
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
        
        let mixer = audioEngine.mainMixerNode
        audioEngine.connect(playerNode, to: pitchNode, format: mixer.outputFormat(forBus: 0))
        audioEngine.connect(pitchNode, to: EQNode, format: mixer.outputFormat(forBus: 0))
        audioEngine.connect(EQNode, to: mixer, format: mixer.outputFormat(forBus: 0))
        playerNode.scheduleFile(audioFile, at: nil, completionHandler: nil)
        audioEngine.prepare()
        do {
            try audioEngine.start()
        } catch {
            assertionFailure("failed to audioEngine start. Error: \(error)")
        }
        print("제발 되라")
    }
    
    public func controlFrame(jump: Double) {
        print(jump)
        guard let audioFile = audioFile else { print("오디오 파일 에러"); return }
        let frameLocaition = AVAudioFramePosition(jump * audioFile.processingFormat.sampleRate)
        //jumpFrame = currentFrame + frameLocaition
        jumpFrame = frameLocaition
        jumpFrame = max(jumpFrame, 0)
        jumpFrame = min(jumpFrame, audioFileLength)
        offsetFrame = jump
        playerNode.stop()
        
        let numberFrames = AVAudioFrameCount(audioFileLength - jumpFrame)
        playerNode.scheduleSegment(audioFile, startingFrame: jumpFrame, frameCount: numberFrames, at: nil)
        
        playerNode.play()
    }
    
    public func checkVidTime(vidTime: Double) {
        let audiTime = offsetFrame + Double(currentFrame)/44100.0
        var interval = audiTime - vidTime
        if interval < 0 {
            interval *= -1
        }
        if Double(audioFileLength / 44100) - audiTime < 1 {
            playerNode.stop()
            //audioEngine.stop()
        }
        print("체크",vidTime, audiTime, interval)
        if interval > 0.1 {
            playerNode.pause()
            controlFrame(jump: vidTime)
        }
    }
}

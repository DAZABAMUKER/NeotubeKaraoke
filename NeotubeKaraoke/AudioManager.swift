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
    var currentFrame: AVAudioFramePosition = 0
    var jumpFrame: AVAudioFramePosition = 0
    
    init(file: URL, frequency: [Int], tone: Float){
        setEngine(file: file, frequency: frequency, tone: tone)
    }
    
    init(){
        
    }
    
    func play(){
        playerNode.play()
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
            audioFile = try AVAudioFile(forReading: file)
            //audioFileBuffer = AVAudioPCMBuffer(pcmFormat: audioFile.processingFormat, frameCapacity: UInt32(audioFile.length))
            //try audioFile.read(into: audioFileBuffer)
        }
        catch{
            print("오류남")
            print(error)
            return
        }
        
        audioFileLength = audioFile.length / 2
        
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
    
    func controlFrame(jump: Double) {
        guard let audioFile = audioFile else { return }
        let frameLocaition = AVAudioFramePosition(jump * audioFile.processingFormat.sampleRate)
        
        jumpFrame = currentFrame + frameLocaition
        jumpFrame = max(jumpFrame, 0)
        jumpFrame = min(jumpFrame, audioFileLength)
        currentFrame = jumpFrame
        
        playerNode.stop()
        
        let numberFrames = AVAudioFrameCount(audioFileLength - jumpFrame)
        playerNode.scheduleSegment(audioFile, startingFrame: jumpFrame, frameCount: numberFrames, at: nil)
        
        playerNode.play()
    }
}


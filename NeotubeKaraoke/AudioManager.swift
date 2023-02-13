//
//  AudioManager.swift
//  NeotubeKaraoke
//
//  Created by 안병욱 on 2023/02/13.
//

import Foundation
import AVFoundation

class AudioManager {
    let player = AVAudioPlayerNode()
    let audioEngine = AVAudioEngine()
    var pitchNode: AVAudioUnitTimePitch!
    var EQNode: AVAudioUnitEQ!
    var audioFileBuffer: AVAudioPCMBuffer!
    
    init(file: URL, frequency: [Int], tone: Float){
        setEngine(file: file, frequency: frequency, tone: tone)
    }
    func setEngine(file: URL, frequency: [Int], tone: Float) {
        do {
            print("실행중")
            guard let musicUrl = Bundle.main.url(forResource: "wild Flower", withExtension: "mp3") else {
                print(" 파일 안나오잖아")
                return
                
            }
            let audioFile = try AVAudioFile(forReading: musicUrl)
            audioFileBuffer = AVAudioPCMBuffer(pcmFormat: audioFile.processingFormat, frameCapacity: UInt32(audioFile.length))
            try audioFile.read(into: audioFileBuffer)
            print("준비 완료")
        }
        catch{
            print(error)
            return
        }
        
        print("이제 한다 ")
        pitchNode = AVAudioUnitTimePitch()
        pitchNode.overlap = 3.0
        pitchNode.pitch = tone * 100
        
        EQNode = AVAudioUnitEQ(numberOfBands: frequency.count)
        for i in 0...(EQNode.bands.count-1) {
                    EQNode.bands[i].frequency  = Float(frequency[i])
                    EQNode.bands[i].bypass     = false
                }
        
        
        audioEngine.attach(EQNode)
        audioEngine.attach(player)
        audioEngine.attach(pitchNode)
        
        let mixer = audioEngine.mainMixerNode
        audioEngine.connect(player, to: pitchNode, format: mixer.outputFormat(forBus: 0))
        audioEngine.connect(pitchNode, to: EQNode, format: mixer.outputFormat(forBus: 0))
        audioEngine.connect(EQNode, to: mixer, format: mixer.outputFormat(forBus: 0))
        
        audioEngine.prepare()
                do {
                    print("플레이 준비")
                    try audioEngine.start()
                    player.play()
                    player.scheduleBuffer(audioFileBuffer, at: nil, options: .loops, completionHandler: nil)
                    print("플레이")
                } catch {
                    assertionFailure("failed to audioEngine start. Error: \(error)")
                }
    }
}

//
//  ScoreWavedata.swift
//  NeotubeKaraoke
//
//  Created by 안병욱 on 2023/04/12.
//

import Foundation
import Combine
import AVFoundation

protocol ServiceProtocol {
    func buffer(url: URL, samplesCount: Int, completion: @escaping([Float]) -> ())
}

class Service {
    static let shared: ServiceProtocol = Service()
    private init() { }
}

extension Service: ServiceProtocol {
    func buffer(url: URL, samplesCount: Int, completion: @escaping([Float]) -> ()) {
        
        DispatchQueue.global(qos: .userInteractive).async {
            do {
                let file = try AVAudioFile(forReading: url)
                if let format = AVAudioFormat(commonFormat: .pcmFormatFloat32,
                                              sampleRate: file.fileFormat.sampleRate,
                                              channels: file.fileFormat.channelCount, interleaved: false),
                   let buf = AVAudioPCMBuffer(pcmFormat: format, frameCapacity: AVAudioFrameCount(file.length)) {
                    
                    try file.read(into: buf)
                    guard let floatChannelData = buf.floatChannelData else { return }
                    let frameLength = Int(buf.frameLength)
                    
                    let samples = Array(UnsafeBufferPointer(start:floatChannelData[0], count:frameLength))
                    
                    var result = [Float]()
                    let chunked = samples.chunked(into: samples.count / samplesCount)
                    for row in chunked {
                        var accumulator: Float = 0
                        let newRow = row.map{ $0 * $0 }
                        accumulator = newRow.reduce(0, +)
                        let power: Float = accumulator / Float(row.count)
                        let decibles = -10 * log10f(power)
                        
                        result.append(Float(decibles))
                        
                    }
                    DispatchQueue.main.async {
                        completion(result)
                    }
                }
            } catch {
                print("Audio Error: \(error)")
            }
        }
        
    }
}
extension Array {
    func chunked(into size: Int) -> [[Element]] {
        return stride(from: 0, to: count, by: size).map {
            Array(self[$0 ..< Swift.min($0 + size, count)])
        }
    }
}

//
//  VideoPlayer.swift
//  NeotubeKaraoke
//
//  Created by 안병욱 on 2023/02/16.
//

import Foundation
import SwiftUI
import AVKit

struct VideoPlayer: UIViewControllerRepresentable {
        
    @Binding var player: AVPlayer
    
    func makeUIViewController(context: Context) -> AVPlayerViewController {
        let controller = AVPlayerViewController()
        controller.player = player
        controller.showsPlaybackControls = false
        return controller
    }
    
    func updateUIViewController(_ uiViewController: AVPlayerViewController, context: Context) {
        <#code#>
    }
    
}

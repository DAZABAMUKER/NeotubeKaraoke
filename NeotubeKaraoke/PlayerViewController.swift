//
//  playerViewController.swift
//  NeotubeKaraoke
//
//  Created by 안병욱 on 2023/02/25.
//

import Foundation
import SwiftUI
import AVKit

struct PlayerViewController: UIViewControllerRepresentable {
    
    var player: AVPlayer
    func makeUIViewController(context: Context) -> AVPlayerViewController {
        let controller = AVPlayerViewController()
        controller.player = player
        controller.showsPlaybackControls = false
        return controller
    }
    func updateUIViewController(_ uiViewController: AVPlayerViewController, context: Context) {
        
    }
}

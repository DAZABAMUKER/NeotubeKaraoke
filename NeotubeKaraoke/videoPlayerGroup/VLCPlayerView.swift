//
//  VLCPlayerView.swift
//  NeotubeKaraoke
//
//  Created by 안병욱 on 11/16/24.
//

import SwiftUI
import MobileVLCKit

struct VLCPlayerView: UIViewRepresentable {

    typealias UIViewType = UIView
    
    @Binding var url: URL?
    //@Binding var spd: Float?
    @State var player: VLCMediaPlayer = VLCMediaPlayer()
    
    func makeUIView(context: Context) -> UIView {
        let view = UIView()
        player.drawable = view
        return view
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {
        guard let url = self.url else { return }
        //guard let spd = self.spd else { return }
        guard let path = Bundle.main.url(forResource: "videoplayback", withExtension: "mp4") else {
            print("Failed!!!!!")
            return
        }
        
        //player.media = VLCMedia(url: path)
        
        player.media = VLCMedia(url: url)
        player.play()
        //player.rate = spd
        //player

    }
    
    func tempo(spd: Float) {
        player.rate = spd
    }
    
}


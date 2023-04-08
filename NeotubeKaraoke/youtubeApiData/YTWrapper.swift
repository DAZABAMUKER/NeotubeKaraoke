//
//  YTWrapper.swift
//  NeotubeKaraoke
//
//  Created by 안병욱 on 2023/04/07.
//

import SwiftUI
import YouTubeiOSPlayerHelper

struct YTWrapper : UIViewRepresentable {
    var videoID : String
    
    func makeUIView(context: Context) -> YTPlayerView {
        let playerView = YTPlayerView()
        playerView.load(withVideoId: videoID)
        return playerView
    }
    
    func updateUIView(_ uiView: YTPlayerView, context: Context) {
        //
    }
}

//
//  VLCView.swift
//  NeotubeKaraoke
//
//  Created by 안병욱 on 11/17/24.
//

import SwiftUI
import MobileVLCKit

struct VLCView: UIViewRepresentable {
    func updateUIView(_ uiView: UIView, context: Context) {
        
    }
    
    typealias UIViewType = UIView
    @State var player: VLCMediaPlayer
    func makeUIView(context: Context) -> UIView {
        let view = UIView()
        player.drawable = view
        return view
    }
}

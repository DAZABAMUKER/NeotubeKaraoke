//
//  DragVidProgress.swift
//  NeotubeKaraoke
//
//  Created by 안병욱 on 2023/03/06.
//

import Foundation
import SwiftUI

struct DragVidProgress: ViewModifier {
    @State var offset = 0.0
    var duration: Double
    var width: Double
    @State var progressLocation = 0.0
    var player: VideoPlayers
    public func body(content: Content) -> some View {
        content
            .offset(x: self.offset)
            .gesture(
            DragGesture()
                .onChanged({ gesture in
                    self.offset = gesture.translation.width
                })
                .onEnded({ gesture in
                    print(self.offset)
                    self.progressLocation = gesture.location.x*duration/width
                    print(progressLocation)
                    player.progressSlider(to: progressLocation)
                    self.offset = 0
                })
            )
            .padding(0)
    }
}

extension View {
    func vidSlider(duartion: Double, width: Double, player: VideoPlayers) -> some View {
        modifier(DragVidProgress(duration: duartion, width: width, player: player))
    }
}

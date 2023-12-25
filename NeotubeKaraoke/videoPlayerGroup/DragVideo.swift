//
//  DragVideo.swift
//  NeotubeKaraoke
//
//  Created by 안병욱 on 2023/03/06.
//

import Foundation
import SwiftUI

struct DragVideo: ViewModifier {
    
    @Binding var vidFull: Bool
    @Binding var tap: Bool
    
    public func body(content: Content) -> some View {
        content
            .gesture(
            DragGesture()
                .onChanged({ gesture in
                })
                .onEnded({ gesture in
                    if gesture.location.y > 150 {
                        self.vidFull.toggle()
                        self.tap = false
                    }
                })
            )
    }
}

extension View {
    func DragVid(vidFull: Binding<Bool>, tap: Binding<Bool>) -> some View {
        self.modifier(DragVideo(vidFull: vidFull, tap: tap))
    }
}

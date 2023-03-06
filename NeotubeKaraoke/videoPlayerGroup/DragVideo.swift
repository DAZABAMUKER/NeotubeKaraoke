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
    
    public func body(content: Content) -> some View {
        content
            .gesture(
            DragGesture()
                .onChanged({ gesture in
                })
                .onEnded({ gesture in
                    self.vidFull.toggle()
                })
            )
    }
}

extension View {
    func DragVid(vidFull: Binding<Bool>) -> some View {
        self.modifier(DragVideo(vidFull: vidFull))
    }
}

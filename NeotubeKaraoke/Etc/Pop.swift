//
//  Pop.swift
//  NeotubeKaraoke
//
//  Created by 안병욱 on 2023/05/07.
//

import Foundation
import SwiftUI

struct Pops: ViewModifier {
    @State var show = false
    
    func body(content: Content) -> some View {
        ZStack{
            if self.show {
                HStack{
                    Button {
                        
                    } label: {
                        Image(systemName: "hands.clap.fill")
                    }
                    Divider()
                    Button {
                        
                    } label: {
                        Image(systemName: "shareplay")
                    }
                }
                .offset(x: 0, y: -100)
                .background(.secondary)
                .cornerRadius(10)
                .border(.red)
            }
            content
                .onLongPressGesture {
                    self.show = true
                }
        }
    }
}

extension View {
    func pops() -> some View {
        self.modifier(Pops())
    }
}

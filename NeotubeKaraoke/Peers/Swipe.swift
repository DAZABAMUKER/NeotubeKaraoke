//
//  Swipe.swift
//  NeotubeKaraoke
//
//  Created by 안병욱 on 2023/05/04.
//

import Foundation
import SwiftUI

struct Swipe: ViewModifier {
    
    @State var offset = 0.0
    let geometry: GeometryProxy
    @State var open = false
    let maxoffset = -60.0
    
    func body(content: Content) -> some View {
        ZStack{
            RoundedRectangle(cornerRadius: 10)
            //.frame(width: geometry.size.width - 65)
                .padding(.horizontal,20)
                .padding(.vertical, 6)
                .foregroundColor(.green)
            Button {
            } label: {
                HStack{
                    Spacer()
                    Image(systemName: "shared.with.you")
                        .resizable()
                        .scaledToFit()
                        .frame(height: 25)
                        .foregroundColor(.white)
                        .padding(.horizontal,40)
                }
            }
            .frame(width: geometry.size.width)
            
            content
                .offset(x: offset)
                .gesture(
                    DragGesture()
                        .onChanged{ gesture in
                            withAnimation {
                                if open {
                                    guard gesture.translation.width < maxoffset else {return}
                                    offset = gesture.translation.width
                                } else {
                                    guard gesture.translation.width < 0 else {return}
                                    offset = gesture.translation.width
                                }
                            }
                        }
                        .onEnded{ gesture in
                            withAnimation {
                                if open {
                                    offset = .zero
                                    open = false
                                } else {
                                    guard gesture.translation.width < 0 else {return}
                                    offset = maxoffset
                                    open = true
                                }
                            }
                        }
                )
            
        }
    }
}

extension View {
    func Swipes(geometry: GeometryProxy) -> some View {
        self.modifier(Swipe(geometry: geometry))
    }
}

//
//  ExternalDisplay.swift
//  NeotubeKaraoke
//
//  Created by 안병욱 on 2023/04/13.
//

import SwiftUI
import AVKit

struct ExternalDisplay: View {
    @EnvironmentObject var player: EnvPlayer
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .center){
                Image("clear")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: geometry.size.width ,height: geometry.size.height)
                    .opacity(0.3)
                if player.isOn{
                    PlayerViewController(player: player.player.player ?? AVPlayer())
                        .onAppear(){
                            print("플레이어 설정 됨")
                        }
                }
            }
            .preferredColorScheme(.dark)
            .edgesIgnoringSafeArea(.all )
        }
    }
}

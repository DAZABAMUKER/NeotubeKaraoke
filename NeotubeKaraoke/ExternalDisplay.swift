//
//  ExternalDisplay.swift
//  NeotubeKaraoke
//
//  Created by 안병욱 on 2023/04/13.
//

import SwiftUI
import AVKit

struct ExternalDisplay: View {
    @ObservedObject var player: VideoPlayers
    var body: some View {
        PlayerViewController(player: player)
    }
}

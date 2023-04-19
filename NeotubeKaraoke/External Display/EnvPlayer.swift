//
//  EnvPlayer.swift
//  NeotubeKaraoke
//
//  Created by 안병욱 on 2023/04/16.
//

import Foundation

final class EnvPlayer: ObservableObject {
    @Published var player: VideoPlayers
    @Published var isOn: Bool
    static let shared = EnvPlayer(VideoPlayers(), isOn: false)
    init(_ player: VideoPlayers, isOn: Bool) {
        self.player = player
        self.isOn = isOn
    }
}

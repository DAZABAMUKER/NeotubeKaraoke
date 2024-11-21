//
//  EnvPlayer.swift
//  NeotubeKaraoke
//
//  Created by 안병욱 on 2023/04/16.
//

import Foundation

final class EnvPlayer: ObservableObject {
    @Published var player: vlcPlayerController
    @Published var isOn: Bool
    //var audioManager: AudioManager?
    static let shared = EnvPlayer(vlcPlayerController(), isOn: false)
    init(_ player: vlcPlayerController, isOn: Bool) {
        self.player = player
        self.isOn = isOn
    }
}

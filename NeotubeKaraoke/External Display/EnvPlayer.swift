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
    @Published var isConnected: Bool
    //var audioManager: AudioManager?
    static let shared = EnvPlayer(vlcPlayerController(), isOn: false)
    init(_ player: vlcPlayerController, isOn: Bool, isConnected: Bool = false) {
        self.player = player
        self.isOn = isOn
        self.isConnected = false
    }
}

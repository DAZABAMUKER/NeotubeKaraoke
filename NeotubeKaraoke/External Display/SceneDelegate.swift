//
//  SceneDelegate.swift
//  NeotubeKaraoke
//
//  Created by 안병욱 on 2023/04/16.
//

import Foundation
import UIKit
import SwiftUI

final class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?
    
    func scene(_ scene: UIScene,
               willConnectTo session: UISceneSession,
               options connectionOptions: UIScene.ConnectionOptions) {
        
        guard let scene = scene as? UIWindowScene else {
            return
        }
        scene.screen.overscanCompensation = .none
        let content = ExternalDisplay()
            .environmentObject(EnvPlayer.shared)
        window = UIWindow(windowScene: scene)
        window?.screen.overscanCompensation = .none
        window?.rootViewController = UIHostingController(rootView: content)
        window?.isHidden = false
    }
}

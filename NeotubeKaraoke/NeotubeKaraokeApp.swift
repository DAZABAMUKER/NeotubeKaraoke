//
//  NeotubeKaraokeApp.swift
//  NeotubeKaraoke
//
//  Created by 안병욱 on 2022/11/12.
//

import SwiftUI
import PythonSupport

@main
struct NeotubeKaraokeApp: App {
    let persistenceController = PersistenceController.shared
    

    var body: some Scene {
        WindowGroup {
            ContentView(tabIndex: .Home)
                .environment(\.managedObjectContext, persistenceController.container.viewContext)

        }
    }
    init() {
            PythonSupport.initialize()
        }
}

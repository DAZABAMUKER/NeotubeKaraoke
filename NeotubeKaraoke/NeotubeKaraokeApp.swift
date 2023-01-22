//
//  NeotubeKaraokeApp.swift
//  NeotubeKaraoke
//
//  Created by 안병욱 on 2022/11/12.
//

import SwiftUI
import PythonSupport
import YoutubeDL

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
            YoutubeDL.downloadPythonModule { error in
                guard error == nil else { fatalError() }
                let ydl = try? YoutubeDL()
                print(ydl?.version)
            }
        }
}

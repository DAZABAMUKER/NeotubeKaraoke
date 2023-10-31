//
//  NeotubeKaraokeApp.swift
//  NeotubeKaraoke
//
//  Created by 안병욱 on 2022/11/12.
//

import SwiftUI
//import PythonSupport
import GoogleMobileAds
import AppTrackingTransparency
import AdSupport
import Firebase

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        FirebaseApp.configure()
        return true
    }
}

@main
struct NeotubeKaraokeApp: App {
    
    let persistenceController = PersistenceController.shared
    @StateObject var envPlayer: EnvPlayer = EnvPlayer.shared
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    
    @StateObject var purchaseManager: PurchaseManager
    @StateObject private var entitlementManager: EntitlementManager

    var body: some Scene {
        WindowGroup {
            ContentView(tabIndex: .Home)
            //fortestView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
                .environmentObject(envPlayer)
                .environmentObject(purchaseManager)
                .environmentObject(entitlementManager)
                .task {
                    await purchaseManager.updatePurchasedProducts()
                }
        }
    }
    init() {
        //PythonSupport.initialize()
        GADMobileAds.sharedInstance().start(completionHandler: nil)
        let entitlementManager = EntitlementManager()
        let purchaseManager = PurchaseManager(entitlementManager: entitlementManager)
        self._entitlementManager = StateObject(wrappedValue: entitlementManager)
        self._purchaseManager = StateObject(wrappedValue: purchaseManager)
//        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
//            ATTrackingManager.requestTrackingAuthorization(completionHandler: { _ in })
//        }
    }
}

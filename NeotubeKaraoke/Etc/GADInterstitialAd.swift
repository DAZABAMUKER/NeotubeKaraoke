//
//  GADInterstitialAd.swift
//  NeotubeKaraoke
//
//  Created by 안병욱 on 2023/03/28.
//

import Foundation
import SwiftUI
import GoogleMobileAds

/*
struct GADInterstitialAds: View {
    private let adViewControllerRepresentable = AdViewControllerRepresentable()
    private let adCoordinator = AdCoordinator()


    var body: some View {
        VStack{
            Text("Hello, World!")
                .background {
                    // Add the adViewControllerRepresentable to the background so it
                    // doesn't influence the placement of other views in the view hierarchy.
                    adViewControllerRepresentable
                        .frame(width: .zero, height: .zero)
                }
            Button("Load an ad") {
                adCoordinator.loadAd()
            }
            
            Button("Watch an ad") {
                //adCoordinator.loadAd()
                adCoordinator.presentAd(from: adViewControllerRepresentable.viewController)
            }
        }
    }
}
*/
struct AdViewControllerRepresentable: UIViewControllerRepresentable {
  let viewController = UIViewController()

  func makeUIViewController(context: Context) -> some UIViewController {
      return viewController
  }
    
    func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {
        // No implementation needed. Nothing to update.
    }
}

class AdCoordinator: NSObject, GADFullScreenContentDelegate, ObservableObject {
    private var ad: GADInterstitialAd? {
        didSet {
            print(ad, oldValue)
        }
    }
    @Published var isAdTwice: Bool = false
    @Published var showScore = false
    func loadAd() {
        GADInterstitialAd.load(
            withAdUnitID: "ca-app-pub-7240659336832390/6681476690", request: GADRequest()
        ) { ad, error in
            if let error = error {
                return print("Failed to load ad with error: \(error.localizedDescription)")
            }
            
            self.ad = ad
            print(self.ad)
            self.ad?.fullScreenContentDelegate = self
        }
    }
    
    func presentAd(from viewController: UIViewController) {
        print(self.ad == nil ? "nil~" : "ok")
        guard let fullScreenAd = ad else {
            return print("Ad wasn't ready")
        }
        
        fullScreenAd.present(fromRootViewController: viewController)
    }
    
    func adDidRecordImpression(_ ad: GADFullScreenPresentingAd) {
        print("\(#function) called")
        self.isAdTwice = true
        self.showScore = true
    }
    
    func adDidRecordClick(_ ad: GADFullScreenPresentingAd) {
        print("\(#function) called")
    }
    
    func ad(_ ad: GADFullScreenPresentingAd, didFailToPresentFullScreenContentWithError error: Error) {
        print("\(#function) called", error)
    }
    
    func adWillPresentFullScreenContent(_ ad: GADFullScreenPresentingAd) {
        //print("\(#function) called")
    }
    
    
    func adWillDismissFullScreenContent(_ ad: GADFullScreenPresentingAd) {
        //print("\(#function) called")
    }
    
    func adDidDismissFullScreenContent(_ ad: GADFullScreenPresentingAd) {
        print("\(#function) called")
    }
}

struct BannerAd: UIViewRepresentable {
    
    var unitID: String = "ca-app-pub-7240659336832390/5106742394"
    
    func makeCoordinator() -> Coordinator {
        return Coordinator()
    }
    func makeUIView(context: Context) -> GADBannerView {
        let adView = GADBannerView(adSize: GADAdSizeBanner)
        adView.adUnitID = unitID
        adView.rootViewController = UIApplication.shared.getRootViewController()
        adView.delegate = context.coordinator
        adView.load(GADRequest())
        return adView
    }
    func updateUIView(_ uiView: UIViewType, context: Context) {
        
    }
    
    class Coordinator: NSObject, GADBannerViewDelegate {
        func bannerViewDidReceiveAd(_ bannerView: GADBannerView) {
          print("bannerViewDidReceiveAd")
        }

        func bannerView(_ bannerView: GADBannerView, didFailToReceiveAdWithError error: Error) {
          print("bannerView:didFailToReceiveAdWithError: \(error.localizedDescription)")
        }

        func bannerViewDidRecordImpression(_ bannerView: GADBannerView) {
          print("bannerViewDidRecordImpression")
        }

        func bannerViewWillPresentScreen(_ bannerView: GADBannerView) {
          print("bannerViewWillPresentScreen")
        }

        func bannerViewWillDismissScreen(_ bannerView: GADBannerView) {
          print("bannerViewWillDIsmissScreen")
        }

        func bannerViewDidDismissScreen(_ bannerView: GADBannerView) {
          print("bannerViewDidDismissScreen")
        }
    }
}

extension UIApplication {
    func getRootViewController()->UIViewController {
        guard let screen = self.connectedScenes.first as? UIWindowScene else {
            return .init()
        }
        guard let root = screen.windows.first?.rootViewController else {
            return .init()
        }
        return root
    }
}

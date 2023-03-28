//
//  GADInterstitialAd.swift
//  NeotubeKaraoke
//
//  Created by 안병욱 on 2023/03/28.
//

import Foundation
import SwiftUI
import GoogleMobileAds


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
                adCoordinator.loadAd()
                adCoordinator.presentAd(from: adViewControllerRepresentable.viewController)
            }
        }
    }
}

struct AdViewControllerRepresentable: UIViewControllerRepresentable {
  let viewController = UIViewController()

  func makeUIViewController(context: Context) -> some UIViewController {
    return viewController
  }

  func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {
    // No implementation needed. Nothing to update.
  }
}

class AdCoordinator: NSObject {
  private var ad: GADInterstitialAd?

  func loadAd() {
    GADInterstitialAd.load(
      withAdUnitID: "ca-app-pub-3940256099942544/4411468910", request: GADRequest()
    ) { ad, error in
      if let error = error {
        return print("Failed to load ad with error: \(error.localizedDescription)")
      }

      self.ad = ad
    }
  }

  func presentAd(from viewController: UIViewController) {
    guard let fullScreenAd = ad else {
      return print("Ad wasn't ready")
    }

    fullScreenAd.present(fromRootViewController: viewController)
  }
}

//
//  NativeAdLoader.swift
//  RatingKit
//
//  Created by Did on 27/04/26.
//

import Foundation
import GoogleMobileAds


final class NativeAdLoader: NSObject {
    
    private let adUnitIDs: [String]
    private let isVideo: Bool
    private weak var rootVC: UIViewController?
    private let completion: (GADNativeAd?) -> Void
    
    private var currentIndex = 0
    private var adLoader: GADAdLoader?
    
    init(
        adUnitIDs: [String],
        isVideo: Bool,
        rootVC: UIViewController,
        completion: @escaping (GADNativeAd?) -> Void
    ) {
        self.adUnitIDs = adUnitIDs
        self.isVideo = isVideo
        self.rootVC = rootVC
        self.completion = completion
    }
    
    func start() {
        loadNext()
    }
    
    private func loadNext() {
        
        guard currentIndex < adUnitIDs.count else {
            DispatchQueue.main.async {
                self.completion(nil)
            }
            return
        }
        
        guard let rootVC = rootVC else {
            completion(nil)
            return
        }
        
        let adUnitID = adUnitIDs[currentIndex]
        currentIndex += 1
        
        let options: [GADAdLoaderOptions]?
        
        if isVideo {
            let videoOptions = GADVideoOptions()
            videoOptions.startMuted = true
            options = [videoOptions]
        } else {
            options = nil
        }
        
        adLoader = GADAdLoader(
            adUnitID: adUnitID,
            rootViewController: rootVC,
            adTypes: [.native],
            options: options
        )
        
        adLoader?.delegate = self
        adLoader?.load(GADRequest())
    }
}

extension NativeAdLoader: GADNativeAdLoaderDelegate, GADAdLoaderDelegate {
    
    func adLoader(_ adLoader: GADAdLoader,
                  didReceive nativeAd: GADNativeAd) {
        
        MonetizationAnalytics.shared.log(.nativeLoaded)
        
        DispatchQueue.main.async {
            self.completion(nativeAd)
        }
    }
    
    func adLoader(_ adLoader: GADAdLoader,
                  didFailToReceiveAdWithError error: Error) {
        
        MonetizationAnalytics.shared.log(.nativeFailed, params: [
            "error": error.localizedDescription
        ])
        
        loadNext() // fallback to next floor
    }
}

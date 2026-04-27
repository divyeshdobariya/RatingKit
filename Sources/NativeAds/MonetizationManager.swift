//
//  MonetizationManager.swift
//  RatingKit
//
//  Created by Did on 27/04/26.
//

import Foundation
import UIKit
import GoogleMobileAds

public final class MonetizationManager {
    
    public static let shared = MonetizationManager()
    
    private init() {}
    
    private var isPremium: (() -> Bool)?
    
    // MARK: - Setup
    
    public func configure(isPremiumUser: @escaping () -> Bool) {
        
        self.isPremium = isPremiumUser
        
        // Initialize AdMob
        GADMobileAds.sharedInstance().start(completionHandler: nil)
        
        MonetizationAnalytics.shared.log(.sdkInitialized)
    }
}

extension MonetizationManager {
    
    public func loadNativeAd(
        adUnitIDs: [String],
        isVideo: Bool = false,
        from viewController: UIViewController,
        completion: @escaping (GADNativeAd?) -> Void
    ) {
        
        MonetizationAnalytics.shared.log(.nativeRequested)
        
        // ✅ Premium check
        if isPremium?() == true {
            MonetizationAnalytics.shared.log(.adSkippedPremium)
            completion(nil)
            return
        }
        
        // ✅ Network check (your existing class)
//        if !NetworkMonitor.shared.isConnected {
//            MonetizationAnalytics.shared.log(.adSkippedNoInternet)
//            completion(nil)
//            return
//        }
        
        NativeAdLoader(
            adUnitIDs: adUnitIDs,
            isVideo: isVideo,
            rootVC: viewController,
            completion: completion
        ).start()
    }
}

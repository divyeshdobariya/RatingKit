//
//  MonetizationAnalytics.swift
//  RatingKit
//
//  Created by Did on 27/04/26.
//

import Foundation

public enum MonetizationEvent: String {
    
    case sdkInitialized
    
    case nativeRequested
    case nativeLoaded
    case nativeFailed
    
    case adSkippedPremium
    case adSkippedNoInternet
}

public final class MonetizationAnalytics {
    
    public static let shared = MonetizationAnalytics()
    
    private init() {}
    
    // Inject your analytics (Firebase / Adjust / AppsFlyer)
    public var logger: ((MonetizationEvent, [String: Any]?) -> Void)?
    
    public func log(_ event: MonetizationEvent,
                    params: [String: Any]? = nil) {
        logger?(event, params)
    }
}

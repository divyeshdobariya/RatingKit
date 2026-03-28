//
//  RatingTrigger.swift
//  Video Player
//
//  Created by Did on 18/12/25.
//

import UIKit


public protocol BottomRatingPopupDelegate: AnyObject {
    func ratingPopupDidSubmit(
        rating: Int,
        selectedTags: [String],
        feedbackText: String
    )
}
public enum AppOpenRatingResult {
    case incremented(count: Int)
    case notTriggered(count: Int)
    case popupShown
    case neverShowEnabled
}


// MARK: - Rating Trigger (Call From Anywhere)

public final class RatingTrigger {

    public static let shared = RatingTrigger()
    
    public var isDebugMode: Bool = false // 👈 ADD THIS
    public var isResetMode: Bool = false
    public var forceShowNeverOption: Bool = false
    
    public var ShowNeverOptionCounter: Int = 10
    public var isShowTagListView: Bool = false

    
    private let openKey = "rating_app_open"
    private let cancelKey = "rating_cancel_count"
    private let neverKey = "rating_never_show"

    public weak var delegate: BottomRatingPopupDelegate?

    public init() {}
    
    public func appOpened(
        title: String,
        subtitle : String,
        rateNowTitle: String,
        MaybeLaterTitle : String,
        nevershowTitle : String,
        triggerCounts: [Int],
        feedbackOptions: [String],
        completion: ((AppOpenRatingResult) -> Void)? = nil
    ) {
        let defaults = UserDefaults.standard

        // 🔥 RESET MODE → ALWAYS CLEAR DATA
            if isResetMode {
                resetRatingFlow()
                print("🔄 Reset mode active")
            }
        
        // 🔥 DEBUG MODE → ALWAYS SHOW
        if isDebugMode {
               
               DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                   
                   guard let rootVC = UIApplication.topViewController() else { return }

                   let viewController = RateDialogVC()
                   viewController.modalPresentationStyle = .overCurrentContext
                   viewController.feedbackOptions = feedbackOptions
                   viewController.isneverShow = true
                   viewController.titleSTR = title
                   viewController.subtitleSTR = subtitle
                   viewController.rateNowTitle = rateNowTitle
                   viewController.maybeLaterTitle = MaybeLaterTitle
                   viewController.neverShowTitle = nevershowTitle
                   viewController.isShowTagListView = self.isShowTagListView
                   viewController.onDismiss = {
                       completion?(.popupShown)
                   }

                   rootVC.present(viewController, animated: true)
               }

               return
           }

        
        resetIfNeeded()
        // Never show again
        if defaults.bool(forKey: neverKey) {
            completion?(.neverShowEnabled)
            return
        }

        // Increment app open count
        let count = defaults.integer(forKey: openKey) + 1
        defaults.set(count, forKey: openKey)

        completion?(.incremented(count: count))

        // Check trigger condition
        guard triggerCounts.contains(count) else {
            completion?(.notTriggered(count: count))
            return
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {

            guard
                let rootVC = UIApplication.topViewController()
            else { return }

            let viewController = RateDialogVC()

            viewController.modalPresentationStyle = .overCurrentContext
            viewController.feedbackOptions = feedbackOptions
            viewController.isneverShow = RatingTrigger.shared.shouldShowNeverOption()
            viewController.titleSTR = title
            viewController.subtitleSTR = subtitle
            viewController.rateNowTitle = rateNowTitle
            viewController.maybeLaterTitle = MaybeLaterTitle
            viewController.neverShowTitle = nevershowTitle
            viewController.isShowTagListView = self.isShowTagListView
            
            // 🔔 Optional: callback when popup finishes
            viewController.onDismiss = {
                completion?(.popupShown)
            }
            rootVC.present(viewController, animated: true)
        }
    }

    func shouldShowNeverOption() -> Bool {
        if forceShowNeverOption {
                return true
            }
            return UserDefaults.standard.integer(forKey: cancelKey) >= ShowNeverOptionCounter
        }
    
    func incrementCancel() {
        UserDefaults.standard.set(
            UserDefaults.standard.integer(forKey: cancelKey) + 1,
            forKey: cancelKey
        )
    }
    
    func neverShowAgain() {
        UserDefaults.standard.set(true, forKey: neverKey)
    }
    
    func resetIfNeeded() {
        let key = "rating_last_reset"
        let now = Date()
        
        let last = UserDefaults.standard.object(forKey: key) as? Date ?? Date.distantPast
        
        let days = Calendar.current.dateComponents([.day], from: last, to: now).day ?? 0
        
        if days >= 30 {
            resetRatingFlow()
            UserDefaults.standard.set(now, forKey: key)
        }
    }
    
    func resetRatingFlow() {
        
        let defaults = UserDefaults.standard
        
        defaults.removeObject(forKey: openKey)
        defaults.removeObject(forKey: cancelKey)
        defaults.removeObject(forKey: neverKey)
        
        defaults.synchronize()
        
        print("✅ Rating flow reset")
    }
    
}

extension UIApplication {
    
    static func topViewController() -> UIViewController? {
        
        guard let scene = UIApplication.shared.connectedScenes
            .first as? UIWindowScene,
              let root = scene.windows.first(where: { $0.isKeyWindow })?.rootViewController
        else { return nil }
        
        var top = root
        while let presented = top.presentedViewController {
            top = presented
        }
        return top
    }
}


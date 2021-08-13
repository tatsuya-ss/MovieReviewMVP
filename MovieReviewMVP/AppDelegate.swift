//
//  AppDelegate.swift
//  MovieReviewMVP
//
//  Created by 坂本龍哉 on 2021/04/29.
//

import UIKit
import Firebase
import GoogleMobileAds
import AppTrackingTransparency

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        FirebaseApp.configure()
        let db = Firestore.firestore()
        print(db)

        // iOS14以降の場合、トラッキングのアラートを表示する
        if #available(iOS 14, *) {
            ATTrackingManager.requestTrackingAuthorization { status in
                GADMobileAds.sharedInstance().start(completionHandler: nil)
            }
        } else {
            GADMobileAds.sharedInstance().start(completionHandler: nil)
        }
        
        return true
    }
}


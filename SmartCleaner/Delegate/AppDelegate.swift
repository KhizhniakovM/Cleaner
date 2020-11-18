//
//  AppDelegate.swift
//  SmartCleaner
//
//  Created by Luchik on 19.05.2020.
//  Copyright © 2020 Luchik. All rights reserved.
//

import UIKit
import Firebase
import YandexMobileMetrica
import YandexMobileMetricaCrashes
import GoogleMobileAds
import FBSDKCoreKit
import SwiftyStoreKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        completeTransactions()
        checkSubscription()
        
        FirebaseApp.configure()
        let configuration = YMMYandexMetricaConfiguration.init(apiKey: "f83c2e42-f3bf-4f89-9c01-67e7e99934b9")
        YMMYandexMetrica.activate(with: configuration!)
        GADMobileAds.sharedInstance().start(completionHandler: nil)
        ApplicationDelegate.shared.application(
            application,
            didFinishLaunchingWithOptions: launchOptions
        )
        
        window?.frame = UIScreen.main.bounds
        window?.makeKeyAndVisible()
        return true
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]
    ) -> Bool {
        ApplicationDelegate.shared.application(
            app,
            open: url,
            sourceApplication: options[UIApplication.OpenURLOptionsKey.sourceApplication] as? String,
            annotation: options[UIApplication.OpenURLOptionsKey.annotation]
        )
    }
    func completeTransactions() {
        SwiftyStoreKit.completeTransactions(atomically: true) { purchases in
            for purchase in purchases {
                switch purchase.transaction.transactionState {
                case .purchased, .restored:
                    if purchase.needsFinishTransaction {
                        SwiftyStoreKit.finishTransaction(purchase.transaction)
                    }
                case .failed, .purchasing, .deferred:
                    break
                @unknown default:
                    break
                }
            }
        }
    }
    func checkSubscription() {
        let appleValidator = AppleReceiptValidator(service: .production, sharedSecret: "ee347928493543a6a7d4d1a79807f9d3")
        SwiftyStoreKit.verifyReceipt(using: appleValidator) { result in
            switch result {
            case .success(let receipt):
                let year = "com.ioscleaner.proalexst.year"
                let month = "com.ioscleaner.proalexst.month"
                let week = "com.ioscleaner.proalexst.week"
                
                let purchaseResultYear = SwiftyStoreKit.verifySubscription(
                    ofType: .autoRenewable,
                    productId: year,
                    inReceipt: receipt)
                let purchaseResultMonth = SwiftyStoreKit.verifySubscription(
                    ofType: .autoRenewable,
                    productId: month,
                    inReceipt: receipt)
                let purchaseResultWeek = SwiftyStoreKit.verifySubscription(
                    ofType: .autoRenewable,
                    productId: week,
                    inReceipt: receipt)
                
                switch purchaseResultYear {
                case .purchased(_,_):
                    UserDefService.setValue(true, forKey: "isPro")
                case .expired(_,_):
                    UserDefService.setValue(false, forKey: "isPro")
                case .notPurchased:
                    print("")
                }
                switch purchaseResultMonth {
                case .purchased(_,_):
                    UserDefService.setValue(true, forKey: "isPro")
                case .expired(_,_):
                    UserDefService.setValue(false, forKey: "isPro")
                case .notPurchased:
                    print("")
                }
                switch purchaseResultWeek {
                case .purchased(_,_):
                    UserDefService.setValue(true, forKey: "isPro")
                case .expired(_,_):
                    UserDefService.setValue(false, forKey: "isPro")
                case .notPurchased:
                    print("")
                }
            case .error(let error):
                print("Receipt verification failed: \(error)")
            }
        }
    }
}

class UserDefService {
    static let usdef = UserDefaults.standard
    static func setValue(_ value: Bool, forKey string: String) {
        usdef.set(value, forKey: string)
    }
    static func takeValue(_ forKey: String) -> Bool {
        return usdef.bool(forKey: forKey)
    }
}


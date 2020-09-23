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

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        FirebaseApp.configure()
//        let configuration = YMMYandexMetricaConfiguration.init(apiKey: "API_key")
//        YMMYandexMetrica.activate(with: configuration!)
        GADMobileAds.sharedInstance().start(completionHandler: nil)
        
        window?.frame = UIScreen.main.bounds
        window?.makeKeyAndVisible()
        return true
    }
}


//
//  SplashController.swift
//  SmartCleaner
//
//  Created by Luchik on 20.05.2020.
//  Copyright © 2020 Luchik. All rights reserved.
//

import Foundation
import UIKit

class SplashController: BaseController {
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        showNextVC()
        banner.isHidden = true
    }
    // MARK: - Methods
    private func showNextVC() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            if UserDefaults.standard.object(forKey: "isFirstLaunch") == nil {
                UserDefaults.standard.set(false, forKey: "isFirstLaunch")
                let pageVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "PageViewController") as! UIPageViewController
                pageVC.modalPresentationStyle = .fullScreen
                self.present(pageVC, animated: true, completion: nil)
            } else {
                let vc: NavigationController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "Home") as! NavigationController
                vc.modalPresentationStyle = .fullScreen
                self.present(vc, animated: true, completion: nil)
            }
        }
    }
}

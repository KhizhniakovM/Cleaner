//
//  SubscriptionController.swift
//  SmartCleaner
//
//  Created by Luchik on 20.05.2020.
//  Copyright © 2020 Luchik. All rights reserved.
//

import Foundation
import UIKit
import SwiftyStoreKit

class SubscriptionController: BaseController {
    // MARK: - UI
    @IBOutlet weak var exitButton: UIButton!
    @IBOutlet weak var yearButton: UIButton!
    @IBOutlet weak var monthButton: UIButton!
    @IBOutlet weak var weekButton: UIButton!
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupButtons()
        takePurcasesInfo { [weak self] (year, month, week) in
            self?.yearButton.setTitle("3-days trial, than \(year) / year", for: .normal)
            self?.monthButton.setTitle("3-days trial, than \(month) / month", for: .normal)
            self?.weekButton.setTitle("\(week) / week", for: .normal)
        }
        banner.isHidden = true
    }
    // MARK: - Methods
    private func setupButtons() {
        self.exitButton.isHidden = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            self.exitButton.isHidden = false
        }
    }
    private func takePurcasesInfo(completion: @escaping (String, String, String) -> Void) {
        var year = String()
        var month = String()
        var week = String()
        SwiftyStoreKit.retrieveProductsInfo([
            "com.ioscleaner.proalexst.year",
            "com.ioscleaner.proalexst.month",
            "com.ioscleaner.proalexst.week"
        ]) { result in
            result.retrievedProducts.forEach { (product) in
                if product.productIdentifier == "com.ioscleaner.proalexst.year" {
                    guard let price = product.localizedPrice else { return }
                    year = price
                } else if product.productIdentifier == "com.ioscleaner.proalexst.month" {
                    guard let price = product.localizedPrice else { return }
                    month = price
                } else if product.productIdentifier == "com.ioscleaner.proalexst.week" {
                    guard let price = product.localizedPrice else { return }
                    week = price
                }
            }
            completion(year, month, week)
        }
    }
    @IBAction func tapYearSubscription(_ sender: UIButton) {
        SwiftyStoreKit.purchaseProduct("com.ioscleaner.proalexst.year", quantity: 1, atomically: true) { result in
            switch result {
            case .success(let purchase):
                UserDefService.setValue(true, forKey: "isPro")
                let vc = HomeController()
                vc.modalPresentationStyle = .fullScreen
                self.present(vc, animated: true, completion: nil)
            case .error(let error):
                switch error.code {
                case .unknown: print("Unknown error. Please contact support")
                case .clientInvalid: print("Not allowed to make the payment")
                case .paymentCancelled: break
                case .paymentInvalid: print("The purchase identifier was invalid")
                case .paymentNotAllowed: print("The device is not allowed to make the payment")
                case .storeProductNotAvailable: print("The product is not available in the current storefront")
                case .cloudServicePermissionDenied: print("Access to cloud service information is not allowed")
                case .cloudServiceNetworkConnectionFailed: print("Could not connect to the network")
                case .cloudServiceRevoked: print("User has revoked permission to use this cloud service")
                default: print((error as NSError).localizedDescription)
                }
            }
        }
    }
    @IBAction func tapMonthSubscription(_ sender: UIButton) {
        SwiftyStoreKit.purchaseProduct("com.ioscleaner.proalexst.month", quantity: 1, atomically: true) { result in
            switch result {
            case .success(let purchase):
                UserDefService.setValue(true, forKey: "isPro")
                let vc = HomeController()
                vc.modalPresentationStyle = .fullScreen
                self.present(vc, animated: true, completion: nil)
            case .error(let error):
                switch error.code {
                case .unknown: print("Unknown error. Please contact support")
                case .clientInvalid: print("Not allowed to make the payment")
                case .paymentCancelled: break
                case .paymentInvalid: print("The purchase identifier was invalid")
                case .paymentNotAllowed: print("The device is not allowed to make the payment")
                case .storeProductNotAvailable: print("The product is not available in the current storefront")
                case .cloudServicePermissionDenied: print("Access to cloud service information is not allowed")
                case .cloudServiceNetworkConnectionFailed: print("Could not connect to the network")
                case .cloudServiceRevoked: print("User has revoked permission to use this cloud service")
                default: print((error as NSError).localizedDescription)
                }
            }
        }
    }
    @IBAction func startWeekSubscription(_ sender: UIButton) {
        SwiftyStoreKit.purchaseProduct("com.ioscleaner.proalexst.week", quantity: 1, atomically: true) { result in
            switch result {
            case .success(let purchase):
                UserDefService.setValue(true, forKey: "isPro")
                let vc = HomeController()
                vc.modalPresentationStyle = .fullScreen
                self.present(vc, animated: true, completion: nil)
            case .error(let error):
                switch error.code {
                case .unknown: print("Unknown error. Please contact support")
                case .clientInvalid: print("Not allowed to make the payment")
                case .paymentCancelled: break
                case .paymentInvalid: print("The purchase identifier was invalid")
                case .paymentNotAllowed: print("The device is not allowed to make the payment")
                case .storeProductNotAvailable: print("The product is not available in the current storefront")
                case .cloudServicePermissionDenied: print("Access to cloud service information is not allowed")
                case .cloudServiceNetworkConnectionFailed: print("Could not connect to the network")
                case .cloudServiceRevoked: print("User has revoked permission to use this cloud service")
                default: print((error as NSError).localizedDescription)
                }
            }
        }
    }
    @IBAction func goBack(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    
}

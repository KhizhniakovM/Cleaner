//
//  SettingsVC.swift
//  SmartCleaner
//
//  Created by Luchik on 01.06.2020.
//  Copyright © 2020 Luchik. All rights reserved.
//

import Foundation
import UIKit
import Alertift
import SwiftyUserDefaults
import FirebaseRemoteConfig
import StoreKit

class SettingsVC: BaseController {
    // MARK: - UI
    @IBOutlet weak var passwordSwitch: UISwitch!
    @IBOutlet weak var bioSwitch: UISwitch!
    @IBOutlet weak var onMailButton: UIStackView!
    @IBOutlet weak var onRateButton: UIStackView!
    @IBOutlet weak var onShareButton: UIStackView!
    @IBOutlet weak var onRestoreButton: UIStackView!
    
    // MARK: - Properties
    var remoteConfig: RemoteConfig?
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupButtons()
        remoteConfig = RemoteManager.remoteConfig()
    }
    
    // MARK: - Methods
    private func setupButtons() {
        onMailButton.isUserInteractionEnabled = true
        onMailButton.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(onMail)))
        onRateButton.isUserInteractionEnabled = true
        onRateButton.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(onRate)))
        onShareButton.isUserInteractionEnabled = true
        onShareButton.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(onShare)))
        onRestoreButton.isUserInteractionEnabled = true
        onRestoreButton.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(onRestore)))
    }
    
    // MARK: - @objc methods
    @objc
    private func onMail() {
        showProgressHUD(title: "Loading...")
        remoteConfig?.fetchAndActivate(completionHandler: {[weak self] (status, error) in
            guard let self = self, error == nil, let mail = self.remoteConfig?.configValue(forKey: "mail").stringValue, let url = URL(string: "mailto:\(mail)") else { return }
            self.hideProgressHUD()
            DispatchQueue.main.async {
                UIApplication.shared.open(url)
            }
        })
    }
    @objc
    private func onRate() {
        SKStoreReviewController.requestReview()
    }
    @objc
    private func onShare() {
        showProgressHUD(title: "Loading...")
        remoteConfig?.fetchAndActivate(completionHandler: {[weak self] (status, error) in
            guard let self = self, error == nil, let share = self.remoteConfig?.configValue(forKey: "share").stringValue, let url = URL(string: share) else { return }
            self.hideProgressHUD()
            let items = [url]
            let ac = UIActivityViewController(activityItems: items, applicationActivities: nil)
            DispatchQueue.main.async {
                self.present(ac, animated: true, completion: nil)
            }
        })
    }
    @objc
    private func onRestore() {
        
    }
}

//    private func setupToggles() {
//        bioSwitch.isOn = Defaults[\.bioAuth]
//        passwordSwitch.isOn = !Defaults[\.bioAuth]
//    }
//    @IBAction func onBioSwitched(_ sender: Any) {
//        Defaults[\.bioAuth] = bioSwitch.isOn
//        if passwordSwitch.isOn && bioSwitch.isOn {
//            passwordSwitch.isOn = false
//        }
//    }
//    @IBAction func onPasswordSwitched(_ sender: Any) {
//        if passwordSwitch.isOn {
//            Alertift.alert(title: "Password", message: "Enter the password")
//                .textField(){ textField in
//                    textField.placeholder = "Password"
//                }
//                .action(.cancel("Cancel")){
//                    self.passwordSwitch.isOn = false
//                }
//                .action(.default("Done")) { (_, _, textFields) in
//                    let password = textFields?.first?.text ?? ""
//                    self.passwordSwitch.isOn = true
//                    Defaults[\.password] = password
//                    Defaults[\.bioAuth] = false
//                    self.bioSwitch.isOn = false
//                    print(Defaults[\.password])
//                }
//                .show(on: self, completion: nil)
//        } else {
//            bioSwitch.isOn = true
//            Defaults[\.bioAuth] = true
//        }
//    }

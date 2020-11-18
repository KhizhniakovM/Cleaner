//
//  HomeController.swift
//  SmartCleaner
//
//  Created by Luchik on 20.05.2020.
//  Copyright © 2020 Luchik. All rights reserved.
//

import Foundation
import UIKit
import BiometricAuthentication
import SwiftyUserDefaults
import Alertift
import CircleProgressBar

class HomeController: BaseController{
    // MARK: - UI
    @IBOutlet weak var contactClearView: UIImageView!
    @IBOutlet weak var videoClearView: UIImageView!
    @IBOutlet weak var photoClearView: UIImageView!
    @IBOutlet weak var smartCleaningView: UIView!
    @IBOutlet weak var circleProgressView: CircleProgressView!
    @IBOutlet weak var spaceLabel: UILabel!
    @IBOutlet weak var percentLabel: UILabel!
//    @IBOutlet weak var proButton: UIBarButtonItem!
    @IBOutlet weak var mainStack: UIStackView!
    @IBOutlet weak var mainCircle: CircleProgressBar!
    @IBOutlet weak var proButton: UIButton!
    
    // MARK: - Properties
    private var lastGroups: [PHAssetGroup] = []
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        addTouches()
        setupSpace()
        openPaywall()
    }
    // MARK: - Methods
    private func openPaywall() {
        guard UserDefService.takeValue("isPro") == false else { return }
        self.performSegue(withIdentifier: "SubscriptionSegue", sender: self)
    }
    private func addTouches() {
        smartCleaningView.isUserInteractionEnabled = true
        smartCleaningView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(onSmartCleaning)))
        photoClearView.isUserInteractionEnabled = true
        photoClearView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(onPhotoClear)))
        videoClearView.isUserInteractionEnabled = true
        videoClearView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(onVideoClear)))
        contactClearView.isUserInteractionEnabled = true
        contactClearView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(onContactClear)))
    }
    private func setupUI() {
        guard UserDefService.takeValue("isPro") == true else { return }
        proButton.isHidden = true
    }
    private func setupSpace() {
        let used = UIDevice.current.usedDiskSpaceInGB
        let total = UIDevice.current.totalDiskSpaceInGB
        let percentage: Int = Int(Double(UIDevice.current.usedDiskSpaceInBytes) / Double(UIDevice.current.totalDiskSpaceInBytes) * 100.0)
        
        percentLabel.text = "\(percentage)"
        spaceLabel.text = "\(used) out of \(total)"
        
        circleProgressView.value = percentage
    }
    
    @IBAction func onSettings(_ sender: UIButton) {
        self.performSegue(withIdentifier: "Settings", sender: self)
    }
    @IBAction func onSubscription(_ sender: UIButton) {
        self.performSegue(withIdentifier: "SubscriptionSegue", sender: self)
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "VideoListSegue", let vc = segue.destination as? GroupedAssetListVC {
            vc.assetGroups = lastGroups
            vc.isVideos = true
        }
    }
    // MARK: - @objc methods
    @objc
    private func onSmartCleaning() {
        self.performSegue(withIdentifier: "StartScanSegue", sender: self)
    }
    @objc
    private func onPhotoClear() {
        self.performSegue(withIdentifier: "PhotoClearSegue", sender: self)
    }
    @objc
    private func onVideoClear() {
        showProgressHUD(title: "Searching related videos...")
        MediaManager.loadSimilarVideos(){ [weak self] groups in
            guard let self = self else { return }
            self.hideProgressHUD()
            self.lastGroups = groups
            self.performSegue(withIdentifier: "VideoListSegue", sender: self)
        }
    }
    @objc
    private func onContactClear() {
        self.performSegue(withIdentifier: "ContactClearSegue", sender: self)
    }
    
}

//    @IBAction func onSecretVault(_ sender: UIBarButtonItem) {
//        if Defaults[\.bioAuth]{
//            DispatchQueue.main.async{
//                BioMetricAuthenticator.authenticateWithBioMetrics(reason: "") { (result) in
//                    switch result {
//                    case .success:
//                        self.performSegue(withIdentifier: "SecretVaultSegue", sender: self)
//                    case .failure:
//                        print("Authentication Failed")
//                    }
//                }
//            }
//        } else {
//             Alertift.alert(title: "Password", message: "Enter the password")
//             .textField(){ textField in
//                 textField.placeholder = "Password"
//             }
//             .action(.cancel("Cancel")){}
//             .action(.default("Done")) { (_, _, textFields) in
//                let password = textFields?.first?.text ?? ""
//                if Defaults[\.password] == password{
//                    self.performSegue(withIdentifier: "SecretVaultSegue", sender: self)
//                }
//             }
//            .show(on: self, completion: nil)
//        }
//    }

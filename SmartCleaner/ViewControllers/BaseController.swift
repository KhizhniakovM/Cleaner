//
//  ViewController.swift
//  SmartCleaner
//
//  Created by Luchik on 19.05.2020.
//  Copyright © 2020 Luchik. All rights reserved.
//

import UIKit
import JGProgressHUD
import GoogleMobileAds

class BaseController: UIViewController {
    override var preferredStatusBarStyle: UIStatusBarStyle { return .lightContent }
    // MARK: - AdMob
    lazy var banner: GADBannerView = {
        let banner = GADBannerView(adSize: kGADAdSizeSmartBannerPortrait)
        banner.translatesAutoresizingMaskIntoConstraints = false
        banner.adUnitID = "ca-app-pub-8003021318299677/5699240628"
//        banner.adUnitID = "ca-app-pub-3940256099942544/2934735716"
        banner.rootViewController = self
        return banner
    }()
    lazy var inter: GADInterstitial = {
        let inter = GADInterstitial(adUnitID: "ca-app-pub-8003021318299677/3073077285")
//        let inter = GADInterstitial(adUnitID: "ca-app-pub-3940256099942544/4411468910")
        return inter
    }()
    // MARK: - Properties
    private lazy var progressHUD: JGProgressHUD = {
        let hud = JGProgressHUD(style: .light)
        hud.textLabel.font = UIFont(name: "SFUIText-Regular", size: 17)
        hud.textLabel.textColor = UIColor(named: "text")
        hud.contentView.backgroundColor = .white
        return hud
    }()
    private lazy var HUD: JGProgressHUD = {
        let hud = JGProgressHUD(style: .light)
        hud.textLabel.font = UIFont(name: "SFUIText-Regular", size: 17)
        hud.textLabel.textColor = UIColor(named: "text")
        hud.contentView.backgroundColor = .white
        hud.indicatorView = JGProgressHUDErrorIndicatorView()
        return hud
    }()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupAllUI()

    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        if UserDefService.takeValue("isPro") == false {
            // AdMob
            banner.load(GADRequest())
            inter.load(GADRequest())
            addBanner()
        }
    }
    
    // MARK: - Methods
    func addBanner() {
        self.view.addSubview(banner)
        
        NSLayoutConstraint.activate([
            banner.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            banner.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }
    func addInter() {}
    
    private func setupAllUI() {
        self.view.get(all: UIView.self).filter({ $0.tag == 201 }).forEach({
            $0.roundCorners(corners: .allCorners, radius: 10.0)
        })
        self.view.get(all: UIImageView.self).filter({ $0.tag == 202 }).forEach({
            $0.roundCorners(corners: [.topRight, .bottomRight], radius: 10.0)
        })
        self.view.get(all: UINavigationBar.self).forEach({
            if let topItem = $0.topItem, let leftBarButtonItem = topItem.leftBarButtonItem, leftBarButtonItem.tag == 301 {
                leftBarButtonItem.action = #selector(self.onBack)
                leftBarButtonItem.target = self
            }
        })
        self.view.get(all: UISegmentedControl.self).forEach({
            segmentedControl in
            let titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
            segmentedControl.setTitleTextAttributes(titleTextAttributes, for: .normal)
            segmentedControl.setTitleTextAttributes(titleTextAttributes, for: .selected)
        })
    }
    public func showProgressHUD(title: String){
        progressHUD.textLabel.text = title
        progressHUD.show(in: self.view, animated: true)
    }
    public func hideProgressHUD() {
        progressHUD.dismiss()
    }
    public func showTextHUD(title: String) {
        HUD.textLabel.text = title
        HUD.show(in: self.view)
    }
    public func hideTextHUD(afterDelay: Double) {
        HUD.dismiss(afterDelay: afterDelay)
    }
    // MARK: - @objc methods
    @objc func onBack(){
        self.navigationController?.popViewController(animated: true)
    }

}


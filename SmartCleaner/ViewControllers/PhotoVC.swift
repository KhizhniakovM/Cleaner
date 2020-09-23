//
//  PhotoVC.swift
//  SmartCleaner
//
//  Created by Luchik on 21.05.2020.
//  Copyright © 2020 Luchik. All rights reserved.
//

import Foundation
import UIKit
import Photos
import CocoaImageHashing
import JGProgressHUD

class PhotoVC: BaseController{
    // MARK: - UI
    @IBOutlet weak var selfiePhotosBlock: UIImageView!
    @IBOutlet weak var gifPhotosBlock: UIImageView!
    @IBOutlet weak var screenshotPhotosBlock: UIImageView!
    @IBOutlet weak var duplicatePhotosBlock: UIImageView!
    @IBOutlet weak var similarPhotosBlock: UIImageView!
    @IBOutlet weak var photoCountLabel: UILabel!
    @IBOutlet weak var mainStack: UIStackView!
    // MARK: - Properties
    private var lastAssetGroups: [PHAssetGroup] = []
    private var lastAssets: [PHAsset] = []
    // MARK:- Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        fetchPhotos()
        addButtons()
    }
    // MARK: - Methods
    override func addInter() {
        if UserDefaults.standard.object(forKey: "isFirstPhoto") == nil {
            UserDefaults.standard.set(false, forKey: "isFirstPhoto")
        } else {
            guard inter.isReady == true else { return }
                inter.present(fromRootViewController: self)
        }
    }
    private func fetchPhotos(){
        let photos = PHPhotoLibrary.authorizationStatus()
        if photos == .notDetermined {
            PHPhotoLibrary.requestAuthorization({status in
                if status == .authorized {
                    self.fetchPhotos()
                }
            })
            return
        }
        MediaManager.fetchPhotoCount({ count in
            DispatchQueue.main.async{
                self.photoCountLabel.text = "\(count) images"
            }
        })
    }
    private func addButtons() {
        similarPhotosBlock.isUserInteractionEnabled = true
        similarPhotosBlock.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.onSimilarPhotos)))
        screenshotPhotosBlock.isUserInteractionEnabled = true
        screenshotPhotosBlock.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.onScreenshotPhotos)))
        gifPhotosBlock.isUserInteractionEnabled = true
        gifPhotosBlock.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.onGifPhotos)))
        selfiePhotosBlock.isUserInteractionEnabled = true
        selfiePhotosBlock.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.onSelfiePhotos)))
        duplicatePhotosBlock.isUserInteractionEnabled = true
        duplicatePhotosBlock.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.onDuplicatePhotos)))
    }
    // MARK: - @objc methods
    @objc private func onSimilarPhotos() {
        addInter()
        showProgressHUD(title: "Searching similar photos...")
        MediaManager.loadSimilarPhotos(live: true, {[weak self] assetGroups in
            guard let self = self else { return }
            self.hideProgressHUD()
            if assetGroups.count == 0 {
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    self.showTextHUD(title: "Nothing found")
                    self.hideTextHUD(afterDelay: 1)
                }
                return
            }
            self.lastAssetGroups = assetGroups
            self.performSegue(withIdentifier: "GroupedPhotoListSegue", sender: self)
        })
    }

    @objc private func onScreenshotPhotos(){
        MediaManager.loadScreenshotPhotos({
            assets in
            if assets.count == 0{
                self.showTextHUD(title: "Nothing found")
                self.hideTextHUD(afterDelay: 1)
                return
            }
            self.lastAssets = assets
            self.performSegue(withIdentifier: "PhotoListSegue", sender: self)
        })
    }
    
    @objc private func onGifPhotos(){
        MediaManager.loadGifPhotos({
            assets in
            if assets.count == 0{
                self.showTextHUD(title: "Nothing found")
                self.hideTextHUD(afterDelay: 1)
                return
            }
            self.lastAssets = assets
            self.performSegue(withIdentifier: "PhotoListSegue", sender: self)
        })
    }

    @objc private func onSelfiePhotos(){
        MediaManager.loadSelfiePhotos({
            assets in
            if assets.count == 0 {
                self.showTextHUD(title: "Nothing found")
                self.hideTextHUD(afterDelay: 1)
                return
            }
            self.lastAssets = assets
            self.performSegue(withIdentifier: "PhotoListSegue", sender: self)
        })
    }
    
    @objc private func onDuplicatePhotos(){
        addInter()
        showProgressHUD(title: "Searching duplicate photos...")
        MediaManager.loadDuplicatePhotos({[weak self] assetGroups in
            guard let self = self else { return }
            self.hideProgressHUD()
            if assetGroups.count == 0 {
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    self.showTextHUD(title: "Nothing found")
                    self.hideTextHUD(afterDelay: 1)
                }
                return
            }
            self.lastAssetGroups = assetGroups
            self.performSegue(withIdentifier: "GroupedPhotoListSegue", sender: self)
        })
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "PhotoListSegue", let vc = segue.destination as? AssetListVC{
            vc.assets = lastAssets
        }
        else if segue.identifier == "GroupedPhotoListSegue", let vc = segue.destination as? GroupedAssetListVC{
            vc.assetGroups = lastAssetGroups
        }
    }
}

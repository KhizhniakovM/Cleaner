//
//  ScanSearchVC.swift
//  SmartCleaner
//
//  Created by Max Khizhniakov on 14.09.2020.
//  Copyright © 2020 Luchik. All rights reserved.
//

import Foundation
import UIKit
import CircleProgressBar
import Photos
import Contacts

class ScanSearchVC: BaseController {
    // MARK: - UI
    @IBOutlet weak var searchLabel: UILabel!
    @IBOutlet weak var circleProgressView: CircleProgressBar!
    
    // MARK: - Properties
    var scanOptions: [Options]?
    
    var dateTo: String?
    var dateFrom: String?
    
    var similarPhotos: [PHAssetGroup]?
    var similarLivePhotos: [PHAssetGroup]?
    var screenshots: [PHAsset]?
    var videos: [PHAssetGroup]?
    var contacts: [CNContactSection]?
    var sections: [CNContactSection]?
    
    var vc: UIViewController?
    
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        startScan()
    }
    
    // MARK: - Methods
    private func setupUI() {
        circleProgressView.hintTextFont = UIFont(name: "SFUIText-Bold", size: 20)
        searchLabel.text = "Searching..."
    }
    
    private func startScan() {
        guard let scanOptions = scanOptions, let dateTo = dateTo, let dateFrom = dateFrom else { return }
        ScanManager.start(scanOptions, from: dateFrom, to: dateTo,
                          handler: {self.scanOptions = $0},
                          similarPhotos: {self.similarPhotos = $0; self.circleProgressView.setProgress(0.6, animated: true, duration: 0.5)},
                          similarLivePhotos: {self.similarLivePhotos = $0; self.circleProgressView.setProgress(0.6, animated: true, duration: 0.5)},
                          screenshots: {self.screenshots = $0; self.circleProgressView.setProgress(0.2, animated: true, duration: 0.5) },
                          videos: {self.videos = $0; self.circleProgressView.setProgress(0.3, animated: true, duration: 0.5)},
                          emptyContacts: {self.sections = $0},
                          duplicateContacts: {self.contacts = $0}) {
            self.circleProgressView.setProgress(1, animated: true, duration: 1)
            DispatchQueue.main.async {
                self.searchLabel.text = "Finish!"
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                self.performSegue(withIdentifier: "ScanResultSegue", sender: nil)
            }
        }
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard segue.identifier == "ScanResultSegue" else { return }
        let vc = segue.destination as? ScanResultVC
        vc?.scanOptions = self.scanOptions
        vc?.similarPhotos = self.similarPhotos
        vc?.similarLivePhotos = self.similarLivePhotos
        vc?.screenshots = self.screenshots
        vc?.videos = self.videos
        vc?.vc = self.vc
        vc?.contacts = self.contacts
        vc?.sections = self.sections
    }

    
}
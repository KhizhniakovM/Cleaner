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
    var scanManager = ScanManager()
    
    var dateTo: String?
    var dateFrom: String?
    
    var similarPhotos: [PHAssetGroup]?
    var similarLivePhotos: [PHAssetGroup]?
    var screenshots: [PHAsset]?
    var videos: [PHAssetGroup]?
    var contacts: [CNContactSection]?
    var sections: [CNContactSection]?
    var allPhotos = 0
    
    var vc: UIViewController?
    
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUIforIt()
        startScan()
        scanManager.mediaManager.delegate = self
        MediaManager.fetchPhotoCount(from: dateFrom!, to: dateTo!) { (x) in
            self.allPhotos = x
        }
    }
    
    // MARK: - Methods
    private func setupUIforIt() {
        circleProgressView.hintTextFont = UIFont(name: "SFUIText-Medium", size: 45)
        searchLabel.text = "Searching..."
    }
    
    private func startScan() {
        guard let scanOptions = scanOptions, let dateTo = dateTo, let dateFrom = dateFrom else { return }
        scanManager.start(scanOptions, from: dateFrom, to: dateTo,
                          handler: {self.scanOptions = $0},
                          similarPhotos: {self.similarPhotos = $0
                            if self.circleProgressView.progress < 0.5 {
                                self.circleProgressView.setProgress(0.66, animated: true, duration: 4)}},
                          similarLivePhotos: {self.similarLivePhotos = $0
                            if self.circleProgressView.progress < 0.5 {
                                self.circleProgressView.setProgress(0.66, animated: true, duration: 4)}},
                          screenshots: {self.screenshots = $0
                            if self.circleProgressView.progress < 0.3 {
                                self.circleProgressView.setProgress(0.33, animated: true, duration: 2)} },
                          videos: {self.videos = $0
                            if self.circleProgressView.progress < 0.3 {
                                self.circleProgressView.setProgress(0.33, animated: true, duration: 2)}},
                          emptyContacts: {self.sections = $0},
                          duplicateContacts: {self.contacts = $0}) {
                            DispatchQueue.main.async {
                                self.circleProgressView.setProgress(1, animated: true, duration: 1.5)
                            }
                            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                                self.searchLabel.text = "Finish!"
                            }
                            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
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

extension ScanSearchVC: MediaManagerDelegate {
    func showPercentage(number: Int) {
        DispatchQueue.main.async {
            self.searchLabel.text = "Check photo \(number)/\(self.allPhotos)"
        }
    }
}

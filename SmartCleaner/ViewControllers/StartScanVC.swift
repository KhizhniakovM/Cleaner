//
//  StartScanVC.swift
//  SmartCleaner
//
//  Created by Luchik on 21.05.2020.
//  Copyright © 2020 Luchik. All rights reserved.
//

import Foundation
import UIKit
import RLBAlertsPickers
import SwiftDate
import Photos

class StartScanVC: BaseController{
    // MARK: - UI
    @IBOutlet weak var startScanBtn: UIImageView!
    @IBOutlet weak var ok6: UIImageView!
    @IBOutlet weak var ok5: UIImageView!
    @IBOutlet weak var ok4: UIImageView!
    @IBOutlet weak var ok3: UIImageView!
    @IBOutlet weak var ok2: UIImageView!
    @IBOutlet weak var ok1: UIImageView!
    @IBOutlet weak var scan6: UIView!
    @IBOutlet weak var scan5: UIView!
    @IBOutlet weak var scan4: UIView!
    @IBOutlet weak var scan3: UIView!
    @IBOutlet weak var scan2: UIView!
    @IBOutlet weak var scan1: UIView!
    @IBOutlet weak var dateToLabel: UILabel!
    @IBOutlet weak var dateFromLabel: UILabel!
    @IBOutlet weak var mainStack: UIStackView!
    
    // MARK: - Properties
    private var lastMonth: String?
    private var lastYear: String?
    private var totalSize: Int64 = 0
    private var scanOptions: [Options] = []
    
    private var dateTo: String?
    private var dateFrom: String?

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    // MARK: - Methods
    override func addInter() {
        if UserDefaults.standard.object(forKey: "isFirstScan") == nil {
            UserDefaults.standard.set(false, forKey: "isFirstScan")
        } else {
            guard inter.isReady == true else { return }
                inter.present(fromRootViewController: self)
        }
    }
    private func setupUI() {
        dateToLabel.text = takeStringFromDate()
        dateToLabel.isUserInteractionEnabled = true
        dateToLabel.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.onDateTo)))
        dateFromLabel.isUserInteractionEnabled = true
        dateFromLabel.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.onDateFrom)))
        let scans = [scan1, scan2, scan3, scan4, scan5, scan6]
        let oks = [ok1, ok2, ok3, ok4, ok5, ok6]
        for i in 1...6{
            scans[i - 1]!.isUserInteractionEnabled = true
            scans[i - 1]!.addGestureRecognizer(ScanTapGestureRecognizer(target: self, action: #selector(self.onScanClicked(_:)), num: i - 1))
            oks[i - 1]!.image = UIImage(named: "Ok")
        }
        startScanBtn.isUserInteractionEnabled = true
        startScanBtn.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.onStartScan)))
    }
    private func takeStringFromDate() -> String {
        let now = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "LLL"
        let nameOfMonth = dateFormatter.string(from: now)
        let year = Calendar.current.component(.year, from: now)
        return "\(nameOfMonth), \(year) ▼"
    }
    
    // MARK: - @objc methods
    @objc private func onStartScan(){
        let photos = PHPhotoLibrary.authorizationStatus()
        if photos == .notDetermined {
            PHPhotoLibrary.requestAuthorization({status in
                if status == .authorized{
                    DispatchQueue.main.async{
                        self.onStartScan()
                    }
                }
            })
            return
        }
        if let dateTo = self.dateToLabel.text!.replacingOccurrences(of: " ▼", with: "").toDate("MMM, yyyy"), let dateFrom = self.dateFromLabel.text!.replacingOccurrences(of: " ▼", with: "").toDate("MMM, yyyy"), dateTo > dateFrom, !self.scanOptions.isEmpty {
            let x = dateTo.addingTimeInterval(2678400)
            
            self.dateFrom = dateFrom.toFormat("dd-MM-yyyy")
            self.dateTo = x.toFormat("dd-MM-yyyy")
            
            self.addInter()
            self.performSegue(withIdentifier: "ScanSearchSegue", sender: self)

        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard segue.identifier == "ScanSearchSegue" else { return }
        let vc = segue.destination as! ScanSearchVC
        vc.dateTo = self.dateTo
        vc.dateFrom = self.dateFrom
        vc.scanOptions = self.scanOptions
        vc.vc = self
    }
    
    @objc private func onScanClicked(_ recognizer: ScanTapGestureRecognizer){
        let oks = [ok1, ok2, ok3, ok4, ok5, ok6]
        oks[recognizer.num]!.image = oks[recognizer.num]!.image == UIImage(named: "Ok") ? UIImage(named: "Ok2") : UIImage(named: "Ok")
        if recognizer.num == 0{
            scanOptions.contains(.similarPhotos) ? scanOptions = scanOptions.filter({ $0 != .similarPhotos }) : scanOptions.append(.similarPhotos)
        }
        if recognizer.num == 1{
            scanOptions.contains(.screenshots) ? scanOptions = scanOptions.filter({ $0 != .screenshots }) : scanOptions.append(.screenshots)
        }
        if recognizer.num == 2{
            scanOptions.contains(.relatedVideos) ? scanOptions = scanOptions.filter({ $0 != .relatedVideos }) : scanOptions.append(.relatedVideos)
        }
        if recognizer.num == 3{
            scanOptions.contains(.similarLivePhotos) ? scanOptions = scanOptions.filter({ $0 != .similarLivePhotos }) : scanOptions.append(.similarLivePhotos)
        }
        if recognizer.num == 4{
            scanOptions.contains(.emptyContacts) ? scanOptions = scanOptions.filter({ $0 != .emptyContacts }) : scanOptions.append(.emptyContacts)
        }
        if recognizer.num == 5{
            scanOptions.contains(.duplicateContacts) ? scanOptions = scanOptions.filter({ $0 != .duplicateContacts }) : scanOptions.append(.duplicateContacts)
        }
    }
    @objc private func onDateTo(){
        let alert = UIAlertController(style: .actionSheet, title: "Select date", message: "")

        let pickerViewValues: [[String]] = [["January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"],
        ["2010", "2011", "2012", "2013", "2014", "2015", "2016", "2017", "2018", "2019", "2020"]]
        let pickerViewSelectedValue: PickerViewViewController.Index = (column: 4, row: 9)
        self.lastMonth = self.dateToLabel.text!.components(separatedBy: ", ")[0]
        self.lastYear = self.dateToLabel.text!.components(separatedBy: ", ")[1].replacingOccurrences(of: " ▼", with: "")

        alert.addPickerView(values: pickerViewValues, initialSelection: pickerViewSelectedValue) { vc, picker, index, values in
            if index.column == 0{
                self.lastMonth = values[index.column][index.row]
            }
            else if index.column == 1{
                self.lastYear = values[index.column][index.row]
            }
        }
        alert.addAction(title: "Done", style: .cancel){ _ in
            if self.lastYear != nil && self.lastMonth != nil{
                self.dateToLabel.text = "\(self.lastMonth![..<String.Index(encodedOffset: 3)]), \(self.lastYear!) ▼"
            }
            self.lastYear = nil
            self.lastMonth = nil
        }
        self.present(alert, animated: true, completion: nil)
    }
    @objc private func onDateFrom(){
        let alert = UIAlertController(style: .actionSheet, title: "Select date", message: "")

        let pickerViewValues: [[String]] = [["January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"],
        ["2010", "2011", "2012", "2013", "2014", "2015", "2016", "2017", "2018", "2019", "2020"]]
        let pickerViewSelectedValue: PickerViewViewController.Index = (column: 8, row: 9)
        self.lastMonth = self.dateFromLabel.text!.components(separatedBy: ", ")[0]
        self.lastYear = self.dateFromLabel.text!.components(separatedBy: ", ")[1].replacingOccurrences(of: " ▼", with: "")
        
        alert.addPickerView(values: pickerViewValues, initialSelection: pickerViewSelectedValue) { vc, picker, index, values in
            if index.column == 0{
                self.lastMonth = values[index.column][index.row]
            }
            else if index.column == 1{
                self.lastYear = values[index.column][index.row]
            }
        }
        alert.addAction(title: "Done", style: .cancel){ _ in
            if self.lastYear != nil && self.lastMonth != nil{
                self.dateFromLabel.text = "\(self.lastMonth![..<String.Index(encodedOffset: 3)]), \(self.lastYear!) ▼"
            }
            self.lastYear = nil
            self.lastMonth = nil
        }
        self.present(alert, animated: true, completion: nil)
    }
}

//
//  ScanResultVC.swift
//  SmartCleaner
//
//  Created by Luchik on 31.05.2020.
//  Copyright © 2020 Luchik. All rights reserved.
//

import Foundation
import UIKit
import Photos
import Contacts

class ScanResultVC: BaseController {
    // MARK: - Properties
    var scanOptions: [Options]?
    
    var similarPhotos: [PHAssetGroup]?
    var similarLivePhotos: [PHAssetGroup]?
    var screenshots: [PHAsset]?
    var videos: [PHAssetGroup]?
    var contacts: [CNContactSection]?
    var sections: [CNContactSection]?
    
    var vc: UIViewController?
    
    // MARK: - UI
    @IBOutlet weak var navBar: UINavigationBar!
    lazy private var tableView: UITableView = {
        let tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.register(UINib(nibName: "ScanResultTableViewCell", bundle: nil), forCellReuseIdentifier: "cell")
        return tableView
    }()

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        
        setupUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        tableView.reloadData()
    }
    
    // MARK: - Methods
    private func setupUI() {
        self.view.addSubview(tableView)
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: self.navBar.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),
        ])
    }
    override func onBack() {
        guard let vc = vc else { return }
        self.navigationController?.popToViewController(vc, animated: true)
    }
        // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier {
        case "GroupedAsset1":
            let vc = segue.destination as? GroupedAssetListVC
            vc?.assetGroups = self.similarPhotos!
            vc?.grouped = .similarPhotos
            vc?.delegate = self
            vc?.smartClean = true
        case "GroupedAsset2":
            let vc = segue.destination as? GroupedAssetListVC
            vc?.assetGroups = self.similarLivePhotos!
            vc?.grouped = .similarLivePhotos
            vc?.delegate = self
            vc?.smartClean = true
        case "GroupedAsset3":
            let vc = segue.destination as? GroupedAssetListVC
            vc?.assetGroups = self.videos!
            vc?.grouped = .videos
            vc?.delegate = self
            vc?.smartClean = true
        case "SimpleAsset":
            let vc = segue.destination as? AssetListVC
            vc?.delegate = self
            vc?.assets = self.screenshots!
            vc?.smartClean = true
        case "IncompliteContacts":
            let vc = segue.destination as? IncompleteContactListVC
            vc?.sections = self.sections!
            vc?.delegate = self
            vc?.smartClean = true
        case "DuplicateContacts":
            let vc = segue.destination as? DuplicateContactListVC
            vc?.duplicateType = .byPhone
            vc?.sections = self.contacts!
            vc?.delegate = self
            vc?.smartClean = true
        default:
            print("ci")
        }
    }
}

// MARK: - Extensions
extension ScanResultVC: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let cell = tableView.cellForRow(at: indexPath) as? ScanResultTableViewCell
        switch cell?.label.text {
        case "Similar photos":
            performSegue(withIdentifier: "GroupedAsset1", sender: nil)
        case "Screenshots":
            performSegue(withIdentifier: "SimpleAsset", sender: nil)
        case "Videos":
            performSegue(withIdentifier: "GroupedAsset3", sender: nil)
        case "Similar live photos":
            performSegue(withIdentifier: "GroupedAsset2", sender: nil)
        case "Empty contacts":
            performSegue(withIdentifier: "IncompliteContacts", sender: nil)
        case "Duplicate contacts":
            performSegue(withIdentifier: "DuplicateContacts", sender: nil)
        default:
            cell?.resultLabel.text = "0"
        }
    }
}
extension ScanResultVC: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let scanOptions = scanOptions else { return 0 }
        return scanOptions.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell") as? ScanResultTableViewCell
        cell?.label.text = scanOptions?[indexPath.row].name()
        switch cell?.label.text {
        case "Similar photos":
            cell?.resultLabel.text = "\(similarPhotos?.count ?? 0) photo groups"
        case "Screenshots":
            cell?.resultLabel.text = "\(screenshots?.count ?? 0) screenshots"
        case "Videos":
            cell?.resultLabel.text = "\(videos?.count ?? 0) video groups"
        case "Similar live photos":
            cell?.resultLabel.text = "\(similarLivePhotos?.count ?? 0) photo groups"
        case "Empty contacts":
            cell?.resultLabel.text = "\(sections?[0].contacts.count ?? 0) empty contacts"
        case "Duplicate contacts":
            cell?.resultLabel.text = "\(contacts?.count ?? 0) contact groups"
        default:
            cell?.resultLabel.text = "0"
        }
        
        return cell!
    }
}

extension ScanResultVC: AssetListDelegate {
    func deleteAsset(id: [String]) {
        self.screenshots = self.screenshots?.filter({ !id.contains($0.localIdentifier) })
    }
}
extension ScanResultVC: GroupedAssetListDelegate {
    func delete(id: [String], grouped: Grouped) {
        switch grouped {
        case .similarPhotos:
            for group in self.similarPhotos!{
                group.assets = group.assets.filter({ !id.contains($0.localIdentifier) })
            }
            self.similarPhotos = self.similarPhotos?.filter({$0.assets.count != 0})
        case .similarLivePhotos:
            for group in self.similarLivePhotos!{
                group.assets = group.assets.filter({ !id.contains($0.localIdentifier) })
            }
            self.similarLivePhotos = self.similarLivePhotos?.filter({$0.assets.count != 0})
        case .videos:
            for group in self.videos!{
                group.assets = group.assets.filter({ !id.contains($0.localIdentifier) })
            }
            self.videos = self.videos?.filter({$0.assets.count != 0})
        }
    }
}
extension ScanResultVC: IncompliteListDelegate {
    func delete(contact: [CNContact]) {
        self.sections?.forEach({ $0.contacts = $0.contacts.filter({ !contact.contains($0) }) })
    }
}
extension ScanResultVC: DuplicateDelegate {
    func delete(ip: [CNContact]) {
        self.contacts?.forEach({$0.contacts = $0.contacts.filter({!ip.contains($0)})})
        self.contacts = self.contacts?.filter({$0.contacts.count != 0})
    }
}

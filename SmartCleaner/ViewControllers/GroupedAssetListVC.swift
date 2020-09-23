//
//  GroupedAssetListVC.swift
//  SmartCleaner
//
//  Created by Luchik on 08.06.2020.
//  Copyright © 2020 Luchik. All rights reserved.
//

import Foundation
import UIKit
import Photos
import Alertift

enum Grouped {
    case similarPhotos, similarLivePhotos, videos
}

class GroupedAssetListVC: BaseController{
    // MARK: - UI
    @IBOutlet weak var navbar: UINavigationBar!
    @IBOutlet weak var collectionView: UICollectionView!
    
    // MARK: - Properties
    var grouped: Grouped?
    weak var delegate: GroupedAssetListDelegate?
    public var assetGroups: [PHAssetGroup] = []
    private var checkedPhotos: [PHAsset] = []
    var smartClean: Bool?
    let columnLayout = ColumnFlowLayout(
        cellsPerRow: 3,
        minimumInteritemSpacing: 10,
        minimumLineSpacing: 10,
        sectionInset: UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
    )
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCollectionView()
        self.navbar.topItem?.title = "Nothing selected"
    }
    
    // MARK: - Methods
    private func openPaywall() {
        guard smartClean ?? false else { return }
        self.performSegue(withIdentifier: "SubscriptionSegue", sender: self)
    }
    fileprivate func setupCollectionView() {
        collectionView.register(UINib(nibName: "PhotoCell", bundle: nil), forCellWithReuseIdentifier: "PhotoCell")
        collectionView.delegate = self
        collectionView.dataSource = self
        columnLayout.headerReferenceSize = CGSize(width: self.view.frame.width, height: 40.0)
        collectionView.collectionViewLayout = columnLayout
        collectionView.reloadData()
    }
    
    @IBAction func onDelete(_ sender: Any) {
        let assetIdentifiers = checkedPhotos.map({ $0.localIdentifier })
        delegate?.delete(id: assetIdentifiers, grouped: self.grouped ?? .similarPhotos)
        let assets = PHAsset.fetchAssets(withLocalIdentifiers: assetIdentifiers, options: nil)
        PHPhotoLibrary.shared().performChanges({
            PHAssetChangeRequest.deleteAssets(assets)
        }, completionHandler: { (success, error) in
            DispatchQueue.main.async{
                if success{
                    for group in self.assetGroups {
                        group.assets = group.assets.filter({ !assetIdentifiers.contains($0.localIdentifier) })
                    }
                    self.assetGroups = self.assetGroups.filter({$0.assets.count != 0})
                }
                self.checkedPhotos = []
                self.collectionView.reloadData()
                self.navbar.topItem?.title = "Nothing selected"
                self.openPaywall()
            }
        })    }
    
    @IBAction func onSelectMore(_ sender: Any) {
        Alertift.actionSheet()
        .backgroundColor(UIColor(rgb: 0xEFF5FF))
        .action(.default("Select all")) {
            var allAssets: [PHAsset] = []
            for group in self.assetGroups{
                allAssets.append(contentsOf: group.assets)
            }
            self.checkedPhotos = allAssets
            self.navbar.topItem?.title = "\(self.checkedPhotos.count == 0 ? "Nothing" : "\(self.checkedPhotos.count)") selected"
            self.collectionView.reloadData()
        }
        .action(.default("Select all except best")) {
            var allAssets: [PHAsset] = []
            for group in self.assetGroups{
                var assets = group.assets
                assets.removeFirst()
                allAssets.append(contentsOf: assets)
            }
            self.checkedPhotos = allAssets
            self.navbar.topItem?.title = "\(self.checkedPhotos.count == 0 ? "Nothing" : "\(self.checkedPhotos.count)") selected"
            self.collectionView.reloadData()
        }
        .action(.destructive("Deselect all")) {
            self.checkedPhotos.removeAll()
            self.navbar.topItem?.title = "\(self.checkedPhotos.count == 0 ? "Nothing" : "\(self.checkedPhotos.count)") selected"
            self.collectionView.reloadData()
        }
        .action(.destructive("Cancel"))
        .show(on: self, completion: nil)
    }
}
// MARK: - Extensions
extension GroupedAssetListVC: UICollectionViewDelegate, UICollectionViewDataSource{
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return assetGroups.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return assetGroups[section].assets.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell: PhotoCell = collectionView.dequeueReusableCell(withReuseIdentifier: "PhotoCell", for: indexPath) as! PhotoCell
        cell.photoThumbnail.image = assetGroups[indexPath.section].assets[indexPath.row].hdImage
        cell.isChecked = self.checkedPhotos.contains(assetGroups[indexPath.section].assets[indexPath.row])
        cell.bestView.isHidden = indexPath.row != 0
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        switch kind {
        case UICollectionView.elementKindSectionHeader:
            let reusableview = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "GroupedAssetHeader", for: indexPath) as! GroupedAssetHeaderView
            reusableview.nameLabel.text = "\(assetGroups[indexPath.section].assets.count) items"
            reusableview.onChoose = {
                for asset in self.assetGroups[indexPath.section].assets{
                    if self.checkedPhotos.contains(asset){
                        self.checkedPhotos.removeAll(asset)
                        return
                    } else if !self.checkedPhotos.contains(asset){
                        self.checkedPhotos.append(asset)
                    }
                }
                self.navbar.topItem?.title = "\(self.checkedPhotos.count == 0 ? "Nothing" : "\(self.checkedPhotos.count)") selected"
                self.collectionView.reloadSections(IndexSet(integer: indexPath.section))
            }
            return reusableview
        default:  fatalError("Unexpected element kind")
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if self.checkedPhotos.contains(self.assetGroups[indexPath.section].assets[indexPath.row]){
            self.checkedPhotos = self.checkedPhotos.filter({ $0 != self.assetGroups[indexPath.section].assets[indexPath.row]})
        }
        else{
            self.checkedPhotos.append(self.assetGroups[indexPath.section].assets[indexPath.row])
        }
        self.navbar.topItem?.title = "\(self.checkedPhotos.count == 0 ? "Nothing" : "\(self.checkedPhotos.count)") selected"
        self.collectionView.reloadItems(at: [indexPath])
    }
    
    
}

protocol GroupedAssetListDelegate: class {
    func delete(id: [String], grouped: Grouped)
}

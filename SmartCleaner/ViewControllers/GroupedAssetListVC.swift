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
    private var assetsCount: Int = 0
    var smartClean: Bool?
    var isVideos: Bool = false
    let columnLayout = ColumnFlowLayout(
        cellsPerRow: 4,
        minimumInteritemSpacing: 1,
        minimumLineSpacing: 1,
        sectionInset: UIEdgeInsets(top: 0.5, left: 0.5, bottom: 0.5, right: 0.5)
    )
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        for i in assetGroups {
            assetsCount += i.assets.count
        }
        setupCollectionView()
        self.navbar.topItem?.title = "Nothing selected"
    }
    
    // MARK: - Methods
    private func openPaywall() {
        guard UserDefService.takeValue("isPro") == false else { return }
        guard smartClean ?? false else { return }
        self.performSegue(withIdentifier: "SubscriptionSegue", sender: self)
    }
    fileprivate func setupCollectionView() {
        collectionView.register(UINib(nibName: "PhotoCell", bundle: nil), forCellWithReuseIdentifier: "PhotoCell")
        collectionView.register(CollectionReusableView.nib(), forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter, withReuseIdentifier: CollectionReusableView.identifire)
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
extension GroupedAssetListVC: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
        if section == assetGroups.count - 1 {
        return CGSize(width: self.view.frame.width, height: 100)
        } else {
        return CGSize(width: 0, height: 0)
        }
    }
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
        case UICollectionView.elementKindSectionFooter:
                guard let view = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionFooter, withReuseIdentifier: CollectionReusableView.identifire, for: indexPath) as? CollectionReusableView else { fatalError() }
            if !isVideos {
                view.numberOfPhotos.text = "\(assetsCount) photos"
            } else {
                view.numberOfPhotos.text = "\(assetsCount) videos"
            }
                return view
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

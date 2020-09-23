//
//  PhotoListVC.swift
//  SmartCleaner
//
//  Created by Luchik on 27.05.2020.
//  Copyright © 2020 Luchik. All rights reserved.
//

import Foundation
import UIKit
import Photos

class AssetListVC: BaseController {
    // MARK: - UI
    @IBOutlet weak var navbar: UINavigationBar!
    @IBOutlet weak var collectionView: UICollectionView!
    // MARK: - Properties
    weak var delegate: AssetListDelegate?
    public var assets: [PHAsset] = []
    private var checkedPhotos: [Int] = []
    var smartClean: Bool?
    let columnLayout = ColumnFlowLayout(cellsPerRow: 3,
                                        minimumInteritemSpacing: 10,
                                        minimumLineSpacing: 10,
                                        sectionInset: UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10))

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
        self.collectionView.register(UINib(nibName: "PhotoCell", bundle: nil), forCellWithReuseIdentifier: "PhotoCell")
        self.collectionView.collectionViewLayout = columnLayout
        self.navbar.topItem?.title = "Nothing selected"
    }
    // MARK: - Methods
    private func openPaywall() {
        guard smartClean ?? false else { return }
        self.performSegue(withIdentifier: "SubscriptionSegue", sender: self)
    }
    @IBAction func onSelectAll(_ sender: Any) {
        if self.checkedPhotos.count == 0 {
            for i in 0...assets.count - 1{
                if !self.checkedPhotos.contains(i){
                    self.checkedPhotos.append(i)
                }
            }
        } else {
            self.checkedPhotos.removeAll()
        }
        
        self.collectionView.reloadData()
        self.navbar.topItem?.title = "\(self.checkedPhotos.count == 0 ? "Nothing" : "\(self.checkedPhotos.count)") selected"
    }
    
    @IBAction func onDelete(_ sender: Any) {
        let assetIdentifiers = checkedPhotos.map({i in self.assets[i]}).map({ $0.localIdentifier })
        delegate?.deleteAsset(id: assetIdentifiers)
        let assets = PHAsset.fetchAssets(withLocalIdentifiers: assetIdentifiers, options: nil)
        PHPhotoLibrary.shared().performChanges({
            PHAssetChangeRequest.deleteAssets(assets)
        }, completionHandler: { (success, error) in
            DispatchQueue.main.async{
                if success{
                    self.assets = self.assets.filter({ !assetIdentifiers.contains($0.localIdentifier) })
                }
                self.checkedPhotos = []
                self.collectionView.reloadData()
                self.navbar.topItem?.title = "Nothing selected"
                self.openPaywall()
            }
        })
    }
}
// MARK: - Extensions
extension AssetListVC: UICollectionViewDelegate, UICollectionViewDataSource{
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return assets.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell: PhotoCell = collectionView.dequeueReusableCell(withReuseIdentifier: "PhotoCell", for: indexPath) as! PhotoCell
        cell.photoThumbnail.image = assets[indexPath.row].hdImage
        cell.isChecked = self.checkedPhotos.contains(indexPath.row)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if self.checkedPhotos.contains(indexPath.row){
            self.checkedPhotos = self.checkedPhotos.filter({ $0 != indexPath.row})
        }
        else{
            self.checkedPhotos.append(indexPath.row)
        }
        self.navbar.topItem?.title = "\(self.checkedPhotos.count == 0 ? "Nothing" : "\(self.checkedPhotos.count)") selected"
        self.collectionView.reloadItems(at: [indexPath])
    }
}

protocol AssetListDelegate: class {
    func deleteAsset(id: [String])
}

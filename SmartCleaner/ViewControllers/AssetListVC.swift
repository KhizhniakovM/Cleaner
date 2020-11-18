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
    let columnLayout = ColumnFlowLayout(cellsPerRow: 4,
                                        minimumInteritemSpacing: 1,
                                        minimumLineSpacing: 1,
                                        sectionInset: UIEdgeInsets(top: 0.5, left: 0.5, bottom: 0.5, right: 0.5))

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
        self.collectionView.register(UINib(nibName: "PhotoCell", bundle: nil), forCellWithReuseIdentifier: "PhotoCell")
        self.collectionView.register(CollectionReusableView.nib(), forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter, withReuseIdentifier: CollectionReusableView.identifire)
        self.collectionView.collectionViewLayout = columnLayout
        self.navbar.topItem?.title = "Nothing selected"
    }
    // MARK: - Methods
    
    private func openPaywall() {
        guard UserDefService.takeValue("isPro") == false else { return }
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
extension AssetListVC: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        guard let view = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionFooter, withReuseIdentifier: CollectionReusableView.identifire, for: indexPath) as? CollectionReusableView else { fatalError() }
        view.numberOfPhotos.text = "\(assets.count) photos"
        return view
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
        return CGSize(width: self.view.frame.width, height: 100)
    }
    
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

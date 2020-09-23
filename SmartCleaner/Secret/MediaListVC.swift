////
////  MediaListVC.swift
////  SmartCleaner
////
////  Created by Luchik on 30.05.2020.
////  Copyright © 2020 Luchik. All rights reserved.
////
//
//import Foundation
//import UIKit
//import Photos
//import SwiftyUserDefaults
//
//class MediaListVC: BaseController{
//    @IBOutlet weak var navbar: UINavigationBar!
//    @IBOutlet weak var collectionView: UICollectionView!
//    private var assets: [PHAsset] = []
//    private var checkedAssets: [PHAsset] = []
//
//    @IBAction func onDone(_ sender: Any) {
//        var secretAssets = Defaults[\.secretMedia]
//        var deleteAssets: [String] = []
//        for asset in checkedAssets{
//            let filename: String = "\(asset.localIdentifier.split(separator: "/")[0]).jpg"
//            if !FilesManager().checkIfFileExists(filename){
//                if let assetData = asset.hdImage?.jpegData(compressionQuality: 90){
//                    do{
//                        try FilesManager().save(fileNamed: filename, data: assetData, {
//                            url in
//                            print("\(url) added!")
//                        })
//                        deleteAssets.append(asset.localIdentifier)
//                        secretAssets.append(filename)
//                    }
//                    catch{
//                        continue
//                    }
//                }
//            }
//        }
//        Defaults[\.secretMedia] = secretAssets
//        
//        let assets = PHAsset.fetchAssets(withLocalIdentifiers: deleteAssets, options: nil)
//        PHPhotoLibrary.shared().performChanges({
//            PHAssetChangeRequest.deleteAssets(assets)
//        }, completionHandler: { (success, error) in
//            DispatchQueue.main.async{
//                self.navigationController?.popViewController(animated: true)
//            }
//        })
//    }
//    
//    let columnLayout = ColumnFlowLayout(
//        cellsPerRow: 3,
//        minimumInteritemSpacing: 10,
//        minimumLineSpacing: 10,
//        sectionInset: UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
//    )
//    
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        self.collectionView.delegate = self
//        self.collectionView.dataSource = self
//        self.collectionView.register(UINib(nibName: "PhotoCell", bundle: nil), forCellWithReuseIdentifier: "PhotoCell")
//        self.collectionView.collectionViewLayout = columnLayout
//        MediaManager.loadPhotosAndVideos(){
//            assets in
//            self.assets = assets
//            self.collectionView.reloadData()
//        }
//    }
//}
//extension MediaListVC: UICollectionViewDelegate, UICollectionViewDataSource{
//    func numberOfSections(in collectionView: UICollectionView) -> Int {
//        return 1
//    }
//    
//    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
//        return assets.count
//    }
//    
//    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
//        let cell: PhotoCell = collectionView.dequeueReusableCell(withReuseIdentifier: "PhotoCell", for: indexPath) as! PhotoCell
//        cell.photoThumbnail.image = assets[indexPath.row].hdImage
//        cell.isChecked = self.checkedAssets.contains(assets[indexPath.row])
//        return cell
//    }
//    
//    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
//        let asset = assets[indexPath.row]
//        if self.checkedAssets.contains(asset){
//            self.checkedAssets = self.checkedAssets.filter({ $0 != asset})
//        }
//        else{
//            self.checkedAssets.append(asset)
//        }
//        self.navbar.topItem?.title = "\(self.checkedAssets.count == 0 ? "Nothing" : "\(self.checkedAssets.count)") selected"
//        self.collectionView.reloadItems(at: [indexPath])
//    }
//}

//
//  MediaManager.swift
//  SmartCleaner
//
//  Created by Luchik on 27.05.2020.
//  Copyright © 2020 Luchik. All rights reserved.
//

import Foundation
import Photos
import CocoaImageHashing
import SwiftyUserDefaults
import SwiftDate

class MediaManager {
    // MARK: - Methods
    public static func loadDuplicatePhotos(from dateFrom: String = "01-01-1970", to dateTo: String = "01-01-2030", _ handler: @escaping((_ assets: [PHAssetGroup]) -> Void)){
        fetchPhotos(from: dateFrom, to: dateTo, live: false) { photoInAlbum in
            var duplicatePhotos: [(asset: PHAsset, date: Int64, imageSize: Int64)] = []
            DispatchQueue.global(qos: .background).async {
                if photoInAlbum.count == 0 {
                    DispatchQueue.main.async {
                        handler([])
                    }
                    return
                }
                for i in 1...photoInAlbum.count{
                    duplicatePhotos.append((asset: photoInAlbum[i - 1], date: Int64(photoInAlbum[i - 1].creationDate!.timeIntervalSince1970), imageSize: photoInAlbum[i - 1].imageSize))
                }
                duplicatePhotos.sort(by: { duplicate1, duplicate2 in
                    return duplicate1.date > duplicate2.date
                })
                var assetGroups: [PHAssetGroup] = []
                var alreadyAdded: [Int] = []
                for i in 0...duplicatePhotos.count - 1{
                    var j = i + 1
                    if alreadyAdded.contains(i) { continue }
                    var duplicateAssets: [PHAsset] = []
                    if (j < duplicatePhotos.count && abs(duplicatePhotos[i].date - duplicatePhotos[j].date) <= 10) {
                        duplicateAssets.append(duplicatePhotos[i].asset)
                        alreadyAdded.append(i)
                        
                        repeat {
                            if alreadyAdded.contains(j) {
                                continue
                            }
                            duplicateAssets.append(duplicatePhotos[j].asset)
                            alreadyAdded.append(j)
                            j += 1
                        }
                        while (j < duplicatePhotos.count && abs(duplicatePhotos[i].date - duplicatePhotos[j].date) <= 10)
                    }
                    
                    if duplicateAssets.count != 0 {
                        assetGroups.append(PHAssetGroup(name: "", assets: duplicateAssets))
                    }
                }
                DispatchQueue.main.async {
                    handler(assetGroups)
                }
            }
        }
    }
    
    public static func loadSimilarVideos(from dateFrom: String = "01-01-1970", to dateTo: String = "01-01-2030", _ handler: @escaping ((_ assets: [PHAssetGroup]) -> Void)){
        fetchVideos(from: dateFrom, to: dateTo) { videoInAlbum in
            DispatchQueue.global(qos: .background).async {
                var images: [OSTuple<NSString, NSData>] = []
                if videoInAlbum.count == 0{
                    DispatchQueue.main.async{
                        handler([])
                    }
                    return
                }
                for i in 1...videoInAlbum.count {
                    if let image = videoInAlbum[i - 1].image, let data = image.jpegData(compressionQuality: 0.8) {
                        let tuple = OSTuple<NSString, NSData>(first: "image\(i)" as NSString,
                                                              andSecond: data as NSData)
                        images.append(tuple)
                    }
                }
                let similarVideoIdsAsTuples = OSImageHashing.sharedInstance().similarImages(withProvider: .pHash, forImages: images)
                DispatchQueue.main.async {
                    var similarVideoNumbers: [Int] = []
                    var similarVideoGroups: [PHAssetGroup] = []
                    for i in 1...similarVideoIdsAsTuples.count {
                        let tuple = similarVideoIdsAsTuples[i - 1]
                        var groupAssets: [PHAsset] = []
                        let n = (tuple.first! as String).removeImageAndToInt() - 1
                        let n2 = (tuple.second! as String).removeImageAndToInt() - 1
                        if abs(n2 - n) >= 10 { continue }
                        if !similarVideoNumbers.contains(n) {
                            similarVideoNumbers.append(n)
                            groupAssets.append(videoInAlbum[n])
                        }
                        if !similarVideoNumbers.contains(n2) {
                            similarVideoNumbers.append(n2)
                            groupAssets.append(videoInAlbum[n2])
                        }
                        similarVideoIdsAsTuples.filter({$0.first != nil && $0.second != nil}).filter({ $0.first == tuple.first || $0.first == tuple.second || $0.second == tuple.second || $0.second == tuple.first }).forEach({ tuple in
                            let n = (tuple.first! as String).removeImageAndToInt() - 1
                            let n2 = (tuple.second! as String).removeImageAndToInt() - 1
                            if abs(n2 - n) >= 10 {
                                return
                            }
                            if !similarVideoNumbers.contains(n) {
                                similarVideoNumbers.append(n)
                                groupAssets.append(videoInAlbum[n])
                            }
                            if !similarVideoNumbers.contains(n2) {
                                similarVideoNumbers.append(n2)
                                groupAssets.append(videoInAlbum[n2])
                            }
                        })
                        if groupAssets.count >= 2{
                            similarVideoGroups.append(PHAssetGroup(name: "", assets: groupAssets))
                        }
                    }
                    handler(similarVideoGroups)
                }
            }
        }
    }
    
    public static func loadSimilarPhotos(from dateFrom: String = "01-01-1970", to dateTo: String = "01-01-2030", live: Bool, _ handler: @escaping ((_ assets: [PHAssetGroup]) -> Void)){
        fetchPhotos(from: dateFrom, to: dateTo, live: live, { photoInAlbum in
            DispatchQueue.global(qos: .background).async {
                var images: [OSTuple<NSString, NSData>] = []
                if photoInAlbum.count == 0{
                    DispatchQueue.main.async{
                        handler([])
                    }
                    return
                }
                for i in 1...photoInAlbum.count {
                    if let image = photoInAlbum[i - 1].image, let data = image.jpegData(compressionQuality: 0.8){
                        let tuple = OSTuple<NSString, NSData>(first: "image\(i)" as NSString,
                                                              andSecond: data as NSData)
                        images.append(tuple)
                    }
                }
                
                
                let similarImageIdsAsTuples = OSImageHashing.sharedInstance().similarImages(with: OSImageHashingQuality.high, forImages: images)
                DispatchQueue.main.async{
                    var similarPhotosNumbers: [Int] = []
                    var similarPhotoGroups: [PHAssetGroup] = []
                    guard similarImageIdsAsTuples.count > 1 else { handler([]); return }
                    for i in 1...similarImageIdsAsTuples.count {
                        let tuple = similarImageIdsAsTuples[i - 1]
                        var groupAssets: [PHAsset] = []
                        let n = (tuple.first! as String).removeImageAndToInt() - 1
                        let n2 = (tuple.second! as String).removeImageAndToInt() - 1
                        if abs(n2 - n) >= 10 { continue }
                        if !similarPhotosNumbers.contains(n){
                            similarPhotosNumbers.append(n)
                            groupAssets.append(photoInAlbum[n])
                        }
                        if !similarPhotosNumbers.contains(n2) {
                            similarPhotosNumbers.append(n2)
                            groupAssets.append(photoInAlbum[n2])
                        }
                        similarImageIdsAsTuples.filter({$0.first != nil && $0.second != nil}).filter({ $0.first == tuple.first || $0.first == tuple.second || $0.second == tuple.second || $0.second == tuple.first }).forEach({ tuple in
                            let n = (tuple.first! as String).removeImageAndToInt() - 1
                            let n2 = (tuple.second! as String).removeImageAndToInt() - 1
                            if abs(n2 - n) >= 10{
                                return
                            }
                            if !similarPhotosNumbers.contains(n) {
                                similarPhotosNumbers.append(n)
                                groupAssets.append(photoInAlbum[n])
                            }
                            if !similarPhotosNumbers.contains(n2) {
                                similarPhotosNumbers.append(n2)
                                groupAssets.append(photoInAlbum[n2])
                            }
                        })
                        if groupAssets.count >= 2 {
                            similarPhotoGroups.append(PHAssetGroup(name: "", assets: groupAssets))
                        }
                    }
                    handler(similarPhotoGroups)
                }
            }
        })
    }
    
    public static func loadScreenshotPhotos(from dateFrom: String = "01-01-1970", to dateTo: String = "01-01-2030",_ handler: @escaping ((_ assets: [PHAsset]) -> Void)){
        fetchScreenshots(from: dateFrom, to: dateTo) { photoInAlbum in
            DispatchQueue.global(qos: .background).async{
                var images: [PHAsset] = []
                if photoInAlbum.count == 0{
                    DispatchQueue.main.async {
                        handler([])
                    }
                    return
                }
                for i in 1...photoInAlbum.count{
                    images.append(photoInAlbum[i - 1])
                }
                DispatchQueue.main.async {
                    handler(images)
                }
            }
        }
    }
    
    public static func loadGifPhotos(_ handler: @escaping ((_ assets: [PHAsset]) -> Void)){
        fetchGIFs({
            photoInAlbum in
            DispatchQueue.global(qos: .background).async{
                var images: [PHAsset] = []
                if photoInAlbum.count == 0{
                    DispatchQueue.main.async {
                        handler([])
                    }
                    return
                }
                for i in 1...photoInAlbum.count{
                    images.append(photoInAlbum[i - 1])
                }
                DispatchQueue.main.async {
                    handler(images)
                }
            }
        })
    }
    
    public static func loadSelfiePhotos(_ handler: @escaping ((_ assets: [PHAsset]) -> Void)){
        fetchSelfies({
            photoInAlbum in
            DispatchQueue.global(qos: .background).async{
                var images: [PHAsset] = []
                if photoInAlbum.count == 0{
                    DispatchQueue.main.async {
                        handler([])
                    }
                    return
                }
                for i in 1...photoInAlbum.count{
                    images.append(photoInAlbum[i - 1])
                }
                DispatchQueue.main.async {
                    handler(images)
                }
            }
        })
    }
    
    private static func fetchVideos(from dateFrom: String = "01-01-1970", to dateTo: String = "01-01-2100", _ handler: @escaping ((_ result: PHFetchResult<PHAsset>) -> Void)){
        let options = PHFetchOptions()
        let albumsPhoto: PHFetchResult<PHAssetCollection> = PHAssetCollection.fetchAssetCollections(with: .smartAlbum, subtype: .smartAlbumUserLibrary, options: options)
        options.predicate = NSPredicate(
            format: "mediaType = %d AND (creationDate >= %@) AND (creationDate <= %@)",
            PHAssetMediaType.video.rawValue,
            dateFrom.toNSDate(format: "dd-MM-yyyy"),
            dateTo.toNSDate(format: "dd-MM-yyyy"))
        options.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        albumsPhoto.enumerateObjects({(collection, index, object) in
            handler(PHAsset.fetchAssets(in: collection, options: options))
        })
    }
    
    private static func fetchPhotos(from dateFrom: String = "01-01-1970", to dateTo: String = "01-01-2100", live: Bool, _ handler: @escaping ((_ result: PHFetchResult<PHAsset>) -> Void)){
        let options = PHFetchOptions()
        let albumsPhoto: PHFetchResult<PHAssetCollection> = PHAssetCollection.fetchAssetCollections(with: .smartAlbum, subtype: live ? .smartAlbumLivePhotos : .smartAlbumUserLibrary, options: options)
        options.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        
        options.predicate = NSPredicate(
            format: "mediaType = %d AND (creationDate >= %@) AND (creationDate <= %@)",
            PHAssetMediaType.image.rawValue,
            dateFrom.toNSDate(format: "dd-MM-yyyy"),
            dateTo.toNSDate(format: "dd-MM-yyyy"))
        
        albumsPhoto.enumerateObjects({(collection, index, object) in
            handler(PHAsset.fetchAssets(in: collection, options: options))
        })
    }
    
    private static func fetchGIFs(_ handler: @escaping ((_ result: PHFetchResult<PHAsset>) -> Void)){
        let options = PHFetchOptions()
        let albumsPhoto: PHFetchResult<PHAssetCollection> = PHAssetCollection.fetchAssetCollections(with: .smartAlbum, subtype: .smartAlbumAnimated, options: options)
        options.predicate = NSPredicate(format: "mediaType == %d", PHAssetMediaType.image.rawValue)
        options.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        albumsPhoto.enumerateObjects({(collection, index, object) in
            handler(PHAsset.fetchAssets(in: collection, options: options))
        })
    }
    
    private static func fetchSelfies(_ handler: @escaping ((_ result: PHFetchResult<PHAsset>) -> Void)){
        let options = PHFetchOptions()
        let albumsPhoto: PHFetchResult<PHAssetCollection> = PHAssetCollection.fetchAssetCollections(with: .smartAlbum, subtype: .smartAlbumSelfPortraits, options: options)
        options.predicate = NSPredicate(format: "mediaType == %d", PHAssetMediaType.image.rawValue)
        options.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        albumsPhoto.enumerateObjects({(collection, index, object) in
            handler(PHAsset.fetchAssets(in: collection, options: options))
        })
    }
    
    public static func fetchPhotoCount(_ handler: @escaping ((_ count: Int) -> Void)){
        fetchPhotos(live: false, {
            result in
            handler(result.count)
        })
    }
    
    private static func fetchScreenshots(from dateFrom: String = "01-01-1970", to dateTo: String = "01-01-2030", handler: @escaping (PHFetchResult<PHAsset>) -> Void){
        let options = PHFetchOptions()
        let albumsPhoto: PHFetchResult<PHAssetCollection> = PHAssetCollection.fetchAssetCollections(with: .smartAlbum, subtype: .smartAlbumScreenshots, options: options)
        options.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        options.predicate = NSPredicate(
            format: "mediaType = %d AND (creationDate >= %@) AND (creationDate <= %@)",
            PHAssetMediaType.image.rawValue,
            dateFrom.toNSDate(format: "dd-MM-yyyy"),
            dateTo.toNSDate(format: "dd-MM-yyyy"))
        handler(PHAsset.fetchAssets(in: albumsPhoto[0], options: options))
    }
}

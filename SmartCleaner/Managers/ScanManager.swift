//
//  ScanManager.swift
//  SmartCleaner
//
//  Created by Luchik on 31.05.2020.
//  Copyright © 2020 Luchik. All rights reserved.
//

import Foundation
import Photos
import Contacts

class ScanManager {
    // MARK: - Methods
    public static func start(_ options: [Options], from dateFrom: String, to dateTo: String,
                             
                             handler: @escaping ([Options]) -> Void,
                             similarPhotos: @escaping ([PHAssetGroup]) -> Void,
                             similarLivePhotos: @escaping ([PHAssetGroup]) -> Void,
                             screenshots: @escaping ([PHAsset]) -> Void,
                             videos: @escaping ([PHAssetGroup]) -> Void,
                             emptyContacts: @escaping ([CNContactSection]) -> Void,
                             duplicateContacts: @escaping ([CNContactSection]) -> Void,
                             completion: @escaping () -> Void) {
        var result = 0
        handler(options)
        DispatchQueue.global(qos: .background).async{
            if options.contains(.similarPhotos){
                MediaManager.loadDuplicatePhotos(from: dateFrom, to: dateTo) { x in
                    similarPhotos(x)
                    result += 1
                    if result == 6 {
                        completion()
                    }
                }
            } else { result += 1
                if result == 6 {
                    completion()
                }
            }
            if options.contains(.similarLivePhotos){
                MediaManager.loadSimilarPhotos(from: dateFrom, to: dateTo, live: true, { x in
                    similarLivePhotos(x)
                    result += 1
                    if result == 6 {
                        completion()
                    }
                })
            } else { result += 1
                if result == 6 {
                    completion()
                }
            }
            if options.contains(.screenshots){
                MediaManager.loadScreenshotPhotos(from: dateFrom, to: dateTo) { (x) in
                    screenshots(x)
                    result += 1
                    if result == 6 {
                        completion()
                    }
                }
            } else { result += 1
                if result == 6 {
                    completion()
                }
            }
            if options.contains(.relatedVideos){
                MediaManager.loadSimilarVideos(from: dateFrom, to: dateTo, {x in
                    videos(x)
                    result += 1
                    if result == 6 {
                        completion()
                    }
                })
            } else { result += 1
                if result == 6 {
                    completion()
                }
            }
            if options.contains(.emptyContacts){
                ContactManager.loadContacts { (contacts) in
                    emptyContacts(ContactManager.loadIncompletedByPhone(contacts))
                    result += 1
                    if result == 6 {
                        completion()
                    }
                }
            } else { result += 1
                if result == 6 {
                    completion()
                }
            }
            if options.contains(.duplicateContacts){
                ContactManager.loadContacts { (contacts) in
                    duplicateContacts(ContactManager.loadDuplicateSectionsByPhone(ContactManager.loadDuplicatesByPhone(contacts)))
                    result += 1
                    if result == 6 {
                        completion()
                    }
                }
            } else { result += 1
                if result == 6 {
                    completion()
                }
            }
        }
        
    }
    
}

// MARK: - Options
public enum Options {
    case similarPhotos, screenshots, relatedVideos, similarLivePhotos, emptyContacts, duplicateContacts
    
    func name() -> String {
        switch self {
        case .similarPhotos:
            return "Similar photos"
        case .screenshots:
            return "Screenshots"
        case .relatedVideos:
            return "Videos"
        case .similarLivePhotos:
            return "Similar live photos"
        case .emptyContacts:
            return "Empty contacts"
        case .duplicateContacts:
            return "Duplicate contacts"
        }
    }
}

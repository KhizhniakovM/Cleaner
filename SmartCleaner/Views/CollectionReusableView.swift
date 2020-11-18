//
//  CollectionReusableView.swift
//  SmartCleaner
//
//  Created by Max Khizhniakov on 15.10.2020.
//  Copyright © 2020 Luchik. All rights reserved.
//

import UIKit

class CollectionReusableView: UICollectionReusableView {
    // MARK: - Properties
    static var identifire: String = "Footer"
    static func nib() -> UINib {
        return UINib(nibName: "CollectionReusableView", bundle: nil)
    }
    // MARK: - UI
    @IBOutlet weak var dateOfUpdate: UILabel!
    @IBOutlet weak var numberOfPhotos: UILabel!
    
    // MARK: - Lifecycle
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
}

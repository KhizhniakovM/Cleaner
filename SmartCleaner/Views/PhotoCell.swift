//
//  PhotoCell.swift
//  SmartCleaner
//
//  Created by Luchik on 27.05.2020.
//  Copyright © 2020 Luchik. All rights reserved.
//

import UIKit

class PhotoCell: UICollectionViewCell {
    @IBOutlet weak var bestView: UIView!
    @IBOutlet weak var photoCheck: UIImageView!
    @IBOutlet weak var photoThumbnail: UIImageView!
    
    public var isChecked: Bool = false{
        didSet{
            self.photoCheck.isHidden = !isChecked
            self.photoThumbnail.alpha = isChecked ? 0.5 : 1.0
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        bestView.clipsToBounds = true
        bestView.layer.cornerRadius = 5.0
        // Initialization code
    }

}

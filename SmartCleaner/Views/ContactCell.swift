//
//  ContactCell.swift
//  SmartCleaner
//
//  Created by Luchik on 29.05.2020.
//  Copyright © 2020 Luchik. All rights reserved.
//

import UIKit

class ContactCell: UITableViewCell {
    @IBOutlet weak var contactNameLabel: UILabel!
    @IBOutlet weak var checkMarkView: UIImageView!
    
    public var isChecked: Bool = false{
        didSet{
            checkMarkView.isHidden = !isChecked
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
}

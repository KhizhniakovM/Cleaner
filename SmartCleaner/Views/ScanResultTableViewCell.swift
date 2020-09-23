//
//  ScanResultTableViewCell.swift
//  SmartCleaner
//
//  Created by Max Khizhniakov on 14.09.2020.
//  Copyright © 2020 Luchik. All rights reserved.
//

import UIKit

class ScanResultTableViewCell: UITableViewCell {
    
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var resultLabel: UILabel!
    
    // MARK: - Lifecycle
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
}

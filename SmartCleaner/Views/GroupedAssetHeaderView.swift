//
//  GroupedAssetHeaderView.swift
//  SmartCleaner
//
//  Created by Luchik on 08.06.2020.
//  Copyright © 2020 Luchik. All rights reserved.
//

import Foundation
import UIKit

class GroupedAssetHeaderView: UICollectionReusableView{
    @IBOutlet weak var nameLabel: UILabel!
    public var onChoose: (() -> Void)?
    @IBAction func onChoose(_ sender: Any) {
        onChoose!()
    }
    
}

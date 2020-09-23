//
//  ScanGestureRecognizer.swift
//  SmartCleaner
//
//  Created by Max Khizhniakov on 31.08.2020.
//  Copyright © 2020 Luchik. All rights reserved.
//

import UIKit

class ScanTapGestureRecognizer: UITapGestureRecognizer{
    public var num: Int
    
    init(target: Any?, action: Selector?, num: Int) {
        self.num = num
        super.init(target: target, action: action)
    }
}

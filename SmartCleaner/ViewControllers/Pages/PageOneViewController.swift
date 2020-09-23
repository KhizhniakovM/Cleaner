//
//  PageOneViewController.swift
//  SmartCleaner
//
//  Created by Max Khizhniakov on 26.08.2020.
//  Copyright © 2020 Luchik. All rights reserved.
//

import UIKit

class PageOneViewController: UIViewController {
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    // MARK: - Methods
    @IBAction func nextPageButton(_ sender: UIButton) {
        let pageVC = self.parent as! PageViewController
        pageVC.goToNextPage(withIndex: 1)
    }
}

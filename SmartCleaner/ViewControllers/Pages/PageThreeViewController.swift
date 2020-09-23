//
//  PageThreeViewController.swift
//  SmartCleaner
//
//  Created by Max Khizhniakov on 26.08.2020.
//  Copyright © 2020 Luchik. All rights reserved.
//

import UIKit

class PageThreeViewController: UIViewController {
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    // MARK: - Methods
    @IBAction func homeButton(_ sender: UIButton) {
        let vc: NavigationController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "Home") as! NavigationController
        vc.modalPresentationStyle = .fullScreen
        self.present(vc, animated: true, completion: nil)
    }
}

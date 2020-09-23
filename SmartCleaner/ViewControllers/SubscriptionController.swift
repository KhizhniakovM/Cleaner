//
//  SubscriptionController.swift
//  SmartCleaner
//
//  Created by Luchik on 20.05.2020.
//  Copyright © 2020 Luchik. All rights reserved.
//

import Foundation
import UIKit

class SubscriptionController: BaseController {
    // MARK: - UI
    @IBOutlet weak var exitButton: UIButton!
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupButtons()
        banner.isHidden = true
    }
    // MARK: - Methods
    private func setupButtons() {
        self.exitButton.isHidden = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            self.exitButton.isHidden = false
        }
    }
    
    @IBAction func goBack(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
}

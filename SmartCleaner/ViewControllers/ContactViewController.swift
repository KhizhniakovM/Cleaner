//
//  ContactViewController.swift
//  SmartCleaner
//
//  Created by Max Khizhniakov on 19.10.2020.
//  Copyright © 2020 Luchik. All rights reserved.
//

import UIKit
import Contacts

class ContactViewController: UIViewController {
    // MARK: - Properties
    
    var contact: CNContact!
    override var preferredStatusBarStyle: UIStatusBarStyle { return .lightContent }
    // MARK: - UI
    @IBOutlet weak var avatar: UIImageView!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var mobile: UILabel!
    @IBOutlet weak var mail: UILabel!
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let x = self.avatar.frame.size.width / 2
        self.avatar.layer.cornerRadius = x
        self.avatar.clipsToBounds = true
    }
    
    // MARK: - Methods
    private func setupUI() {
        
        self.name.text = "\(contact.givenName) \(contact.familyName)"
        self.mobile.text = contact.phoneNumbers.first?.value.stringValue ?? ""
        self.mail.text = contact.emailAddresses.first?.value as String? ?? ""
        if let imadeData = contact.imageData {
            self.avatar.image = UIImage(data: imadeData)
        }
    }
    @IBAction func tapExitButton(_ sender: UIBarButtonItem) {
        self.navigationController?.popViewController(animated: true)
    }
}

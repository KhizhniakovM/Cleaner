//
//  ContactVC.swift
//  SmartCleaner
//
//  Created by Luchik on 28.05.2020.
//  Copyright © 2020 Luchik. All rights reserved.
//

import Foundation
import UIKit
import Contacts
import CloudKit

class ContactVC: BaseController {
    // MARK: - UI
//    @IBOutlet weak var iCloudView: UIView!
    @IBOutlet weak var incompleteNumberMailBlock: UIView!
    @IBOutlet weak var incompleteNumberBlock: UIView!
    @IBOutlet weak var incompleteNameBlock: UIView!
    @IBOutlet weak var duplicatesByEmailBlock: UIView!
    @IBOutlet weak var duplicatesByPhoneBlock: UIView!
    @IBOutlet weak var duplicatesByNameBlock: UIView!
    @IBOutlet weak var totalContactsBlock: UIView!
    @IBOutlet weak var noNumberMailCountLabel: UILabel!
    @IBOutlet weak var noNumberCountLabel: UILabel!
    @IBOutlet weak var noNameCountLabel: UILabel!
    @IBOutlet weak var dByEmailContactLabel: UILabel!
    @IBOutlet weak var dByPhoneContactLabel: UILabel!
    @IBOutlet weak var dByNameContactLabel: UILabel!
    @IBOutlet weak var totalContactCountLabel: UILabel!
    
    // MARK: - Properties
    private var lastContacts: [CNContact] = []
    private var totalContacts: [CNContact] = []
    private var lastSections: [CNContactSection] = []
    private var lastDuplicateType: DuplicateContactListVC.DuplicateType = .byName
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        loadContacts()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.viewDidLoad()
    }
    
    // MARK: - Methods
    fileprivate func loadContacts() {
        ContactManager.loadContacts({ [weak self] contacts in
            guard let self = self else { return }
            self.totalContacts = contacts
            let noNameCount: Int = contacts.filter({ $0.givenName.isEmpty }).count
            let noNumberCount: Int = contacts.filter({ $0.phoneNumbers.count == 0 }).count
            let noNumberAndMailCount: Int = contacts.filter({ $0.phoneNumbers.count == 0 && $0.emailAddresses.count == 0 }).count
            DispatchQueue.main.async {
                self.totalContactCountLabel.text = "\(contacts.count)"
                self.noNameCountLabel.text = "\(noNameCount)"
                self.noNumberCountLabel.text = "\(noNumberCount)"
                self.noNumberMailCountLabel.text = "\(noNumberAndMailCount)"
                self.dByPhoneContactLabel.text = "\(ContactManager.loadDuplicatesByPhone(contacts).count)"
                self.dByNameContactLabel.text = "\(ContactManager.loadDuplicatesByName(contacts).count)"
                self.dByEmailContactLabel.text = "\(ContactManager.loadDuplicatesByEmail(contacts).count)"
                self.setupButtons()
            }
        })
    }
    
    private func setupButtons(){
        totalContactsBlock.isUserInteractionEnabled = true
        totalContactsBlock.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.onTotalContacts)))
        duplicatesByNameBlock.isUserInteractionEnabled = true
        duplicatesByNameBlock.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.onDuplicateByNameContacts)))
        duplicatesByPhoneBlock.isUserInteractionEnabled = true
        duplicatesByPhoneBlock.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.onDuplicateByPhoneContacts)))
        duplicatesByEmailBlock.isUserInteractionEnabled = true
        duplicatesByEmailBlock.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.onDuplicateByEmailContacts)))
        incompleteNameBlock.isUserInteractionEnabled = true
        incompleteNameBlock.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.onIncompleteByName)))
        incompleteNumberBlock.isUserInteractionEnabled = true
        incompleteNumberBlock.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.onIncompleteByNumber)))
        incompleteNumberMailBlock.isUserInteractionEnabled = true
        incompleteNumberMailBlock.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.onIncompleteByNumberMail)))
//        iCloudView.isUserInteractionEnabled = true
//        iCloudView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.onBackup)))
    }
    
    // MARK: - @objc methods
    @objc private func onIncompleteByName(){
        self.lastSections = ContactManager.loadIncompletedByName(self.totalContacts)
        self.performSegue(withIdentifier: "IncompleteContactListSegue", sender: self)
    }
    
    @objc private func onIncompleteByNumber(){
        self.lastSections = ContactManager.loadIncompletedByPhone(self.totalContacts)
        self.performSegue(withIdentifier: "IncompleteContactListSegue", sender: self)
    }
    
    @objc private func onIncompleteByNumberMail(){
        self.lastSections = ContactManager.loadIncompletedByNumberAndMail(self.totalContacts)
        self.performSegue(withIdentifier: "IncompleteContactListSegue", sender: self)
    }
    
    @objc private func onTotalContacts(){
        ContactManager.loadContacts({
            contacts in
            self.lastContacts = contacts
            self.performSegue(withIdentifier: "ContactListSegue", sender: self)
        })
    }
    
    @objc private func onDuplicateByNameContacts(){
        let sections: [CNContactSection] = ContactManager.loadDuplicateSectionsByName(ContactManager.loadDuplicatesByName(self.totalContacts))
        self.lastSections = sections
        self.lastDuplicateType = .byName
        self.performSegue(withIdentifier: "DuplicateContactListSegue", sender: self)
    }
    
    @objc private func onDuplicateByPhoneContacts(){
        let sections: [CNContactSection] = ContactManager.loadDuplicateSectionsByPhone(ContactManager.loadDuplicatesByPhone(self.totalContacts))
        self.lastSections = sections
        self.lastDuplicateType = .byPhone
        self.performSegue(withIdentifier: "DuplicateContactListSegue", sender: self)
    }
    
    @objc private func onDuplicateByEmailContacts(){
        let sections: [CNContactSection] = ContactManager.loadDuplicateSectionsByEmail(ContactManager.loadDuplicatesByEmail(self.totalContacts))
        self.lastSections = sections
        self.lastDuplicateType = .byEmail
        self.performSegue(withIdentifier: "DuplicateContactListSegue", sender: self)
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ContactListSegue", let vc = segue.destination as? ContactListVC{
            vc.contacts = lastContacts
        }
        else if segue.identifier == "DuplicateContactListSegue", let vc = segue.destination as? DuplicateContactListVC{
            vc.sections = lastSections
            vc.duplicateType = self.lastDuplicateType
        }
        else if segue.identifier == "IncompleteContactListSegue", let vc = segue.destination as? IncompleteContactListVC{
            vc.sections = lastSections
        }
    }
}
//    @objc private func onBackup(){
//        self.showProgressHUD(title: "Please, wait...")
//        let keyStore = NSUbiquitousKeyValueStore()
//        for contact in self.totalContacts{
//            let entity = ContactEntity(JSON: [
//                "first_name": contact.givenName,
//                "last_name": contact.familyName,
//                "middle_name": contact.middleName,
//                "phones": contact.phoneNumbers.map({ $0.value.stringValue }),
//                "emails": contact.emailAddresses.map({ $0.value as String })
//            ])
//            keyStore.set(entity!.toJSONString()!, forKey: contact.identifier)
//        }
//        keyStore.synchronize()
//        DispatchQueue.main.asyncAfter(deadline: .now() + 2.5){
//            self.hideProgressHUD()
//        }
//    }

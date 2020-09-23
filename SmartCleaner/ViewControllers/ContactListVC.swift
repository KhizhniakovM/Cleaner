//
//  ContactListVC.swift
//  SmartCleaner
//
//  Created by Luchik on 29.05.2020.
//  Copyright © 2020 Luchik. All rights reserved.
//

import Foundation
import UIKit
import Contacts

class ContactListVC: BaseController{
    @IBOutlet weak var tableView: UITableView!
    public var contacts: [CNContact] = []
    private var sections: [CNContactSection] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(UINib(nibName: "ContactCell", bundle: nil), forCellReuseIdentifier: "ContactCell")
        tableView.delegate = self
        tableView.dataSource = self
        tableView.tableFooterView = UIView(frame: .zero)
        tableView.separatorColor = UIColor(rgb: 0x616163)
        initContacts()
        tableView.reloadData()
    }
    
    private func initContacts(){
        var letters: [String] = []
        for contact in contacts{
            if contact.givenName != ""{
                if !contact.givenName[String.Index(encodedOffset: 0)].isLetter{
                    if !letters.contains("#"){
                        letters.append("#")
                    }
                }
                else{
                    if !letters.contains(String(contact.givenName[String.Index(encodedOffset: 0)])){
                        letters.append(String(contact.givenName[String.Index(encodedOffset: 0)]))
                    }
                }
            }
        }
        letters.sort(by: {
            (letter1, letter2) in
            letter1 < letter2
        })
        for letter in letters{
            if letter == "#"{
                sections.append(CNContactSection(name: letter, contacts: self.contacts.filter({
                    $0.givenName.isEmpty || !$0.givenName[String.Index(encodedOffset: 0)].isLetter }).sorted(by: {
                    (contact1, contact2) in
                    contact1.givenName < contact2.givenName
                })))
                continue
            }
            let contacts = self.contacts.filter({ $0.givenName.starts(with: letter) }).sorted(by: {
                (contact1, contact2) in
                contact1.givenName < contact2.givenName
            })
            if contacts.count != 0{
                sections.append(CNContactSection(name: letter, contacts: contacts))
            }
        }
    }
}

extension ContactListVC: UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        (view as! UITableViewHeaderFooterView).contentView.backgroundColor = UIColor(rgb: 0xF3F3F3)
        (view as! UITableViewHeaderFooterView).textLabel?.textColor = UIColor(rgb: 0x407BFF)

    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: ContactCell = tableView.dequeueReusableCell(withIdentifier: "ContactCell") as! ContactCell
        cell.contactNameLabel.text = sections[indexPath.section].contacts[indexPath.row].getTitle()
        return cell
    }
    
    func tableView(_ tableView: UITableView, titleForDeleteConfirmationButtonForRowAt indexPath: IndexPath) -> String? {
        return "Delete"
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete{
            ContactManager.delete(sections[indexPath.section].contacts[indexPath.row]){
                success in
                if success{
                    self.sections[indexPath.section].contacts.remove(at: indexPath.row)
                    self.tableView.deleteRows(at: [indexPath], with: .none)
                }
            }
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sections[section].name
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sections[section].contacts.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50.0
    }
}
public class CNContactSection{
    let name: String
    var contacts: [CNContact]
    
    init(name: String, contacts: [CNContact]){
        self.name = name
        self.contacts = contacts
    }
}

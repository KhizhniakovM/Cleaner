//
//  IncompleteContactListVC.swift
//  SmartCleaner
//
//  Created by Luchik on 30.05.2020.
//  Copyright © 2020 Luchik. All rights reserved.
//

import Foundation
import UIKit
import Contacts

class IncompleteContactListVC: BaseController{
    @IBAction func onDelete(_ sender: Any) {
        ContactManager.delete(checkedContacts)
        delegate?.delete(contact: checkedContacts)
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0){
            self.deleteButton.isEnabled = false
            self.sections.forEach({ $0.contacts = $0.contacts.filter({ !self.checkedContacts.contains($0) }) })
            var newSections: [CNContactSection] = []
            for section in self.sections{
                if section.contacts.count != 0{
                    newSections.append(section)
                }
            }
            self.sections = newSections
            self.tableView.reloadData()
            self.openPaywall()
        }
    }
    @IBOutlet weak var deleteButton: UIBarButtonItem!
    @IBOutlet weak var navbar: UINavigationBar!
    @IBOutlet weak var tableView: UITableView!
    public var sections: [CNContactSection] = []
    private var checkedContacts: [CNContact] = []
    var smartClean: Bool?
    weak var delegate: IncompliteListDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        deleteButton.isEnabled = false
        tableView.register(GroupedContactHeaderView.self, forHeaderFooterViewReuseIdentifier: "GroupedContactHeaderView")
        tableView.register(UINib(nibName: "ContactCell", bundle: nil), forCellReuseIdentifier: "ContactCell")
        tableView.delegate = self
        tableView.dataSource = self
        tableView.tableFooterView = UIView(frame: .zero)
        tableView.separatorColor = UIColor(rgb: 0x616163)
        tableView.reloadData()
    }
    private func openPaywall() {
        guard smartClean ?? false else { return }
        self.performSegue(withIdentifier: "SubscriptionSegue", sender: self)
    }

}
extension IncompleteContactListVC: UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
         let header = tableView.dequeueReusableHeaderFooterView(
            withIdentifier: "GroupedContactHeaderView")! as! GroupedContactHeaderView
        header.setName(sections[section].name)
        header.onSelectAll = {
            guard self.sections[section].contacts.count >= 1 else { return }
            for i in 0...self.sections[section].contacts.count - 1{
                let contact = self.sections[section].contacts[i]
                if self.checkedContacts.contains(contact){
                    self.checkedContacts = self.checkedContacts.filter({ $0 != contact })
                }
                else{
                    self.checkedContacts.append(contact)
                }
            }
            self.deleteButton.isEnabled = self.checkedContacts.count != 0
            self.tableView.reloadSections(IndexSet(integer: section), with: .none)
        }
        return header
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 35.0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: ContactCell = tableView.dequeueReusableCell(withIdentifier: "ContactCell") as! ContactCell
        cell.contactNameLabel.text = sections[indexPath.section].contacts[indexPath.row].getTitle()
        cell.isChecked = self.checkedContacts.contains(sections[indexPath.section].contacts[indexPath.row])
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

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let contact = self.sections[indexPath.section].contacts[indexPath.row]
        if self.checkedContacts.contains(contact){
            self.checkedContacts = self.checkedContacts.filter({ $0 != contact })
        }
        else{
            self.checkedContacts.append(contact)
        }
        self.tableView.reloadRows(at: [indexPath], with: .none)
        deleteButton.isEnabled = self.checkedContacts.count != 0
    }
}

protocol IncompliteListDelegate: class {
    func delete(contact: [CNContact])
}

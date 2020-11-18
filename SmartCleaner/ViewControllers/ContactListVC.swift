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

class ContactListVC: BaseController, UIGestureRecognizerDelegate{
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var trashButton: UIBarButtonItem!
    public var contacts: [CNContact] = []
    public var contactsCopy: [CNContact] = []
    private var sections: [CNContactSection] = []
    var hide: Bool = true
    private var checkedContacts: [CNContact] = []
    private var contactForSegue: CNContact?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        trashButton.isEnabled = false
        self.contactsCopy = contacts
        searchBar.delegate = self
        let textFieldInsideUISearchBar = searchBar.value(forKey: "searchField") as? UITextField
        textFieldInsideUISearchBar?.textColor = UIColor.white
        textFieldInsideUISearchBar?.font = UIFont(name: "SFUIText-Medium", size: 17)
        tableView.register(UINib(nibName: "ContactCell", bundle: nil), forCellReuseIdentifier: "ContactCell")
        tableView.delegate = self
        tableView.dataSource = self
        tableView.tableFooterView = UIView(frame: .zero)
        tableView.separatorColor = UIColor(rgb: 0x616163)
        initContacts()
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(hideCircles(sender:)))
        longPress.delegate = self
        longPress.delaysTouchesEnded = true
        tableView.addGestureRecognizer(longPress)
        tableView.reloadData()
    }
    @objc
    private func hideCircles(sender: UILongPressGestureRecognizer) {
        if sender.state == .began {
            if hide == true {
                hide = false
            } else {
                hide = true
                checkedContacts = []
            }
            tableView.reloadData()
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? ContactViewController {
            vc.contact = contactForSegue
        }
    }
    @IBAction func tapTrashButton(_ sender: UIBarButtonItem) {
        ContactManager.delete(checkedContacts)
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0){
            self.trashButton.isEnabled = false
            self.sections.forEach({ $0.contacts = $0.contacts.filter({ !self.checkedContacts.contains($0) }) })
            var newSections: [CNContactSection] = []
            for section in self.sections{
                if section.contacts.count != 0{
                    newSections.append(section)
                }
            }
            self.sections = newSections
            self.hide = true
            self.checkedContacts = []
            self.tableView.reloadData()
        }
    }
    
    private func initContacts(){
        var letters: [String] = []
        for contact in contacts {
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
extension ContactListVC: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        sections = []
        contacts = contactsCopy
        contacts = contacts.filter { (contact) -> Bool in
            contact.givenName.hasPrefix(searchText)
        }
        initContacts()
        tableView.reloadData()
    }
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.endEditing(true)
    }
}
extension ContactListVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if !hide {
        let contact = self.sections[indexPath.section].contacts[indexPath.row]
        if self.checkedContacts.contains(contact){
            self.checkedContacts = self.checkedContacts.filter({ $0 != contact })
        }
        else{
            self.checkedContacts.append(contact)
        }
        self.tableView.reloadRows(at: [indexPath], with: .none)
        trashButton.isEnabled = self.checkedContacts.count != 0
        } else {
            tableView.deselectRow(at: indexPath, animated: true)
            contactForSegue = sections[indexPath.section].contacts[indexPath.row]
            performSegue(withIdentifier: "Contact", sender: nil)
        }

}
func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
    (view as! UITableViewHeaderFooterView).contentView.backgroundColor = UIColor(named: "cell")
    (view as! UITableViewHeaderFooterView).textLabel?.textColor = UIColor(named: "text")
    
}

func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell: ContactCell = tableView.dequeueReusableCell(withIdentifier: "ContactCell") as! ContactCell
    cell.contactNameLabel.text = sections[indexPath.section].contacts[indexPath.row].getTitle()
    cell.isChecked = self.checkedContacts.contains(sections[indexPath.section].contacts[indexPath.row])
    if !hide {
        cell.checkMarkView.isHidden = false
    } else if hide {
        cell.checkMarkView.isHidden = true
    }
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
public class CNContactSection {
    let name: String
    var contacts: [CNContact]
    
    init(name: String, contacts: [CNContact]){
        self.name = name
        self.contacts = contacts
    }
}

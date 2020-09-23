//
//  DuplicateContactListVC.swift
//  SmartCleaner
//
//  Created by Luchik on 30.05.2020.
//  Copyright © 2020 Luchik. All rights reserved.
//

import Foundation
import UIKit
import Contacts

class DuplicateContactListVC: BaseController{
    public enum DuplicateType {
        case byPhone, byEmail, byName
    }
    // MARK: - UI
    @IBOutlet weak var navbar: UINavigationBar!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var combineButton: UIButton!
    
    // MARK: - Properties
    public var sections: [CNContactSection] = []
    public var duplicateType: DuplicateType = .byName
    private var checkedIndexPaths: [IndexPath] = []
    weak var delegate: DuplicateDelegate?
    var smartClean: Bool?
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        navbar.topItem?.title = duplicateType == .byName ? "Duplicates by name" : duplicateType == .byEmail ? "Duplicates by email" : "Duplicates by phone"
    }
    // MARK: - Methods
    private func openPaywall() {
        guard smartClean ?? false else { return }
        self.performSegue(withIdentifier: "SubscriptionSegue", sender: self)
    }
    override func addInter() {
        if UserDefaults.standard.object(forKey: "isFirstContact") == nil {
            UserDefaults.standard.set(false, forKey: "isFirstContact")
        } else {
            guard inter.isReady == true else { return }
                inter.present(fromRootViewController: self)
        }
    }
    @IBAction func onCombine(_ sender: UIButton) {
        addInter()
        let x = checkedIndexPaths.map({ sections[$0.section].contacts[$0.row] })
        ContactManager.combine(checkedIndexPaths.map({ sections[$0.section].contacts[$0.row] }), { success in
            self.delegate?.delete(ip: x)
            self.navigationController?.popViewController(animated: true)
            self.openPaywall()
        })
    }
    fileprivate func setupTableView() {
        tableView.register(GroupedContactHeaderView.self, forHeaderFooterViewReuseIdentifier: "GroupedContactHeaderView")
        tableView.register(UINib(nibName: "ContactCell", bundle: nil), forCellReuseIdentifier: "ContactCell")
        tableView.delegate = self
        tableView.dataSource = self
        tableView.tableFooterView = UIView(frame: .zero)
        tableView.separatorColor = UIColor(rgb: 0x616163)
        tableView.reloadData()
    }
}
// MARK: - Extensions
extension DuplicateContactListVC: UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
         let header = tableView.dequeueReusableHeaderFooterView(
            withIdentifier: "GroupedContactHeaderView")! as! GroupedContactHeaderView
        header.setName(sections[section].name)
        header.onSelectAll = {
            guard self.sections[section].contacts.count >= 1 else { return }
            for i in 0...self.sections[section].contacts.count - 1{
                let indexPath: IndexPath = IndexPath(row: i, section: section)
                if self.checkedIndexPaths.contains(indexPath){
                    self.checkedIndexPaths = self.checkedIndexPaths.filter({ $0 != indexPath })
                }
                else{
                    self.checkedIndexPaths.append(indexPath)
                }
            }
            self.tableView.reloadSections(IndexSet(integer: section), with: .none)
            self.combineButton.isHidden = self.checkedIndexPaths.count < 2
        }
        
        return header
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 35.0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: ContactCell = tableView.dequeueReusableCell(withIdentifier: "ContactCell") as! ContactCell
        cell.contactNameLabel.text = sections[indexPath.section].contacts[indexPath.row].givenName
        cell.isChecked = checkedIndexPaths.contains(indexPath)
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
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return checkedIndexPaths.count == 0
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if checkedIndexPaths.contains(indexPath) {
            checkedIndexPaths = checkedIndexPaths.filter({ $0 != indexPath })
        } else {
            checkedIndexPaths.append(indexPath)
        }
        self.tableView.reloadRows(at: [indexPath], with: .none)
        self.combineButton.isHidden = checkedIndexPaths.count < 2
    }
}

protocol DuplicateDelegate: class {
    func delete(ip: [CNContact])
}

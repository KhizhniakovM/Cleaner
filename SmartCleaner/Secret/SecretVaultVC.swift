////
////  SecretVaultVC.swift
////  SmartCleaner
////
////  Created by Luchik on 30.05.2020.
////  Copyright © 2020 Luchik. All rights reserved.
////
//
//import Foundation
//import UIKit
//import Photos
//import Contacts
//
//class SecretVaultVC: BaseController{
//    @IBAction func onAdd(_ sender: Any) {
//        self.performSegue(withIdentifier: segmentedControl.selectedSegmentIndex == 0 ? "MediaListSegue" : "ContactListSegue2", sender: self)
//    }
//    @IBOutlet weak var tableView: UITableView!
//    @IBOutlet weak var collectionView: UICollectionView!
//    private var assets: [URL] = []
//    private var sections: [CNContactSection] = []
//    private var contacts: [CNContact] = []{
//        didSet{
//            sections.removeAll()
//            var letters: [String] = []
//            for contact in contacts{
//                if contact.givenName != ""{
//                    if !contact.givenName[String.Index(encodedOffset: 0)].isLetter{
//                        if !letters.contains("#"){
//                            letters.append("#")
//                        }
//                    }
//                    else{
//                        if !letters.contains(String(contact.givenName[String.Index(encodedOffset: 0)])){
//                            letters.append(String(contact.givenName[String.Index(encodedOffset: 0)]))
//                        }
//                    }
//                }
//            }
//            letters.sort(by: {
//                                  (letter1, letter2) in
//                                  letter1 < letter2
//                              })
//        for letter in letters{
//                    if letter == "#"{
//                        sections.append(CNContactSection(name: letter, contacts: self.contacts.filter({
//                            $0.givenName.isEmpty || !$0.givenName[String.Index(encodedOffset: 0)].isLetter }).sorted(by: {
//                            (contact1, contact2) in
//                            contact1.givenName < contact2.givenName
//                        })))
//                        continue
//                    }
//                    let contacts = self.contacts.filter({ $0.givenName.starts(with: letter) }).sorted(by: {
//                        (contact1, contact2) in
//                        contact1.givenName < contact2.givenName
//                    })
//                    if contacts.count != 0{
//                        sections.append(CNContactSection(name: letter, contacts: contacts))
//                    }
//                }
//        }
//    }
//
//    @IBAction func segmentedValueChanged(_ sender: Any) {
//        if segmentedControl.selectedSegmentIndex == 0{
//            initMedia()
//        }
//        else{
//            initContacts()
//        }
//    }
//    @IBOutlet weak var addLabel: UILabel!
//    @IBOutlet weak var shield: UIImageView!
//    @IBOutlet weak var addBlock: UIStackView!
//    @IBOutlet weak var segmentedControl: UISegmentedControl!
//    
//    let columnLayout = ColumnFlowLayout(
//        cellsPerRow: 3,
//        minimumInteritemSpacing: 10,
//        minimumLineSpacing: 10,
//        sectionInset: UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
//    )
//    
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        self.collectionView.delegate = self
//        self.collectionView.dataSource = self
//        self.collectionView.register(UINib(nibName: "PhotoCell", bundle: nil), forCellWithReuseIdentifier: "PhotoCell")
//        self.collectionView.collectionViewLayout = columnLayout
//        
//        tableView.register(UINib(nibName: "ContactCell", bundle: nil), forCellReuseIdentifier: "ContactCell")
//        tableView.delegate = self
//        tableView.dataSource = self
//        tableView.tableFooterView = UIView(frame: .zero)
//        tableView.separatorColor = UIColor(rgb: 0x616163)
//        let photos = PHPhotoLibrary.authorizationStatus()
//        if photos == .notDetermined {
//            PHPhotoLibrary.requestAuthorization({status in
//                if status == .authorized{
//                    self.resume()
//                }
//            })
//            return
//        }
//        self.resume()
//    }
//    
//    private func resume(){
//        MediaManager.loadSecretMedia(){
//            assets in
//            self.assets = assets
//            self.initMedia()
//        }
//        ContactManager.loadSecretContacts(){
//            contacts in
//            self.contacts = contacts
//        }
//    }
//    
//    override func viewWillAppear(_ animated: Bool) {
//        super.viewWillAppear(animated)
//        if segmentedControl.selectedSegmentIndex == 0{
//            MediaManager.loadSecretMedia(){
//                assets in
//                self.assets = assets
//                self.initMedia()
//            }
//            ContactManager.loadSecretContacts(){
//                contacts in
//                self.contacts = contacts
//            }
//        }
//        else{
//            MediaManager.loadSecretMedia(){
//                assets in
//                self.assets = assets
//            }
//            ContactManager.loadSecretContacts(){
//                contacts in
//                self.contacts = contacts
//                self.initContacts()
//            }
//        }
//    }
//    
//    private func initMedia(){
//        DispatchQueue.main.async{
//            self.addLabel.text = "Touch \"+\" to add photo or video"
//            self.shield.image = UIImage(named: "Shield1")
//            self.collectionView.reloadData()
//            self.collectionView.isHidden = false
//            self.tableView.isHidden = true
//            self.addBlock.isHidden = self.assets.count != 0
//        }
//    }
//    
//    private func initContacts(){
//        addLabel.text = "Touch \"+\" to add contacts"
//        shield.image = UIImage(named: "Shield2")
//        self.tableView.reloadData()
//        self.collectionView.isHidden = true
//        self.tableView.isHidden = false
//        addBlock.isHidden = contacts.count != 0
//    }
//}
//extension SecretVaultVC: UICollectionViewDelegate, UICollectionViewDataSource{
//    func numberOfSections(in collectionView: UICollectionView) -> Int {
//        return 1
//    }
//    
//    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
//        return assets.count
//    }
//    
//    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
//        let cell: PhotoCell = collectionView.dequeueReusableCell(withReuseIdentifier: "PhotoCell", for: indexPath) as! PhotoCell
//        var imageData: Data? = nil
//        do {
//             imageData = try Data(contentsOf: assets[indexPath.row])
//        } catch {
//            print(error.localizedDescription)
//        }
//        if let data = imageData, let image = UIImage(data: data){
//            cell.photoThumbnail.image = image
//        }
//        cell.isChecked = false
//        return cell
//    }
//    
//    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
//        //let asset = assets[indexPath.row]
//    }
//}
//
//extension SecretVaultVC: UITableViewDelegate, UITableViewDataSource{
//    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
//        (view as! UITableViewHeaderFooterView).contentView.backgroundColor = UIColor(rgb: 0x414142)
//        (view as! UITableViewHeaderFooterView).textLabel?.textColor = .white
//
//    }
//    
//    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        let cell: ContactCell = tableView.dequeueReusableCell(withIdentifier: "ContactCell") as! ContactCell
//        cell.contactNameLabel.text = sections[indexPath.section].contacts[indexPath.row].getTitle()
//        return cell
//    }
//    
//    func numberOfSections(in tableView: UITableView) -> Int {
//        return sections.count
//    }
//    
//    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
//        return sections[section].name
//    }
//    
//    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        return sections[section].contacts.count
//    }
//    
//    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
//        return 50.0
//    }
//}

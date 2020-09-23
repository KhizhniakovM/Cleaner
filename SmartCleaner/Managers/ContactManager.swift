//
//  ContactManager.swift
//  SmartCleaner
//
//  Created by Luchik on 28.05.2020.
//  Copyright © 2020 Luchik. All rights reserved.
//

import Foundation
import SwiftyContacts
import Contacts
import SwiftyUserDefaults

class ContactManager{
//    public static func loadSecretContacts(_ handler: @escaping ((_ contacts: [CNContact]) -> Void)){
//        checkStatus {
//            fetchContacts(completionHandler: { (result) in
//                switch result {
//                case .success(let contacts):
//                    handler(contacts.filter({ Defaults[\.secretContacts].contains($0.identifier) }))
//                    // Do your thing here with [CNContacts] array
//                    break
//                case .failure:
//                    break
//                }
//            })
//        }
//    }
    
    public static func loadContacts(_ handler: @escaping ((_ contacts: [CNContact]) -> Void)){
        checkStatus {
            fetchContacts(completionHandler: { (result) in
                switch result {
                case .success(let contacts):
                    handler(contacts)
                    // Do your thing here with [CNContacts] array
                    break
                case .failure:
                    break
                }
            })
        }
    }
    
    private static func checkStatus(_ handler: @escaping (() -> Void)){
        authorizationStatus { (status) in
            if status == .authorized{
                handler()
            }
            else{
                requestContactAccess {
                    handler()
                }
            }
        }
    }
    
    private static func requestContactAccess(_ handler: @escaping (() -> Void)){
        requestAccess { (response) in
            if response {
                handler()
                print("Contacts Acess Granted")
            } else {
                print("Contacts Acess Denied")
            }
        }
    }
    
    public static func loadDuplicatesByPhone(_ c: [CNContact]) -> [CNContact]{
        var duplicates: [CNContact] = []
        let contacts = c.filter({ $0.phoneNumbers.count != 0 })
        for i in 0...contacts.count - 1{
            if duplicates.contains(contacts[i]){
                continue
            }
            let phones: [String] = contacts[i].phoneNumbers.map({ $0.value.stringValue })
            let duplicatedContacts: [CNContact] = contacts.filter({ $0 != contacts[i] }).filter({
                return $0.phoneNumbers.map({ $0.value.stringValue }).contains(phones)
            })
            duplicatedContacts.forEach({
                if !duplicates.contains(contacts[i]){
                    duplicates.append(contacts[i])
                }
                if !duplicates.contains($0){
                    duplicates.append($0)
                }
            })
        }
        return duplicates
    }
    
    public static func loadDuplicateSectionsByPhone(_ contacts: [CNContact]) -> [CNContactSection]{
        var sections: [CNContactSection] = []
        var phones: [String] = []
        for contact in contacts{
            for phone in contact.phoneNumbers{
                if !phones.contains(phone.value.stringValue){
                    phones.append(phone.value.stringValue)
                    sections.append(CNContactSection(name: phone.value.stringValue, contacts: []))
                }
            }
        }
        for phone in phones{
            let contacts = contacts.filter({ $0.phoneNumbers.map({ $0.value.stringValue }).contains(phone) })
            sections.filter({ $0.name == phone })[0].contacts.append(contentsOf: contacts)
        }
        return sections
    }
    
    public static func loadDuplicatesByName(_ contacts: [CNContact]) -> [CNContact]{
        var duplicates: [CNContact] = []
        for i in 0...contacts.count - 1{
            if duplicates.contains(contacts[i]){
                continue
            }
            let duplicatedContacts: [CNContact] = contacts.filter({ $0 != contacts[i] }).filter({
                $0.givenName == contacts[i].givenName }).filter({$0.familyName == contacts[i].familyName})
            duplicatedContacts.forEach({
                if !duplicates.contains(contacts[i]){
                    duplicates.append(contacts[i])
                }
                if !duplicates.contains($0){
                    duplicates.append($0)
                }
            })
        }
        return duplicates
    }
    
    public static func loadDuplicateSectionsByName(_ contacts: [CNContact]) -> [CNContactSection]{
        var sections: [CNContactSection] = []
        for contact in contacts{
            if sections.filter({ $0.name == contact.givenName + " " + contact.familyName }).count == 0{
                sections.append(CNContactSection(name: contact.givenName + " " + contact.familyName, contacts: []))
            }
        }
        for contact in contacts{
            sections.filter({ $0.name == contact.givenName + " " + contact.familyName })[0].contacts.append(contact)
        }
        return sections
    }
    
    public static func loadDuplicatesByEmail(_ contacts: [CNContact]) -> [CNContact]{
        var duplicates: [CNContact] = []
        for i in 0...contacts.count - 1{
            if duplicates.contains(contacts[i]){
                continue
            }
            let emails: [String] = contacts[i].emailAddresses.map({ $0.value as String })
            let duplicatedContacts: [CNContact] = contacts.filter({ $0 != contacts[i] }).filter({
                return $0.emailAddresses.map({ $0.value as String }).contains(emails)
            })
            duplicatedContacts.forEach({
                if !duplicates.contains(contacts[i]){
                    duplicates.append(contacts[i])
                }
                if !duplicates.contains($0){
                    duplicates.append($0)
                }
            })
        }
        return duplicates
    }
    
    public static func loadDuplicateSectionsByEmail(_ contacts: [CNContact]) -> [CNContactSection]{
        var sections: [CNContactSection] = []
        var emails: [String] = []
        for contact in contacts{
            for email in contact.emailAddresses{
                if !emails.contains(email.value as String){
                    emails.append(email.value as String)
                    sections.append(CNContactSection(name: email.value as String, contacts: []))
                }
            }
        }
        for email in emails{
            let contacts = contacts.filter({ $0.emailAddresses.map({ $0.value as String }).contains(email) })
            sections.filter({ $0.name == email })[0].contacts.append(contentsOf: contacts)
        }
        return sections
    }
    
    public static func delete(_ contact: CNContact, _ handler: @escaping ((_ success: Bool) -> Void)){
        deleteContact(Contact: contact.mutableCopy() as! CNMutableContact, completionHandler: {
            (result) in
            switch result{
            case .success(let bool):
                handler(bool)
                break
            case .failure:
                handler(false)
                break
            }
        })
    }
    
    public static func delete(_ contacts: [CNContact]){
        for contact in contacts{
            deleteContact(Contact: contact.mutableCopy() as! CNMutableContact, completionHandler: {
                (result) in
            })
        }
    }
    
    public static func combine(_ contacts: [CNContact], _ handler: @escaping ((_ success: Bool) -> Void)){
        var bestContact: CNContact?
        var bestValue: Int = 0
        for contact in contacts{
            if contact.getPrice() > bestValue{
                bestValue = contact.getPrice()
                bestContact = contact
            }
        }
        let deleteContacts = contacts.filter({ $0 != bestContact! })
        for contact in deleteContacts{
            deleteContact(Contact: contact.mutableCopy() as! CNMutableContact, completionHandler: {
                (result) in
            })
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0, execute: {
            handler(true)
        })
    }
    
    public static func loadIncompletedByName(_ contacts: [CNContact]) -> [CNContactSection]{
        var incompleted: [CNContact] = []
        for contact in contacts{
            if contact.givenName.isEmpty{
                incompleted.append(contact)
            }
        }
        return [CNContactSection(name: "No name", contacts: incompleted)]
    }
    
    public static func loadIncompletedByPhone(_ contacts: [CNContact]) -> [CNContactSection]{
        var incompleted: [CNContact] = []
        for contact in contacts{
            if contact.phoneNumbers.count == 0{
                incompleted.append(contact)
            }
        }
        return [CNContactSection(name: "No phones", contacts: incompleted)]
    }
    
    public static func loadIncompletedByNumberAndMail(_ contacts: [CNContact]) -> [CNContactSection]{
        var incompleted: [CNContact] = []
        for contact in contacts{
            if contact.emailAddresses.count == 0 && contact.phoneNumbers.count == 0{
                incompleted.append(contact)
            }
        }
        print(incompleted)
        return [CNContactSection(name: "No email addresses", contacts: incompleted)]
    }
}
extension CNContact{
    func getPrice() -> Int{
        return self.emailAddresses.count + self.phoneNumbers.count + (self.givenName.isEmpty ? 0 : 1) + (self.familyName.isEmpty ? 0 : 1) + (self.middleName.isEmpty ? 0 : 1)
    }
}

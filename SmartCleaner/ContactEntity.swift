//
//  ContactEntity.swift
//  SmartCleaner
//
//  Created by Luchik on 10.06.2020.
//  Copyright © 2020 Luchik. All rights reserved.
//

import Foundation
import ObjectMapper

class ContactEntity: Mappable {
    var name, lastName, middleName: String?
    var phones: [String] = []
    var emails: [String] = []
    
    required init?(map: Map) {
    }
    
    
    func mapping(map: Map) {
        name <- map["name"]
        lastName <- map["last_name"]
        middleName <- map["middle_name"]
        phones <- map["phones"]
        emails <- map["emails"]
    }
}

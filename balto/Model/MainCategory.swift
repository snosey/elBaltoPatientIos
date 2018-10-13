//
//  Category.swift
//  balto
//
//  Created by Abanoub Osama on 4/4/18.
//  Copyright © 2018 Abanoub Osama. All rights reserved.
//

import Foundation

class MainCategory: BaseModel {
    
    var logo: String!
    
    init(jsonDic: [String: Any]) {
        let id = jsonDic["id"] as! Int
        let name = jsonDic["name"] as! String
        super.init(id: id, name: name)
        
        logo = "http://haseboty.com/doctor/public/images/\(jsonDic["logo"] as! String)".replacingOccurrences(of: " ", with: "%20")
    }
}

//
//  Category.swift
//  balto
//
//  Created by Abanoub Osama on 4/4/18.
//  Copyright © 2018 Abanoub Osama. All rights reserved.
//

import Foundation

class Category: BaseModel {
    
    var subCategories = [BaseModel]()
    
    init(jsonDic: [String: Any]) {
        let id = jsonDic["id"] as! Int
        let name = jsonDic["name"] as! String
        super.init(id: id, name: name)
        
        let third = jsonDic["Third"] as! [[String: Any]]
        for item in third {
            
            let id = item["id"] as! Int
            let name = item["name"] as! String
            
            let sub = BaseModel(id: id, name: name)
            
            subCategories.append(sub)
        }
    }
}

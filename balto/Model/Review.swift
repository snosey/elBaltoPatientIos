//
//  Review.swift
//  balto
//
//  Created by Abanoub Osama on 4/20/18.
//  Copyright © 2018 Abanoub Osama. All rights reserved.
//

import Foundation

class Review: BaseModel {
    
    var rate: Int!
    
    var userId: Int!
    var userName: String!
    var userImage: String!
    
    init(jsonDic: [String: Any]) throws {
        let id = jsonDic["id"] as! Int
        let name = jsonDic["review"] as? String ?? ""
        super.init(id: id, name: name)
        
        rate = (jsonDic["rate"] as! NSString).integerValue
        
        if let user = jsonDic["user"] as? [String: Any] {
            
            userId = user["id"] as! Int
            userName = "\(user["first_name_en"] as? String ?? "") \(user["last_name_en"] as? String ?? "")"
            
            if let image = user["image"] as? String, !image.isEmpty {
                
                self.userImage = "http://haseboty.com/doctor/public/images/\(image)"
            } else {
                self.userImage = ""
            }
        }
    }
}

//
//  Category.swift
//  balto
//
//  Created by Abanoub Osama on 4/4/18.
//  Copyright © 2018 Abanoub Osama. All rights reserved.
//

import Foundation

class SubCategory: BaseModel {
    
    var logo: String!
    var description: String!
    var baseFare: Int!
    
    var idSub: Int!
    
    var maxHours: Int!
    var minHours: Int!
    
    var peicePerHour: Int!
    
    init(jsonDic: [String: Any]) {
        let id = jsonDic["id"] as! Int
        let name = jsonDic["name"] as! String
        super.init(id: id, name: name)
        
        logo = "http://haseboty.com/doctor/public/images/\(jsonDic["logo"] as! String)".replacingOccurrences(of: " ", with: "%20")
        
        description = jsonDic["description"] as! String
        
        baseFare = (jsonDic["base_fare"] as! NSString).integerValue
        
        idSub = jsonDic["id_sub"] as! Int
        
        maxHours = (jsonDic["max_hour"] as! NSString).integerValue
        minHours = (jsonDic["min_hour"] as! NSString).integerValue
        
        peicePerHour = (jsonDic["price_per_hour"] as! NSString).integerValue
    }
}

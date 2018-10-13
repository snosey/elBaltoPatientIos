//
//  Coupon.swift
//  balto
//
//  Created by Abanoub Osama on 3/29/18.
//  Copyright © 2018 Abanoub Osama. All rights reserved.
//

import Foundation

class Coupon: BaseModel {
    
    var addedBy: String!
    var discount:Float!
    
    init(jsonDic: [String: Any]) throws {
        
        let id = jsonDic["id"] as! Int
        let name = jsonDic["code"] as! String
        
        super.init(id: id, name: name)
        
        if let ammount = jsonDic["discount"] as? NSString {
            let x = ammount.integerValue
            discount = Float(x) / 100.0
        }
        
        addedBy = jsonDic["add_by"] as? String
    }
}

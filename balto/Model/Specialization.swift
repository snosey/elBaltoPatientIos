//
//  Category.swift
//  balto
//
//  Created by Abanoub Osama on 3/22/18.
//  Copyright © 2018 Abanoub Osama. All rights reserved.
//

import Foundation

class Specialization: BaseModel {
    
    var services = [BaseModel]()
    
    override init(id: Int, name: String) {
        super.init(id: id, name: name)
    }
}

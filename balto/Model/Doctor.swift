//
//  Doctor.swift
//  balto
//
//  Created by Abanoub Osama on 4/3/18.
//  Copyright © 2018 Abanoub Osama. All rights reserved.
//

import Foundation

class Doctor: User {
    
//    ▿ 0 : 2 elements
//    - key : "genderName"
//    - value : ذكر
//    ▿ 5 : 2 elements
//    - key : "id_gender"
//    - value : 1
//    ▿ 1 : 2 elements
//    - key : "id_language"
//    - value : 1
//    ▿ 4 : 2 elements
//    - key : "doctor_documents"
//    - value : 0 elements
//    ▿ 8 : 2 elements
//    - key : "spokenLanguage"
//    - value : العربيه
//    ▿ 16 : 2 elements
//    - key : "doctor_city"
//    ▿ value : 1 element
//    ▿ 0 : 4 elements
//    ▿ 0 : 2 elements
//    - key : id_city
//    - value : 1
//    ▿ 1 : 2 elements
//    - key : cityName
//    - value : القاهرة الجديدة
//    ▿ 2 : 2 elements
//    - key : id_government
//    - value : 1
//    ▿ 3 : 2 elements
//    - key : governmentName
//    - value : القاهرة
    
    var rate: Int!
    var price: String!
    var documents = [BaseModel]()
    
    override init(jsonDic: [String : Any]) throws {
        super.init()
        
        id = jsonDic["id"] as? Int ?? 0
        
        firstName = jsonDic["firstName"] as? String
        lastName = jsonDic["lastName"] as? String
        
        email = jsonDic["email"] as? String
        
        phone = jsonDic["phone"] as? String
        
        gender = BaseModel(id: jsonDic["id_gender"] as? Int ?? 0, name: jsonDic["genderName"] as? String ?? "")
        
        if let image = jsonDic["image"] as? String, !image.isEmpty {
            
            self.image = "http://haseboty.com/doctor/public/images/\(image)"
        } else {
            self.image = ""
        }
        
        if let specItems = jsonDic["doctor_sub"] as? [[String: Any]], !specItems.isEmpty {
            
            let specItem = specItems[0]
            
            specialization = BaseModel(id: specItem["id_sub"] as! Int, name: specItem["subName"] as! String)
        } else {
            
            specialization = BaseModel(id: jsonDic["id_sub"] as? Int ?? 0, name: jsonDic["subName"] as? String ?? "")
        }
        
        fcmToken = jsonDic["fcm_token"] as? String
        
        if let priceObject = jsonDic["price"] as? [String: Any] {
            
            if let price = priceObject["price"] as? String, !price.isEmpty {
                self.price = price
            } else if let price = priceObject["price_per_hour"] as? String, !price.isEmpty {
                self.price = price
            }
        }
        
        rate = jsonDic["total_rate"] as? Int ?? 0
        
        let docs = jsonDic["doctor_documents"] as? [[String: Any]] ?? [[String: Any]]()
        for doc in docs {
            
            let id = doc["id"] as! Int
            var image: String!
            if let img = doc["image"] as? String, !img.isEmpty {
                
                image = "http://haseboty.com/doctor/public/images/\(img)"
            } else {
                image = ""
            }
            
            documents.append(BaseModel(id: id, name: image))
        }
    }
}

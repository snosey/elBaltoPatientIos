//
//  User.swift
//  kora
//
//  Created by Abanoub Osama on 3/10/18.
//  Copyright © 2018 Abanoub Osama. All rights reserved.
//

import Foundation

class User: BaseModel {
    
    override var name: String {
        
        get {
            
            return "\(self.firstName ?? "") \(self.lastName ?? "")"
        }
        
        set {
        }
    }
    
    var firstName: String!
    
    var lastName: String!
    
    var email: String!
    
    var phone: String!
    
    var gender: BaseModel!
    
    var profession: BaseModel!
    
    var specialization: BaseModel!
    
    var locations: [BaseModel]!
    
    var language: BaseModel!
    
    var token: String!
    
    var fcmToken: String!
    
    var paymentToken: String!
    var maskedPan: String!
    var subType: String!
    
    var image: String!
    
    //id_doctor_kind
    //id_language
    //id_government
    //id_city[] ( array ) - array of cities
    //id_sub[] ( array ) - array of sub category
    
    init() {
        super.init(id: 0, name: "")
    }
    
    init(jsonDic: [String: Any]) throws {
        let id = jsonDic["id"] as! Int
        super.init(id: id, name: "")
        
        if let name = jsonDic["first_name_en"] as? String, !name.isEmpty {
            
            firstName = name
        } else if let name = jsonDic["first_name_ar"] as? String, !name.isEmpty {
            
            firstName = name
        } else if let name = jsonDic["firstName"] as? String, !name.isEmpty {
            
            firstName = name
        }
        
        if let name = jsonDic["last_name_en"] as? String, !name.isEmpty {
            
            lastName = name
        } else if let name = jsonDic["last_name_ar"] as? String, !name.isEmpty {
            
            lastName = name
        } else if let name = jsonDic["lastName"] as? String, !name.isEmpty {
            
            lastName = name
        }
        
        gender = BaseModel(id: jsonDic["id_gender"] as? Int ?? 0, name: jsonDic["genderName"] as? String ?? "")
        
        email = jsonDic["email"] as! String
        
        phone = jsonDic["phone"] as! String
        
        token = jsonDic["video_token"] as? String ?? ""
        
        fcmToken = jsonDic["fcm_token"] as? String
        
        if let t = jsonDic["payment_token"] as? String {
            
            paymentToken = t.replacingOccurrences(of: "<null>", with: "")
        }
        
        if let t = jsonDic["card_number"] as? String {
            
            maskedPan = t.replacingOccurrences(of: "<null>", with: "")
        }
        
        if let t = jsonDic["card_type"] as? String {
            
            subType = t.replacingOccurrences(of: "<null>", with: "")
        }
        
        if let image = jsonDic["image"] as? String, !image.isEmpty {
            if image.hasPrefix("http") {
                self.image = image
            }else {
                self.image = "http://haseboty.com/doctor/public/images/\(image)"
            }
        } else {
            self.image = ""
        }
    }
}

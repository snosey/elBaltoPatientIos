//
//  Schedule.swift
//  balto
//
//  Created by Abanoub Osama on 4/3/18.
//  Copyright © 2018 Abanoub Osama. All rights reserved.
//

import Foundation

class Schedule {
    
//    ▿ 1 : 2 elements
//    - key : "updated_at"
//    - value : 2018-05-02 11:39:47
//    ▿ 2 : 2 elements
//    - key : "id"
//    - value : 190
//    ▿ 3 : 2 elements
//    - key : "id_user"
//    - value : 144
//    ▿ 5 : 2 elements
//    - key : "created_at"
//    - value : 2018-05-02 11:39:47

    var id: Int!
    
    var date: String!
    
    var from: String!
    var to: String!
    
    var type: String!
    
    var isBooked = false
    var isMine = false
    
    var originalDate:Date!
    
    init(date scheduleDate: Date = Date(), serviceDuration: Int = 30) {
        
        let calendar = Calendar.current
        
        originalDate = scheduleDate
        var hour = calendar.component(Calendar.Component.hour, from: scheduleDate)
        var min = calendar.component(Calendar.Component.minute, from: scheduleDate)
        
        from = String(format: "%02d:%02d", hour, min)
        
        let toDate = calendar.date(byAdding: .minute, value: serviceDuration, to: scheduleDate)!
        
        hour = calendar.component(Calendar.Component.hour, from: toDate)
        min = calendar.component(Calendar.Component.minute, from: toDate)
        
        to = String(format: "%02d:%02d", hour, min)
        
        let year = calendar.component(Calendar.Component.year, from: scheduleDate)
        let month = calendar.component(Calendar.Component.month, from: scheduleDate)
        let day = calendar.component(Calendar.Component.day, from: scheduleDate)
        
        date = String(format: "%d-%02d-%02d", year, month, day)
        type = "home"
    }
    
    init(jsonDic: [String: Any]) throws {
        
        id = jsonDic["id"] as? Int
        
        let day = (jsonDic["day"] as! NSString).integerValue
        let month = (jsonDic["month"] as! NSString).integerValue
        let year = (jsonDic["year"] as! NSString).integerValue
        
        date = String(format: "%02d-%02d-%02d", year, month, day)
        
        from = String(format: "%02d:%02d", (jsonDic["from_hour"] as! NSString).integerValue, (jsonDic["from_minutes"] as! NSString).integerValue)
        
        to = String(format: "%02d:%02d", (jsonDic["to_hour"] as! NSString).integerValue, (jsonDic["to_minutes"] as! NSString).integerValue)
    }
}

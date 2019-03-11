//
//  Reservation.swift
//  balto
//
//  Created by Abanoub Osama on 4/5/18.
//  Copyright © 2018 Abanoub Osama. All rights reserved.
//

import Foundation
import CoreLocation

class Reservation: BaseModel {
    
    //    public static String bookingStateSearch = "1";
    //    public static String bookingStateProcessing = "2";
    //    public static String bookingStateStart = "3";
    //    public static String bookingStateWorking = "4";
    //    public static String bookingStateDone = "5";
    //    public static String bookingStateCancel = "6";
    //    public static String patientCanceled = "7";
    //    public static String doctorCanceled = "8";
    //    public static String doctorTimeout = "9";
    
    //    ▿ 1 : 2 elements
    //    - key : "id_payment_way"
    //    - value : 2
    //    ▿ 5 : 2 elements
    //    - key : "lastName"
    //    - value : mohamed
    //    ▿ 6 : 2 elements
    //    - key : "id_coupon_doctor"
    //    - value : 0
    //    ▿ 7 : 2 elements
    //    - key : "send_year"
    //    - value : 2018
    //    ▿ 9 : 2 elements
    //    - key : "send_hour"
    //    - value : 10
    //    ▿ 14 : 2 elements
    //    - key : "phone"
    //    - value : 01003063157
    //    ▿ 16 : 2 elements
    //    - key : "send_month"
    //    - value : 05
    //    ▿ 17 : 2 elements
    //    - key : "duration"
    //    - value : 30
    //    ▿ 18 : 2 elements
    //    - key : "id_client"
    //    - value : 109
    //    ▿ 19 : 2 elements
    //    - key : "receive_day"
    //    - value : 01
    //    ▿ 23 : 2 elements
    //    - key : "updated_at"
    //    - value : 2018-05-01 10:39:55
    //    ▿ 25 : 2 elements
    //    - key : "id_coupon_client"
    //    - value : 0
    //    ▿ 29 : 2 elements
    //    - key : "id_gender"
    //    - value : 1
    //    ▿ 30 : 2 elements
    //    - key : "send_day"
    //    - value : 01
    //    ▿ 31 : 2 elements
    //    - key : "review"
    //    - value : <null>
    //    ▿ 35 : 2 elements
    //    - key : "id_sub"
    //    - value : 11
    
    var price: String!
    var date: String!
    
    var rate: String!
    var id_rate: Int!
    var review: String!
    var image: String!
    
    var diagnosis: String!
    var medication: String!
    
    var idDoctor: Int!
    var idClient: Int!
    
    var doctorKind: BaseModel!
    
    var stateId: Int!
    var createAt: TimeInterval!
    
    var subCategoryName: String!
    var subId: Int!
    
    var serviceDuration: Int!
    
    var clientLocation: CLLocationCoordinate2D!
    var clientAddress: String!
    
    var fcmToken: String!
    
    var phone: String!
    
    var paymentMethodId: Int!
    
    var orignalDate : Date!
    
    var idCouponClient: Int!
    var wallet_id: Int!
    
    init(jsonDic: [String: Any]) {
        
        let id = jsonDic["id"] as! Int
        let name = jsonDic["firstName"] as? String ?? ""
        
        super.init(id: id, name: name)
        
        price = jsonDic["total_price"] as! String
        
        let hour = jsonDic["receive_hour"] as! String
        let min = jsonDic["receive_minutes"] as! String
        
        let day = jsonDic["receive_day"] as! String
        let month = jsonDic["receive_month"] as! String
        let year = jsonDic["receive_year"] as! String
        
        date = "\(year)-\(month)-\(day) \(hour):\(min)"
        
        if let rate = jsonDic["rate"] as? Int {
            self.rate = "\(rate)"
        } else if let rate = jsonDic["rate"] as? String {
            self.rate = rate
        }
        
        self.id_rate = jsonDic["id_rate"] as? Int
        if let review = jsonDic["review"] as? String {
            self.review = review as! String
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
        
        diagnosis = jsonDic["diagnosis"] as? String
        medication = jsonDic["medication"] as? String
        
        idDoctor = jsonDic["id_doctor"] as? Int ?? 0
        idClient = jsonDic["id_client"] as? Int ?? 0
        wallet_id = jsonDic["wallet_id"] as? Int ?? 0
        
        doctorKind = BaseModel(id: jsonDic["id_doctor_kind"] as? Int ?? 0, name: jsonDic["doctorKindName"] as? String ?? "")
        
        stateId = jsonDic["id_state"] as? Int ?? (jsonDic["id_state"] as! NSString).integerValue
        
        // 2018-05-19 18:45:49 "yyyy-MM-dd HH:mm:ss"
        createAt = DateUtils.getServerDateTime(dateString: jsonDic["created_at"] as! String).timeIntervalSince1970
        
        subCategoryName = jsonDic["subCategoryName"] as? String
        subId = jsonDic["id_sub"] as? Int
        
        if let s = jsonDic["duration"] as? NSString {
            
            serviceDuration = s.integerValue
        } else if let s = jsonDic["duration"] as? Int {
            
            serviceDuration = s
        } else {
            
            serviceDuration = 25
        }
        
        if let lat = jsonDic["client_latitude"] as? Double, let lng = jsonDic["client_longitude"] as? Double {
            
            clientLocation = CLLocationCoordinate2D(latitude: lat, longitude: lng)
        } else if let lat = jsonDic["client_latitude"] as? NSString, let lng = jsonDic["client_longitude"] as? NSString {
            
            clientLocation = CLLocationCoordinate2D(latitude: lat.doubleValue, longitude: lng.doubleValue)
        }
        
        clientAddress = jsonDic["client_address"] as! String
        
        fcmToken = jsonDic["fcm_token"] as? String ?? jsonDic["fcm_token_doctor"] as? String
        
        phone = jsonDic["phone"] as? String
        
        paymentMethodId = jsonDic["id_payment_way"] as? Int ?? 1
        
        orignalDate = DateUtils.getDate(dateString: date, dateFormat: "\(DateUtils.SERVER_DATE_FORMAT) \(DateUtils.SERVER_TIME_SHORT_FORMAT)")
        
        if let id = jsonDic["id_coupon_client"] as? NSString {
            
            idCouponClient = id.integerValue
        } else if let id = jsonDic["id_coupon_client"] as? Int {
            
            idCouponClient = id
        } else {
            
            idCouponClient = 0
        }
    }
}


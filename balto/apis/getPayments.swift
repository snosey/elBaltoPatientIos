//
//  getPayments.swift
//  Doctor ElBalto
//
//  Created by mac on 9/22/18.
//  Copyright © 2018 Abanoub Osama. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON

class DoctorsAPIS {
    
    class func getDoctorPayments(lang: String, doctorId: Int, completion: @escaping (_ success: JSON?, _ failure: Error?) -> Void) {
        
        let url = APIS_URLS.doctorPayments
        let params = [
            "id" : doctorId,
            "lang" : lang
        ] as [String: Any]
        
        Alamofire.request(url, method: .get, parameters: params, encoding: URLEncoding.default, headers: nil)
            .validate(statusCode: 200..<300)
            .responseJSON { (data) in
                
                switch data.result {
                case .success(let success) :
                    let json = JSON(success)
                    //save user email to the next time
                    completion(json, nil)
                case .failure(let failure) :
                    completion(nil, failure)
                }
        }
    }
    
    class func onlinePayment(user_id: Int, amount: String, state: String, completion: @escaping (_ success: JSON?, _ failure: Error?) -> Void) {
        
        let url = APIS_URLS.onlinePayment
        let params = [
            "amount": amount ,
            "user_id": user_id ,
        ] as [String : Any]
        
        Alamofire.request(url, method: .post, parameters: params, encoding: URLEncoding.default, headers: nil)
            .validate(statusCode: 200..<300)
            .responseJSON { (data) in
                switch data.result {
                case .success(let success) :
                    let json = JSON(success)
                    //save user email to the next time
                    completion(json, nil)
                case .failure(let failure) :
                    completion(nil, failure)
                }
        }
    }
    
    class func walletPayment(user_id: Int, amount: String, phone: String, completion: @escaping (_ success: JSON?, _ failure: Error?) -> Void) {
        
        let url = APIS_URLS.walletPayment
        let params = [
            "amount"  : amount,
            "user_id" : user_id,
            "phone"   : phone,
        ] as [String  : Any]
        
        Alamofire.request(url, method: .post, parameters: params, encoding: URLEncoding.default, headers: nil)
            .validate(statusCode: 200..<300)
            .responseJSON { (data) in
                
                switch data.result {
                case .success(let success) :
                    let json = JSON(success)
                    //save user email to the next time
                    completion(json, nil)
                case .failure(let failure) :
                    completion(nil, failure)
                }        
        }
        
    }
    
    class func amanPayment(user_id: Int, amount: String , completion: @escaping (_ success: JSON?, _ failure: Error?) -> Void) {
        
        let url = APIS_URLS.amanPayment
        let params = [
            "amount": amount,
            "user_id": user_id ,
        ] as [String: Any]
        
        Alamofire.request(url, method: .post, parameters: params, encoding: URLEncoding.default, headers: nil)
            .validate(statusCode: 200..<300)
            .responseJSON { (data) in
                
                switch data.result {
                case .success(let success) :
                    let json = JSON(success)
                    //save user email to the next time
                    completion(json, nil)
                case .failure(let failure) :
                    completion(nil, failure)
                }
                
        }
        
    }
    
    
    class func addUserTransaction(params: [String: Any], completion: @escaping (_ success: JSON?, _ failure: Error?) -> Void) {
        
        let url = APIS_URLS.addUserTransaction
        
        Alamofire.request(url, method: .get, parameters: params, encoding: URLEncoding.default, headers: nil)
            .validate(statusCode: 200..<300)
            .responseJSON { (data) in
                
                switch data.result {
                case .success(let success) :
                    let json = JSON(success)
                    //save user email to the next time
                    completion(json, nil)
                case .failure(let failure) :
                    completion(nil, failure)
                }
                
        }
        
    }
    
}

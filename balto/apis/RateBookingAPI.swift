//
//  RateBookingAPI.swift
//  ElBalto
//
//  Created by rocky on 12/4/18.
//  Copyright © 2018 Abanoub Osama. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class RateBookingAPI {
    
    class func editRateBooking(params: [String: Any], completion: @escaping (_ success: JSON?, _ failure: Error?) -> Void) {
        
        let url = APIS_URLS.editRateBooking
        
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
    
    class func deleteRateBooking(params: [String: Any], completion: @escaping (_ success: JSON?, _ failure: Error?) -> Void) {
        
        let url = APIS_URLS.deleteRateBooking
        
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

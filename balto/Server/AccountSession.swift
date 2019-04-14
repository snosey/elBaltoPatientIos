//
//  AccountSession.swift
//  kora
//
//  Created by Abanoub Osama on 3/9/18.
//  Copyright © 2018 Abanoub Osama. All rights reserved.
//

import Foundation
import UIKit

public class AccountSession: BaseUrlSession {
    
    var delegate: AccountDelegate!
    
    var language = LocalizationSystem.sharedInstance.getLanguage()
    
    public enum ActionType {
        case getRegistrationData, getGender, geState, getLanguage, getCities, getProfessions,
        checkEmail, Register, Login, FacebookLogin, ForgetPassword, checkCoupon, addCouponForUser,
        addCoupon
    }
    
    init<T: AccountDelegate>(delegate: T)  {
        super.init()
        
        self.delegate = delegate
    }
    
    func getRegistrationData(language: String) {
        self.language = language
        
        let actionType = ActionType.getRegistrationData
        
        let url = UrlBuilder(baseUrl: "http://haseboty.com/doctor/public/api/dataSingup")
        url.put("type", language)
        
        requestConnection(action: actionType, url: url.build(), shouldLoadFromCache: true)
    }
    
    func checkEmail(email: String) {
        
        let actionType = ActionType.checkEmail
        
        let url = UrlBuilder(baseUrl: "http://haseboty.com/doctor/public/api/userCheck")
        url.put("email", email)
        
        requestConnection(action: actionType, url: url.build(), shouldCache: true)
    }
    
    func register(user: User, password: String, providerId: String! = nil) {
        
        let actionType = ActionType.Register
        
        let url = UrlBuilder(baseUrl: "http://haseboty.com/doctor/public/api/singUp?")
        
        url.put("first_name_ar", "\(user.firstName ?? "")")
           .put("last_name_ar", "\(user.lastName ?? "")")
           .put("first_name_en", "\(user.firstName ?? "")")
           .put("last_name_en", "\(user.lastName ?? "")")
           .put("phone", "\(user.phone ?? "")")
           .put("email", "\(user.email ?? "")")
           .put("id_language", "\(user.language?.id ?? 0)")
           .put("id_gender", "\(user.gender.id)")
           .put("type", "client")
        
        
        
        if let providerId = providerId {
            
            url.put("id_provider", providerId)
                .put("provider_kind", "facebook")

        } else {
            
            url.put("password", password)
        }
        
        if let profession = user.profession {
            url.put("id_doctor_kind", profession.id)
        }
        
        if let locations = user.locations {
        
            for location in locations {
            
                url.put("id_city[]", location.id)
            }
        }
        
        if let specialization = user.specialization {
            
            url.put("id_sub[]", specialization.id)
        }
        
        requestConnection(action: actionType, url: url.build(), shouldCache: true)
    }
    
    func login(email: String, password: String) {
        
        let actionType = ActionType.Login
        
        let url = UrlBuilder(baseUrl: "http://haseboty.com/doctor/public/api/login?")
        
        url.put("email", email)
            .put("password", password)
            .put("type", "client")
            .put("fcm_token", "saddsa")
        
        requestConnection(action: actionType, url: url.build(), shouldCache: false)
    }
    
    func facebookLogin(facebookId: String) {
        
        let actionType = ActionType.FacebookLogin
        
        let url = UrlBuilder(baseUrl: "http://haseboty.com/doctor/public/api/login?")
        
        url.put("id_provider", facebookId)
            .put("type", "client")
            .put("provider_kind", "facebook")
            .put("fcm_token", "saddsa")
       
        
        requestConnection(action: actionType, url: url.build(), shouldCache: false)
    }
    
    func forgetPassword(email: String) {
        
        let actionType = ActionType.ForgetPassword
        
        let url = UrlBuilder(baseUrl: "http://haseboty.com/doctor/public/api/forgetPassword?")
        
        url.put("email", email)
        
        requestConnection(action: actionType, url: url.build(), shouldCache: false)
    }
    
    func checkCopoun(code: String)  {
        
        let actionType = ActionType.checkCoupon
        
        let url = UrlBuilder(baseUrl: "http://haseboty.com/doctor/public/api/checkCoupon?")
        url.put("code", code)
        
        requestConnection(action: actionType, url: url.build(), shouldCache: true)
    }
    
    func addCouponForUser(couponId: Int, userId: Int)  {
        
        let actionType = ActionType.addCouponForUser
        
        let url = UrlBuilder(baseUrl: "http://haseboty.com/doctor/public/api/CouponUser?")
        url.put("id_coupon", couponId)
            .put("id_user", userId)
        
        requestConnection(action: actionType, url: url.build(), shouldCache: true)
    }
    
    func addCoupon(userId: Int)  {
        
        let actionType = ActionType.addCoupon
        
        let url = UrlBuilder(baseUrl: "http://haseboty.com/doctor/public/api/Add_coupon?")
        url.put("add_by", userId)
        
        requestConnection(action: actionType, url: url.build(), shouldCache: true)
    }
    
    func getUDID() -> String {
        return UIDevice.current.identifierForVendor!.uuidString
    }
    
    override func onPreExecute(action: Any) {
        delegate.onPreExecute(action: action as! AccountSession.ActionType)
    }
    
    func onPreExecute(action: ActionType) {
        delegate.onPreExecute(action: action)
    }
    
    override func onSuccess(action: Any, response: URLResponse!, data: Data!) {
        let actionType: ActionType = action as! AccountSession.ActionType
        do {
            let res = String(data: data, encoding: .ascii)
            print(res ?? "")
            var jsonResponse = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String: Any] ?? [String: Any]()
            
            let success = jsonResponse["status"] as? Bool ?? true
            
            if success {
                switch actionType {
                case .getRegistrationData:
                    
                    var genders = [BaseModel]()
                    let gendersArray = jsonResponse["gender"] as! [[String: Any]]
                    for item in gendersArray {
                        
                        let gender = BaseModel(id: item["id"] as! Int, name: item["name"] as! String)
                        genders.append(gender)
                    }
                    delegate.onPostExecute(status: Status(200, true, ""), action: .getGender, response: genders)
                    
                    var states = [BaseModel]()
                    let statesArray = jsonResponse["state"] as! [[String: Any]]
                    for item in statesArray {
                        
                        let state = BaseModel(id: item["id"] as! Int, name: item["name"] as! String)
                        states.append(state)
                    }
                    delegate.onPostExecute(status: Status(200, true, ""), action: .geState, response: states)
                    
                    var languages = [BaseModel]()
                    let languagesArray = jsonResponse["language"] as! [[String: Any]]
                    for item in languagesArray {
                        
                        let language = BaseModel(id: item["id"] as! Int, name: item["name"] as! String)
                        languages.append(language)
                    }
                    delegate.onPostExecute(status: Status(200, true, ""), action: .getLanguage, response: languages)
                    
                    var cities = [BaseModel]()
                    let citiesArray = jsonResponse["cities"] as! [[String: Any]]
                    for item in citiesArray {
                        
                        let city = BaseModel(id: item["id"] as! Int, name: item["name"] as! String)
                        cities.append(city)
                    }
                    delegate.onPostExecute(status: Status(200, true, ""), action: .getCities, response: cities)
                    
                    var professions = [Profession]()
                    let professionsArray = jsonResponse["category"] as! [[String: Any]]
                    for item in professionsArray {
                        
                        let profession = Profession(id: item["id"] as! Int, name: item["name"] as! String)
                        
                        let specializationsArray = item["sub_\(language)"] as! [[String: Any]]
                        
                        for item in specializationsArray {
                            
                            let specialization = Specialization(id: item["id"] as! Int, name: item["name"] as! String)
                            
                            let servicesArray = item["doctorkind"] as! [[String: Any]]
                            
                            for item in servicesArray {
                                
                                let name =  (item["doctor_kind_\(language)"] as! [String: Any])["name"] as! String
                                let service = BaseModel(id: item["id_doctor_kind"] as! Int, name: name)
                                
                                specialization.services.append(service)
                            }
                            
                            profession.specializations.append(specialization)
                        }
                        
                        professions.append(profession)
                    }
                    delegate.onPostExecute(status: Status(200, true, ""), action: .getProfessions, response: professions)
                    break
                case .checkEmail,.ForgetPassword:
                    
                    let isValid = jsonResponse["status"] as! Bool
                    
                    delegate.onPostExecute(status: Status(200, true, ""), action: actionType, response: isValid)
                    break
                case .Register, .Login, .FacebookLogin:
                    
                    let user = try? User(jsonDic: jsonResponse["user"] as! [String: Any])
                    
                    delegate.onPostExecute(status: Status(200, user != nil, ""), action: actionType, response: user)
                    break
                case .checkCoupon:
                    
                    let success = jsonResponse["status"] as! Bool
                    
                    let couponDic = jsonResponse["coupon"] as! [String: Any]
                    
                    let coupon = try? Coupon(jsonDic: couponDic)
                    
                    delegate.onPostExecute(status: Status(200, success, ""), action: actionType, response: coupon)
                    break
                case .addCoupon:
                    
                    let coupon = try? Coupon(jsonDic: jsonResponse)
                    
                    delegate.onPostExecute(status: Status(200, true, ""), action: actionType, response: coupon)
                    break
                case .addCouponForUser:
                    break
                default:
                    delegate.onPostExecute(status: Status(200, true, ""), action: actionType, response: nil)
                    break
                }
            } else {
                let code = jsonResponse["error_code"] as? Int ?? -1
                var codeMessage = "..."
                
                if let message = jsonResponse["messages"] as? [String: Any],
                    let messages = message[message.keys.first!] as? [String] {
                    
                    codeMessage = messages[0]
                } else if let message = jsonResponse["messages"] as? String {
                    
                    codeMessage = message
                }
                onFailure(action: actionType, error: NSError(domain: codeMessage, code: code, userInfo: nil))
            }
        } catch {
            onFailure(action: actionType, error: error as NSError)
        }
    }
    
    override func onFailure(action: Any, error: NSError) {
        delegate.onPostExecute(status: Status(error: error), action: action as! AccountSession.ActionType, response: nil)
    }
}

public protocol AccountDelegate {
    
    func onPreExecute(action: AccountSession.ActionType)
    
    func onPostExecute(status: BaseUrlSession.Status, action: AccountSession.ActionType, response: Any!)
}

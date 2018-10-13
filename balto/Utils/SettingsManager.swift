//
//  SettingsManager.swift
//  Syariti
//
//  Created by Mena on 9/17/17.
//  Copyright © 2017 Mena. All rights reserved.
//

import Foundation

class SettingsManager {
    
    enum Settings : String {
        case  FirstTime, Skip, IsLoggedIn, UserToken, UserId, FullName, Email, ProfilePic, DeviceToken, type, Password
    }
    
    var userDefault: UserDefaults
    
    init() {
        userDefault = UserDefaults.standard
    }
    
    func setDeviceToken(value : String) {
        let _ =  save(object: value, setting: Settings.DeviceToken)
    }
    
    func getDeviceToken() -> String{
        if let object = userDefault.object(forKey: Settings.DeviceToken.rawValue) {
            return object as! String
        }
        return ""
    }
    
    func setFirstTime(value : Bool) {
       let _ =  save(object: value, setting: Settings.FirstTime)
    }
    
    func setLoggedIn(value:Bool) {
        if (!value) {
                resetAccount()
        }
        let _ = save(object: value, setting: Settings.IsLoggedIn)
    }
    
    func setSkip(value:Bool) {
        if (!value) {
            resetAccount()
        }
        let _ = save(object: value, setting: Settings.Skip)
    }
    
    func updateUser(user : User) {
        setUserId(value: user.id)
        
        if let token = user.token, !token.isEmpty {
            setLoggedIn(value: true)
            setUserToken(value: user.token)
            
//            Crashlytics.sharedInstance().setUserEmail(user.email!)
//            Crashlytics.sharedInstance().setUserIdentifier("\(user.id)")
//            Crashlytics.sharedInstance().setUserName(user.name!)
        }
        
        setFullName(value: user.name)
        setEmail(value: user.email ?? "")
//        setPhoneNumber(value: user.phoneNumber)
        setProfilePic(value: user.image)
//        setAccountType(value: user.accountType.rawValue)
        
        if let token = user.paymentToken {
        
            let _ = PaymentSession.saveWith(key: "savedToken", value: token)
        }
        
        if let pan = user.maskedPan {
        
            let _ = PaymentSession.saveWith(key: "masked_pan", value: pan)
        }
        
        if let type = user.subType {
            
            let _ = PaymentSession.saveWith(key: "card_subtype", value: type)
        }
    }
    
    func getUser () -> User {
        
        let user = User()
        user.id = getUserId()
        user.token = getUserToken()
        user.name = getFullName()
        user.email = getEmail()
        user.image = getProfilePic()
        
        return user
    }
    
    func resetAccount() {
        
        setUserToken(value: "")
        setEmail(value: "")
        setFullName(value: "")
        setUserId(value: 0)
        
        let userDefault = UserDefaults.standard
        
        userDefault.set(nil, forKey: "savedToken")
        userDefault.set(nil, forKey: "masked_pan")
        userDefault.set(nil, forKey: "card_subtype")
        
        userDefault.synchronize()
    }
    
    func setIsloggedIn (value:Bool){
        let _ = save(object: value, setting: Settings.IsLoggedIn)
    }
    
    func setUserToken(value :String) {
      let _ =  save(object: value, setting: Settings.UserToken)
    }
    
    func setUserId( value : Int) {
        let _ = save(object: value, setting: Settings.UserId)
    }
    
    func setFullName( value : String) {
       let _ = save(object: value, setting: Settings.FullName)
    }
    
    func setPassword( value : String) {
        let _ = save(object: value, setting: Settings.Password)
    }
    
    func setEmail( value:String) {
       let _ = save(object: value, setting: Settings.Email)
    }
    
    func setProfilePic(value : String) {
      let _ =  save(object: value, setting: Settings.ProfilePic)
    }
    
    func isFirstTime() ->Bool {
        if let object = userDefault.object(forKey: Settings.FirstTime.rawValue) {
            return object as! Bool
        }
        return true

    }
    
    func isLoggedIn() -> Bool {
        if let object = userDefault.object(forKey: Settings.IsLoggedIn.rawValue) {
            return object as! Bool
        }
        return false
    }
    
    func isSkip() -> Bool {
        if let object = userDefault.object(forKey: Settings.Skip.rawValue) {
            return object as! Bool
        }
        return false
    }
    
    func getUserToken()  -> String {
        if let object = userDefault.object(forKey: Settings.UserToken.rawValue) {
            return object as! String
        }
        return ""
    }
    
    func getUserId() -> Int  {
        if let object = userDefault.object(forKey: Settings.UserId.rawValue) {
            return object as! Int
        }
        return 0
    }
    
    func getFullName() -> String {
        if let object = userDefault.object(forKey: Settings.FullName.rawValue) {
            return object as! String
        }
        return ""
    }
    
    func getPassword() -> String {
        if let object = userDefault.object(forKey: Settings.Password.rawValue) {
            return object as! String
        }
        return ""
    }
    
    func getEmail() -> String{
        if let object = userDefault.object(forKey: Settings.Email.rawValue) {
            return object as! String
        }
        return ""

    }
    
    func getProfilePic() -> String! {
        if let object = userDefault.object(forKey: Settings.ProfilePic.rawValue) {
            return object as! String
        }
        return nil
    }
    
    func getType() -> Int  {
        if let object = userDefault.object(forKey: Settings.type.rawValue) {
            return object as! Int
        }
        return 0
    }
    
    func setType(value : Int) {
        let _ =  save(object: value, setting: Settings.type)
    }

    private func save(object: Any, setting: Settings) -> Bool {
        if (object is Int) {
            userDefault.set(object as! Int, forKey: setting.rawValue)
        } else if (object is Bool) {
            userDefault.set(object as! Bool, forKey: setting.rawValue)
        } else if (object is String) {
            userDefault.set(object as! String, forKey: setting.rawValue)
        } else {
            userDefault.set(object, forKey: setting.rawValue)
        }
        
        return userDefault.synchronize()
    }
}

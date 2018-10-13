//
//  SoicalViewController.swift
//  Syariti
//
//  Created by Mena on 9/17/17.
//  Copyright © 2017 Mena. All rights reserved.
//
//
//  SocialViewController.swift
//  Barek
//
//  Created by Abanoub Osama on 2/3/17.
//  Copyright © 2017 Abanoub Osama. All rights reserved.
//

import Foundation
import UIKit
import FacebookLogin
import FacebookCore

class SocialViewController: UIViewController {
    
    let GOOGLE_HIDEN_BUTTON_TAG = 130
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    func loginWithFacebook() {
        
        let loginManager = LoginManager()
        loginManager.logIn(readPermissions: [ReadPermission.publicProfile ,ReadPermission.email], viewController: self) { (login) in
            switch login {
            case .failed(let error):
                print(error.localizedDescription)
                break
            case .cancelled:
                print("cancelled")
                break
            case .success(grantedPermissions: _, declinedPermissions: _, let accessToken):
                self.getFacebookUser(accessToken: accessToken)
                loginManager.logOut()
                break
            }
        }

    }
    
    private func getFacebookUser(accessToken: AccessToken) {
        
        let connection = GraphRequestConnection()
        
        connection.add(GraphRequest(graphPath: "/me", parameters: ["fields": "id, name, email, gender"], accessToken: accessToken, httpMethod: .GET, apiVersion: .defaultVersion)) { response, result in
            
            switch result {
            case.success(let response):
                let value = response.dictionaryValue as! [String: String]
                
                let user = SocialUser()
                
                user.id = value["id"] ?? ""
                user.type = "facebook"
                user.email = value["email"]
                
                user.gender = value["gender"]
                let name = value["name"] ?? ""
                let split = name.components(separatedBy: " ")
                
                user.fname = split[0]
                
                user.lname = split.count > 0 ? split[1] : split[0]
                
                self.finishLoginWithFacebook(user: user, message: "success")
                // get data and call registration api
                
                break
            case.failed(let error):
                print("error Iam here \(error)")
                self.finishLoginWithFacebook(user: nil, message: error.localizedDescription)
                break
            }
        }
        
        connection.start()
    }
    
    func finishLoginWithFacebook(user: SocialUser!, message: String) {
        
    }
    
    public class SocialUser {
        
        var id: String = ""
        var type: String = ""
        var email: String!
        var fname: String = ""
        var lname: String!
        var gender: String!
        
    }
}

//
//  Account2ViewController.swift
//  balto
//
//  Created by Abanoub Osama on 4/26/18.
//  Copyright © 2018 Abanoub Osama. All rights reserved.
//

import UIKit

class Account2ViewController: SocialViewController, AccountDelegate {
    
    var account: AccountSession!
    var loadingView: LoadingView!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        account = AccountSession(delegate: self)
        
        loadingView = LoadingView(frame: view.frame)
        loadingView.setLoadingImage(image: UIImage(named: "loading")!)
        loadingView.backgroundColor = UIColor.white.withAlphaComponent(0.8)
        loadingView.isHidden = true
        self.view.addSubview(loadingView)

        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.isHidden = false
    }
    
    @IBAction func facebookLogin(_ sender: UIButton) {
        
        loginWithFacebook()
    }
    
    var socialUser: SocialUser!
    
    override func finishLoginWithFacebook(user: SocialViewController.SocialUser!, message: String) {
        
        if let user = user {
            
            socialUser = user
            
            account.facebookLogin(facebookId: user.id)
        } else {
            
            Toast.showAlert(viewController: self, text: message)
        }
    }
    
    func onPreExecute(action: AccountSession.ActionType) {
        loadingView.setIsLoading(true)
    }
    
    func onPostExecute(status: BaseUrlSession.Status, action: AccountSession.ActionType, response: Any!) {
        loadingView.setIsLoading(false)
        
        switch action {
        case .Login, .FacebookLogin:
            
            if status.success {
                
                let user = response as! User
                
                let settingsManager = SettingsManager()
                settingsManager.updateUser(user: user)
                settingsManager.setType(value: 0)
                
                let main = UIStoryboard(name: "Main", bundle: nil)
                let vc = main.instantiateInitialViewController()
                
                let window = UIApplication.shared.keyWindow!
                
                window.rootViewController = vc
                window.makeKeyAndVisible()
            } else if action == .FacebookLogin {
                
                let vc = storyboard?.instantiateViewController(withIdentifier: "RegistrationViewController") as! RegistrationViewController
                vc.socialUser = socialUser
                self.show(vc, sender: self)
            } else {
                Toast.showAlert(viewController: self, text: status.message)
            }
            break
        default:
            break
        }
    }
}

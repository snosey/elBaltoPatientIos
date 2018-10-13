//
//  LoginViewController.swift
//  kora
//
//  Created by Abanoub Osama on 3/9/18.
//  Copyright © 2018 Abanoub Osama. All rights reserved.
//

import UIKit

class LoginViewController: SocialViewController, AccountDelegate {
    
    @IBOutlet weak var textFieldEmail: UITextField!
    @IBOutlet weak var textFieldPassword: UITextField!
    
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
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissMyKeyboard))
        view.addGestureRecognizer(tap)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.isHidden = false
    }
    
    @IBAction func login(_ sender: UIButton) {
        
        let email = textFieldEmail.text!
        if email.isEmpty {
            
            Toast.showAlert(viewController: self, text: LocalizationSystem.sharedInstance.localizedStringForKey(key:"mail_empty", comment: ""))
            return
        } else if email.range(of:  "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}", options: .regularExpression, range: nil, locale: nil) == nil {
            
            Toast.showAlert(viewController: self, text: LocalizationSystem.sharedInstance.localizedStringForKey(key:"invalidEmail", comment: ""))
            return
        }
        
        let password = textFieldPassword.text!
        if password.count < 6 {
            
            Toast.showAlert(viewController: self, text: LocalizationSystem.sharedInstance.localizedStringForKey(key:"WrongPassword", comment: ""))
            return
        }
        
        account.login(email: email, password: password)
    }
    
    @IBAction func facebookLogin(_ sender: UIButton) {
        
        loginWithFacebook()
    }
    
    @IBAction func forgetPassword(_ sender: UIBarButtonItem) {
        
        var alert: UIAlertController!
        
        let submit = UIAlertAction(title: LocalizationSystem.sharedInstance.localizedStringForKey(key:"done", comment: ""), style: .default) { (action) in
            
            let textFieldEmail = alert!.textFields![0]
            
            let email = textFieldEmail.text!
            if email.isEmpty {
                
                Toast.showAlert(viewController: self, text: LocalizationSystem.sharedInstance.localizedStringForKey(key:"mail_empty", comment: "")) { (action) in
                    
                    self.forgetPassword(sender)
                }
                return
            } else if email.range(of:  "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}", options: .regularExpression, range: nil, locale: nil) == nil {
                
                Toast.showAlert(viewController: self, text: LocalizationSystem.sharedInstance.localizedStringForKey(key:"enter_valid_email", comment: "")) { (action) in
                    
                    self.forgetPassword(sender)
                }
                return
            }
            
            self.account.forgetPassword(email: email)
        }
        
        let cancel = UIAlertAction(title: LocalizationSystem.sharedInstance.localizedStringForKey(key:"cancel", comment: ""), style: .default, handler: nil)
        
        alert = Toast.showAlert(viewController: self, title: LocalizationSystem.sharedInstance.localizedStringForKey(key:"Forget Password", comment: ""), text: "enter your email", fieldHints: ["email"], cancel, submit)
    }
    
    func isValidEmail(testStr:String) -> Bool {
        // print("validate calendar: \(testStr)")
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluate(with: testStr)
    }
    
    var socialUser: SocialUser!
    
    override func finishLoginWithFacebook(user: SocialViewController.SocialUser!, message: String) {
        
        if let user = user {
            
            socialUser = user
            
            account.facebookLogin(facebookId: user.id)
        } else {
            
            Toast.showAlert(viewController: self, text: message)
        }
    } // end  of finishLoginWithFacebook

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
        case .ForgetPassword:
            if status.success {
                
                Toast.showAlert(viewController: self, text: LocalizationSystem.sharedInstance.localizedStringForKey(key:"we_will_send_you_the_password_rest_instructions", comment: ""))
            } else {
                Toast.showAlert(viewController: self, text: status.message)
            }
            break
        default:
            break
        }
    }
    
    @objc func dismissMyKeyboard() {
        view.endEditing(true)
    }
}

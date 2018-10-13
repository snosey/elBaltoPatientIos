//
//  ConfirmationViewController.swift
//  balto
//
//  Created by Abanoub Osama on 3/22/18.
//  Copyright © 2018 Abanoub Osama. All rights reserved.
//

import UIKit
import FirebaseAuth

class ConfirmationViewController: UIViewController, UITextFieldDelegate, AccountDelegate {
    
    @IBOutlet weak var stackViewNumber: UIStackView!
    @IBOutlet weak var textfieldCode: UITextField!
    
    var loadingView: LoadingView!
    var account: AccountSession!
    
    var verificationID: String!
    
    var coupon: Coupon!
    
    var isVerified = false
    var isAddingForUser = false
    var hasAgreedToTerms = false
    
    var user: User!
    var password: String!
    
    var socialUser: SocialViewController.SocialUser!
    
    var userId: Int!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        account = AccountSession(delegate: self)
        
        loadingView = LoadingView(frame: view.frame)
        loadingView.setLoadingImage(image: UIImage(named: "loading")!)
        loadingView.backgroundColor = UIColor.white.withAlphaComponent(0.8)
        loadingView.isHidden = true
        self.view.addSubview(loadingView)
        
        verificationID = UserDefaults.standard.string(forKey: "authVerificationID")
        
        for i in 1...6 {
            
            let textField = self.view.viewWithTag(i) as! UITextField
            textField.delegate = self
        }
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismisKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
        
        if Constants.language == "ar" {
            stackViewNumber.semanticContentAttribute = .forceLeftToRight
        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.backgroundColor = UIColor.clear
        self.navigationController?.navigationBar.isTranslucent = true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        var changeText = false
        
        // backspace or one charachter
        if string.count == 0 || textField.text?.count == 0 {
            
            changeText = true
        }
        
        if changeText {
            
            var text = textField.text!
            
            if text.isEmpty && !string.isEmpty && string.count < 2 {
                
                text = string
                
                if let nextTextField = self.view.viewWithTag(textField.tag + 1) as? UITextField {
                    
                    OperationQueue.main.addOperation {
                        
                        nextTextField.becomeFirstResponder()
                    }
                }
            } else {
                
                text = string
                
                if let prevTextField = self.view.viewWithTag(textField.tag - 1) as? UITextField {
                    
                    OperationQueue.main.addOperation {
                        
                        prevTextField.becomeFirstResponder()
                    }
                }
            }
        }
        
        return changeText
    }
    
    func textFieldDidBeginEditing(_ textFieldd: UITextField) {
        
        for i in 0...textFieldd.tag {
            
            if let textField = self.view.viewWithTag(i) as? UITextField, textField.text!.isEmpty {
                
                textField.becomeFirstResponder()
                return
            }
        }
    }
    
    @IBAction func resendVerificationCode(_ sender: UIButton) {
        
        loadingView.setIsLoading(true)
        
        PhoneAuthProvider.provider().verifyPhoneNumber("\(user.phone)", uiDelegate: nil) { (verificationID, error) in
            self.loadingView.setIsLoading(false)
            if let er = error as NSError? {
                Toast.showAlert(viewController: self, text: er.localizedDescription)
            } else {
                
                self.verificationID = verificationID
                
                UserDefaults.standard.set(verificationID, forKey: "authVerificationID")
                
                Toast.showAlert(viewController: self, text: "Verification code resent successfully")
            }
        }
    }
    
    @IBAction func showTerms(_ sender: UIButton) {
        let main = UIStoryboard(name: "Main", bundle: nil)
        let vc = main.instantiateViewController(withIdentifier: "StaticContentViewController") as! StaticContentViewController
        vc.viewControllerType = .TermsAndConditions
        show(vc, sender: nil)
    }
    
    @IBAction func toggleAgress(_ sender: UIButton) {
        
        if hasAgreedToTerms {
            
            sender.setImage(UIImage(named: "ic_checkbox_unchecked"), for: .normal)
            hasAgreedToTerms = false
        } else {
            
            sender.setImage(UIImage(named: "ic_checkbox_checked"), for: .normal)
            hasAgreedToTerms = true
        }
    }
    
    @IBAction func confirmCode(_ sender: UIButton) {
        
        if !textfieldCode.text!.isEmpty {
            account.checkCopoun(code: textfieldCode.text!)
        }
    }
    
    @IBAction func confirm(_ sender: UIButton) {
        
        if !hasAgreedToTerms {
            
            Toast.showAlert(viewController: self, text: "Please review and agree to the terms and conditions")
            return
        }
        
        if isVerified {
            
            if let userId = userId {
                
                if let coupon = self.coupon {
                    
                    self.account.addCouponForUser(couponId: coupon.id, userId: userId)
                    self.account.addCoupon(userId: self.userId)
                } else if !self.textfieldCode.text!.isEmpty {
                    
                    self.account.checkCopoun(code: self.textfieldCode.text!)
                } else {
                    
                    let main = UIStoryboard(name: "Main", bundle: nil)
                    let vc = main.instantiateInitialViewController()
                    
                    let window = UIApplication.shared.keyWindow!
                    
                    window.rootViewController = vc
                    window.makeKeyAndVisible()
                }
            } else {
                
                if let id = socialUser?.id {
                    
                    account.register(user: user, password: password,providerId: id)
                } else {
                
                    account.register(user: user, password: password)
                }
            }
        } else {
            
            var verificationCode = ""
            for i in 1...6 {
                let textField = self.view.viewWithTag(i) as! UITextField
                verificationCode.append(textField.text!)
            }
            
            if verificationCode.count != 6 {
                
                Toast.showAlert(viewController: self, text: "Please enter valid verification code")
                return
            }
            
            let credential = PhoneAuthProvider.provider().credential(
                withVerificationID: verificationID,
                verificationCode: verificationCode)
            
            loadingView.setIsLoading(true)
            Auth.auth().signIn(with: credential) { (user, error) in
                
                self.loadingView.setIsLoading(false)
                
                if let error = error as NSError? {
                    
                    Toast.showAlert(viewController: self, text: error.localizedDescription)
                } else {
                    
                    self.isVerified = true
                    
                    if let id = self.socialUser?.id {
                        
                        self.account.register(user: self.user, password: self.password,providerId: id)
                    } else {
                        
                        self.account.register(user: self.user, password: self.password)
                    }
                }
            }
        }
    }
    
    @objc func dismisKeyboard() {
        view.endEditing(true)
    }
    
    func onPreExecute(action: AccountSession.ActionType) {
        loadingView.setIsLoading(true)
    }
    
    func onPostExecute(status: BaseUrlSession.Status, action: AccountSession.ActionType, response: Any!) {
        loadingView.setIsLoading(false)
        if status.success {
            switch action {
            case .Register:
                
                let user = response as! User
                
                let settingsManager = SettingsManager()
                
                settingsManager.updateUser(user: user)
                settingsManager.setType(value: 1)
                
                self.userId = user.id
                
                if let coupon = self.coupon {
                    
                    self.account.addCouponForUser(couponId: coupon.id, userId: self.userId)
                    self.account.addCoupon(userId: self.userId)
                } else if !self.textfieldCode.text!.isEmpty {
                    
                    self.account.checkCopoun(code: self.textfieldCode.text!)
                } else {
                    
                    let main = UIStoryboard(name: "Main", bundle: nil)
                    let vc = main.instantiateInitialViewController()
                    
                    let window = UIApplication.shared.keyWindow!
                    
                    window.rootViewController = vc
                    window.makeKeyAndVisible()
                }
                break
            case .checkCoupon:
                
                coupon = response as! Coupon
                
                if let userId = self.userId {
                    
                    self.account.addCouponForUser(couponId: coupon.id, userId: userId)
                    self.account.addCoupon(userId: userId)
                } else {
                    
                    Toast.showAlert(viewController: self, text: "Coupon code is valid")
                }
                break
            case .addCoupon:
                
                let coupon = response as! Coupon
                
                isAddingForUser = true
                
                account.addCouponForUser(couponId: coupon.id, userId: (self.coupon.addedBy as NSString).integerValue)
                
                break
            case .addCouponForUser:
                
                if isAddingForUser {
                    
                    let main = UIStoryboard(name: "Main", bundle: nil)
                    let vc = main.instantiateInitialViewController()
                    
                    let window = UIApplication.shared.keyWindow!
                    
                    window.rootViewController = vc
                    window.makeKeyAndVisible()
                }
                break
            default:
                break
            }
        } else {
            Toast.showAlert(viewController: self, text: status.message)
        }
    }
}


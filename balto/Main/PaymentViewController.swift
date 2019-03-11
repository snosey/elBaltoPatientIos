    //
//  PaymentViewController.swift
//  balto
//
//  Created by Abanoub Osama on 3/29/18.
//  Copyright © 2018 Abanoub Osama. All rights reserved.
//

extension UIView {
    
    @IBInspectable var cornerRadius: CGFloat {
        get {
            return layer.cornerRadius
        }
        set {
            layer.cornerRadius = newValue
            layer.masksToBounds = newValue > 0
        }
    }
   
    @IBInspectable var shadowSize: CGSize {
        set {
            self.layer.shadowOffset = shadowSize
            self.layer.shadowOpacity = 0.5
            self.layer.shadowRadius = 2.0
            self.layer.masksToBounds = false
        }
        get {
            return self.layer.shadowOffset
        }
    }
    
    @IBInspectable var borderWidth: CGFloat {
        get {
            return layer.borderWidth
        }
        set {
            layer.borderWidth = newValue
        }
    }
    
    @IBInspectable var borderColor: UIColor? {
        get {
            return UIColor(cgColor: layer.borderColor!)
        }
        set {
            layer.borderColor = newValue?.cgColor
        }
    }
}

import UIKit
import SwiftyJSON

    
class PaymentViewController: UIViewController, PaymentDelegate{
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        amountTF.placeholder = LocalizationSystem.sharedInstance.localizedStringForKey(key: "Amount", comment: "")
        
        identifier.placeholder = LocalizationSystem.sharedInstance.localizedStringForKey(key: "phoneNumber", comment: "")
        
        loadingView = LoadingView(frame: view.frame)
        loadingView.setLoadingImage(image: UIImage(named: "loading")!)
        loadingView.backgroundColor = UIColor.white.withAlphaComponent(0.8)
        loadingView.isHidden = true
        self.view.addSubview(loadingView)
        
        payment = PaymentSession(delegate: self)
        
        if let _ = PaymentSession.getSavedWith(key: "savedToken") {
            
            let maskedPan = PaymentSession.getSavedWith(key: "masked_pan")
            _ = PaymentSession.getSavedWith(key: "card_subtype")
            
            buttonMaskedPan.setTitle(maskedPan ?? "Unknown saved card", for: .normal)
            buttonMaskedPan.imageView?.contentMode = .scaleAspectFit
            buttonMaskedPan.setImage(maskedPan == nil ? nil : UIImage(named: "credit_blue_small"), for: .normal)
        }

        loadingView = LoadingView(frame: view.frame)
        loadingView.setLoadingImage(image: UIImage(named: "loading")!)
        loadingView.backgroundColor = UIColor.white.withAlphaComponent(0.8)
        loadingView.isHidden = true
        self.view.addSubview(loadingView)
     
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        self.navigationController?.navigationBar.topItem?.title = LocalizationSystem.sharedInstance.localizedStringForKey(key: "wallet", comment: "")
        buttonMaskedPan.borderWidth = 2
        buttonMaskedPan.borderColor = UIColor(red: 0x2F / 255, green: 0x9C / 255, blue: 0xAB / 255, alpha: 1)
        buttonMaskedPan.cornerRadius = 16
        buttonMaskedPan.titleEdgeInsets = UIEdgeInsets(top: 12, left: 2, bottom: 12, right: 8)
        buttonMaskedPan.imageEdgeInsets = UIEdgeInsets(top: 4, left: 4, bottom: 4, right: 8)

    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.navigationBar.topItem?.title = ""
    }
    
    /*
     | MARK:- IBOutlets
     |==========================================
     | 1- buttonMaskedPan
     | 2- amountTextField
     | 3- identifier >> (wallet)
     | 4- amanPayment
     | 5- walletPayment
     | 6- onlinePayment
     | 7- ourPickerView
     | 8- walletTextField
     */
    @IBOutlet weak var buttonMaskedPan: UIButton!
    @IBOutlet weak var amountTF: UITextField!
    @IBOutlet weak var identifier: UITextField!
    @IBOutlet weak var amanButton: UIButton!
    @IBOutlet weak var walletButton: UIButton!
    @IBOutlet weak var onlineButton: UIButton!
    @IBOutlet weak var walletTextField: UILabel!
    
    /*
     | MARK:- variables
     |==========================================
     | 1- loadingView
     | 2- payment
     | 3- paymentWay
     | 4- amanNumber
     | 5- pickerViewTitles
     */
    private var loadingView: LoadingView!
    private var payment: PaymentSession!
    private var paymentWay: String = "wallet"
    private var amanNumber: Int = 0
    
    /*
     | MARK:- IBActions
     |==========================================
     | 1- addOrEditCreditCard
     | 2- addToWallet
     | 3- walletPaymentClicked
     | 3- amanPaymentClicked
     | 3- onlinePaymentClicked
     */
    
    @IBAction func addOrEditCreditCard(_ sender: UIButton) {
        loadingView.setIsLoading(true)
        payment.addCard(vc: self)
    }
    @IBAction func addToWallet(_ sender: UIButton) {
        
        guard let amount = amountTF.text, !amount.isEmpty else {
            Toast.showAlert(viewController: self, text: "Please add amount")
            return
        }
        
        if paymentWay == "wallet" {
            guard let identifierText = identifier.text, !identifierText.isEmpty, identifierText.prefix(2) == "01" else {
                Toast.showAlert(viewController: self, text: "Please add phone number")
                return
            }
            if identifierText.prefix(2) != "01" {
                Toast.showAlert(viewController: self, text: "Please add correct phone number")
                return
            }
        }
        
        loadingView.setIsLoading(true)
        let patientId = SettingsManager().getUserId()
        
        if paymentWay == "aman" {
            self.amanPaymentRequest(patientId: patientId, amount: amount)
        } else if paymentWay == "online" {
            self.onlinePaymentRequest(patientId: patientId, amount: amount, state: "online")
        } else if paymentWay == "wallet" {
            self.walletPaymentRequest(doctorId: patientId, amount: amount, phone: identifier.text!)
        }
    }
    @IBAction func walletPaymentClicked(_ sender: UIButton) {
        radioButtonsCheck(button: sender)
    }
    
    @IBAction func amanPaymentClicked(_ sender: UIButton) {
        radioButtonsCheck(button: sender)
    }
    
    @IBAction func onlinePaymentClicked(_ sender: UIButton) {
        radioButtonsCheck(button: sender)
    }
    
    
    /*
     | MARK:- functions
     |==========================================
     | 1- onPostExecute
     | 2- radioButtonsCheck
     | 3- amanPaymentRequest
     | 4- walletPaymentRequest
     | 5- onlinePaymentRequest
     | 6- prepare
     */
    
    func onPostExecute(status: BaseUrlSession.Status, action: PaymentSession.ActionType, response: Any!) {
        loadingView.setIsLoading(false)
        if status.success {
            
            if let _ = PaymentSession.getSavedWith(key: "savedToken") {
                
                let maskedPan = PaymentSession.getSavedWith(key: "masked_pan")
                _ = PaymentSession.getSavedWith(key: "card_subtype")
                
                buttonMaskedPan.setTitle(maskedPan ?? "Unknown saved card", for: .normal)
                buttonMaskedPan.imageView?.contentMode = .scaleAspectFit
                buttonMaskedPan.setImage(maskedPan == nil ? nil : UIImage(named: "credit_blue_small"), for: .normal)
            }
            
            Toast.showAlert(viewController: self, text: "Successfully saved")
        } else {
            Toast.showAlert(viewController: self, text: status.message)
        }
    }
    
    func radioButtonsCheck(button: UIButton) {
        if button == amanButton {
            paymentWay = "aman"
            identifier.isHidden = true
            walletTextField.isHidden = true
        }else if button == onlineButton {
            paymentWay = "online"
            identifier.isHidden = true
            walletTextField.isHidden = true
        }else if button == walletButton {
            paymentWay = "wallet"
            identifier.isHidden = false
            walletTextField.isHidden = false
        }
        amanButton.setImage(UIImage(named: "emptyCircle"), for: .normal)
        onlineButton.setImage(UIImage(named: "emptyCircle"), for: .normal)
        walletButton.setImage(UIImage(named: "emptyCircle"), for: .normal)
        button.setImage(UIImage(named: "fillCircle"), for: .normal)
    }
    
    func amanPaymentRequest(patientId: Int, amount: String) {
        DoctorsAPIS.amanPayment(user_id: patientId, amount: amount) { (success, failure) in
            if failure != nil {
                self.loadingView.setIsLoading(false)
                print("operation Failed")
            }else {
                if success != nil {
                    self.loadingView.setIsLoading(false)
                    let json = JSON(success!)
                    if json["status"] == "1" {
                        if let newInt = json["data"].int {
                            self.amanNumber = newInt
                            self.performSegue(withIdentifier: "goToAmanMessage", sender: self)
                        }
                    }
                }
            }
        }
    }

    func walletPaymentRequest(doctorId: Int, amount: String, phone: String) {
        DoctorsAPIS.walletPayment(user_id: doctorId, amount: amount, phone: phone) { (success, failure) in
            if failure != nil {
                self.loadingView.setIsLoading(false)
                print("operation Failed")
            }else {
                if success != nil {
                    self.loadingView.setIsLoading(false)
                    let json = JSON(success!)
                    if json["status"] == "1" {
                        if let url = URL(string: json["data"].string!) {
                            if #available(iOS 10.0, *) {
                                UIApplication.shared.open(url, options: [:])
                            } else {
                                
                            }
                        }
                    }
                }
            }
        }
    }
    
    func onlinePaymentRequest(patientId: Int, amount: String, state: String) {
        DoctorsAPIS.onlinePayment(user_id: patientId, amount: amount, state: state) { (success, failure) in
            if failure != nil {
                self.loadingView.setIsLoading(false)
                print("operation Failed")
            }else {
                if success != nil {
                    self.loadingView.setIsLoading(false)
                    let json = JSON(success!)
                    if json["status"] == "1" {
                        let first  = self.navigationController?.viewControllers.first
                        self.navigationController?.popToRootViewController(animated: false)
                        
                        if let main = first as? MainViewController {
                            let storyboard = UIStoryboard(name: "Main", bundle: nil)
                            let vc = storyboard.instantiateViewController(withIdentifier: "newTransaction")
                            main.replaceViewController(vc)
                        }
                    }
                }
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goToAmanMessage" {
            if let dest = segue.destination as? amanMessageController {
                dest.amanNumberSent = amanNumber
            }
        }
    }
}

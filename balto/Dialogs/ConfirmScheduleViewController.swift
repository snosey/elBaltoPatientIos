//
//  WarningViewController.swift
//  Tabeeb
//
//  Created by Abanoub Osama on 8/15/17.
//  Copyright © 2017 Abanoub Osama. All rights reserved.
//

import UIKit
import SwiftyJSON

class ConfirmScheduleViewController: UIViewController, ContentDelegate, PaymentDelegate {
    
    @IBOutlet weak var scrollview: UIScrollView!
    
    @IBOutlet weak var labelPrice: UILabel!
    @IBOutlet weak var labelTime: UILabel!
    
    @IBOutlet weak var labelPaymentMethod: UIButton!
    @IBOutlet weak var walletCheckedButton: UIButton!
    
    @IBOutlet weak var labelCreditPan: UILabel!
    
    @IBOutlet weak var textfieldPromotion: UITextField!
    
    @IBOutlet weak var labelSpecialization: UILabel!
    
    @IBOutlet weak var viewBack: UIView!
    
    @IBOutlet weak var loadingView: LoadingView!
    
    
    private var content: ContentSession!
    fileprivate var walletAddedSuccessfully: Bool = false
    private var payment: PaymentSession!
    
    private var schedule: Schedule!
    private var doctor: Doctor!
    private var payMobId: Int!
    private var coupon: Coupon!
    fileprivate var moneyInWallet: Double = 0.0
    var mainViewController: MainViewController!
    
    private var postAction: ((_ isSuccess: Bool) -> Bool)!
    
    private var isSubmit = true
    // 0 >> credit |||||| 1 >> wallet
    fileprivate var selectedPaymentWay: Int = 0
    
    
    init(doctor: Doctor, schedule: Schedule, postAction: ((_ isSuccess: Bool) -> Bool)!) {
        super.init(nibName: "ConfirmScheduleViewController", bundle: nil)
        self.modalPresentationStyle = UIModalPresentationStyle.overCurrentContext
        self.schedule = schedule
        self.doctor = doctor
        self.postAction = postAction
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadingView.setLoadingImage(image: UIImage(named: "loading")!)
        loadingView.backgroundColor = UIColor.white.withAlphaComponent(0.8)
        loadingView.isHidden = true
        
        content = ContentSession(delegate: self)
        payment = PaymentSession(delegate: self)
        
        labelPrice.text = "\(doctor.price ?? "-") EGP"
        labelTime.text = "\(schedule.from ?? "") - \(schedule.to ?? "")"
        
        self.checkIfCardAssigned()
        labelSpecialization.text = doctor.specialization.name
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismiss(_:)))
        tap.cancelsTouchesInView = true
        view.addGestureRecognizer(tap)
        
        let tap2: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: nil)
        tap2.cancelsTouchesInView = true
        viewBack.addGestureRecognizer(tap2)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name:NSNotification.Name.UIKeyboardWillShow, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name:NSNotification.Name.UIKeyboardWillHide, object: nil)
        let tap3: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.DismissKeyboardNow))
        self.view.addGestureRecognizer(tap3)
        
        self.getUserAmount()
        
    }
    
    @objc func DismissKeyboardNow() {
        OperationQueue.main.addOperation {
            self.view.endEditing(true)
        }
    }
    
    @objc func keyboardWillShow(notification:NSNotification) {
        //give room at the bottom of the scroll view, so it doesn't cover up anything the user needs to tap
        var userInfo = notification.userInfo!
        var keyboardFrame:CGRect = (userInfo[UIKeyboardFrameBeginUserInfoKey] as! NSValue).cgRectValue
        keyboardFrame = self.view.convert(keyboardFrame, from: nil)
        
        var contentInset:UIEdgeInsets = self.scrollview.contentInset
        contentInset.bottom = keyboardFrame.size.height
        self.scrollview.contentInset = contentInset
    }
    
    @objc func keyboardWillHide(notification:NSNotification) {
        let contentInset:UIEdgeInsets = UIEdgeInsets.zero
        self.scrollview.contentInset = contentInset
    }
    
    
    @IBAction func confirm(_ sender: Any) {
        self.view.endEditing(true)
        submit()
    }
    
    @IBAction func cancel(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func submit()  {
        
        let price = (doctor.price as NSString).integerValue
        
        if textfieldPromotion.text!.isEmpty { // first case
            
            self.coupon = nil
            
            if selectedPaymentWay == 1 {
                // wallet selected
                let userId = SettingsManager().getUserId()
                let params = [
                    "user" : userId,
                    "amount": price,
                    "way": 4,
                    "state": 4,
                ] as [String : Any]
                
                sendWalletRequest(amount: Double(price) ,params: params)
                
            } else if let token = PaymentSession.getSavedWith(key: "savedToken"), !token.isEmpty {
                
                let userId = SettingsManager().getUserId()
                content.addBooking(doctor: doctor, userId: userId, schedule: schedule, scheduleKind: 2, paymentMethod: 2, coupon: nil)

            } else {
                
                payment.addCard(vc: self)
            }
        } else if let _ = coupon { // second case

            if selectedPaymentWay == 1 {
                let userId = SettingsManager().getUserId()
                let params = [
                    "user" : userId,
                    "amount": price,
                    "way": 4,
                    "state": 4,
                    ] as [String : Any]
                sendWalletRequest(amount: Double(price) ,params: params)
                
            } else if let token = PaymentSession.getSavedWith(key: "savedToken"), !token.isEmpty {
                let userId = SettingsManager().getUserId()
                content.addBooking(doctor: doctor, userId: userId, schedule: schedule, scheduleKind: 2, paymentMethod: 2, coupon: nil)
            } else {
                payment.addCard(vc: self)
            }
        } else {
            isSubmit = true
            content.checkCopoun(code: textfieldPromotion.text!)
        }
    }
    
    @IBAction func confirmPromotion(_ sender: UIButton) {
        
        if !textfieldPromotion.text!.isEmpty {
            isSubmit = false
            content.checkCopoun(code: textfieldPromotion.text!)
        }
    }
    
    @objc func dismiss(_ ite: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func onPreExecute(action: ContentSession.ActionType) {
        loadingView.setIsLoading(true)
    }
    
    func onPostExecute(status: BaseUrlSession.Status, action: ContentSession.ActionType, response: Any!) {
        if status.success {
            switch action {
            case .checkCoupon:
                
                coupon = response as! Coupon
                
                let price = Float((doctor.price as NSString).integerValue)
                
                var newPrice = price - price * coupon.discount
                newPrice.round(.up)
                
                labelPrice.text = "\(Int(newPrice)) - EGP"
                
                if isSubmit {
                    
                    submit()
                } else {
                    
                    loadingView.setIsLoading(false)
                }
                break
            case .addBooking:
                loadingView.setIsLoading(false)
                
                let reservation = response as! Reservation
                
                content.updateBooking(with: reservation.id, toState: 2, doctorId: doctor.id)
                
                content.sendNotification(bookingId: reservation.id, fcmToken: doctor.fcmToken, kind: NotificationHandler.Kind.bookingRequestOnline, title: "", message: "")
                break
            case .addPayment:
                break
            default:
                loadingView.setIsLoading(false)
                
                if let postAction = postAction, postAction(true) {
                } else {
                    dismiss(animated: true, completion: nil)
                }
                break
            }
        } else {
            
            loadingView.setIsLoading(false)
            
            Toast.showAlert(viewController: self, text: status.message)
        }
    }
    
    func onPostExecute(status: BaseUrlSession.Status, action: PaymentSession.ActionType, response: Any!) {
        loadingView.setIsLoading(false)
        if status.success {
            
            switch action {
            case .payNowByToken:
                
                self.payMobId = response as! Int
                
                let userId = SettingsManager().getUserId()
                
                content.addBooking(doctor: doctor, userId: userId, schedule: schedule, scheduleKind: 2, paymentMethod: 2, coupon: nil)
                break
            case .payNowByCard:
                
                self.payMobId = response as! Int
                
                let userId = SettingsManager().getUserId()
                
                content.addBooking(doctor: doctor, userId: userId, schedule: schedule, scheduleKind: 2, paymentMethod: 2, coupon: nil)
                break
            default:
                break
            }
        } else {
            
            Toast.showAlert(viewController: self, text: status.message)
        }
    }
    
    @IBAction func walletChecked(_ sender: UIButton){
        sender.setImage(#imageLiteral(resourceName: "fillCircle"), for: .normal)
        labelPaymentMethod.setImage(#imageLiteral(resourceName: "emptyCircle"), for: .normal)
        self.selectedPaymentWay = 1 // checked
        self.labelCreditPan.text = "\(self.moneyInWallet)"
    }
    
    @IBAction func creditChecked(_ sender: UIButton){
        sender.setImage(#imageLiteral(resourceName: "fillCircle"), for: .normal)
        walletCheckedButton.setImage(#imageLiteral(resourceName: "emptyCircle"), for: .normal)
        self.selectedPaymentWay = 0 // checked
        checkIfCardAssigned()
        
    }
    
    func getUserAmount() {
        let lang = LocalizationSystem.sharedInstance.getLanguage()
        let userId = SettingsManager().getUserId()
        DoctorsAPIS.getDoctorPayments(lang: lang, doctorId: userId) { (success, error) in
            if error != nil {
                self.loadingView.setIsLoading(false)
            }else {
                let json = JSON(success!)
                if json["status"].string == "1" {
                    if let amount = json["total_amount"].double {
                        if self.selectedPaymentWay == 1 {
                            self.labelCreditPan.text = "\(amount)"
                        }
                        self.moneyInWallet = amount
                        self.loadingView.setIsLoading(false)
                    }
                } else {
                    self.loadingView.setIsLoading(false)
                }
            }
        }
    }
    
    func sendWalletRequest(amount: Double, params: [String: Any]) {
        
        if amount > moneyInWallet {
            Toast.showAlert(viewController: self, text: "you don't have enough Money")
            return
        }
        
        loadingView.setIsLoading(true)
        DoctorsAPIS.addUserTransaction(params: params) { (success, error) in
            if error != nil {
                // return status
                Toast.showAlert(viewController: self, text: "Error")
                self.loadingView.setIsLoading(false)
            }else {
                let json = JSON(success!)
                if json["status"].string == "1" {
                    
                    if let wallet_id = json["data"]["id"].int {
                        
                        let userId = SettingsManager().getUserId()
                        self.content.addBooking(doctor: self.doctor, userId: userId, schedule: self.schedule, scheduleKind: 2, paymentMethod: 4, coupon: nil, wallet_id: wallet_id)
//                        self.dismiss(animated: true, completion: nil)
                        /*
                        self.loadingView.setIsLoading(false)
                        self.dismiss(animated: true, completion: nil)
                        NotificationCenter.default.post(name: Notification.Name("reloadReservation"), object: nil)
                        */
                        
                    }else {
                        Toast.showAlert(viewController: self, text: "Mission Failed")
                        self.loadingView.setIsLoading(false)
                    }
                }else {
                    Toast.showAlert(viewController: self, text: "Mission Failed")
                    self.loadingView.setIsLoading(false)
                }
                
            }
        }
         
    }
    
    func checkIfCardAssigned() {
        if let token = PaymentSession.getSavedWith(key: "savedToken"), !token.isEmpty {
            
            let maskedPan = PaymentSession.getSavedWith(key: "masked_pan")
            let _ = PaymentSession.getSavedWith(key: "card_subtype")
            
            labelCreditPan.text = maskedPan ?? "****-****-****-****"
        } else {
            labelCreditPan.text = LocalizationSystem.sharedInstance.localizedStringForKey(key: "no_saved_cards", comment: "")
        }
    }
    
}

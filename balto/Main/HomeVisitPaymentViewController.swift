//
//  HomeVisitPaymentViewController.swift
//  balto
//
//  Created by Abanoub Osama on 4/30/18.
//  Copyright © 2018 Abanoub Osama. All rights reserved.
//

import UIKit
import CoreLocation

class HomeVisitPaymentViewController: UIViewController, RadioGroupDelegate, AccountDelegate {
    
    @IBOutlet weak var imageViewPic: UIImageView!
    
    @IBOutlet weak var labelProfession: UILabel!
    @IBOutlet weak var labelSpecialization: UILabel!
    @IBOutlet weak var labelMotto: UILabel!
    
    @IBOutlet weak var labelBaseFare: UILabel!
    
    @IBOutlet weak var sliderServiceDuration: UISlider!
    
    @IBOutlet weak var labelServiceDuration: UILabel!
    
    @IBOutlet weak var radioGroupPaymentMethod: RadioGroup!
    
    @IBOutlet weak var radioGroupGender: RadioGroup!
    
    @IBOutlet weak var textfieldCode: UITextField!
    
    private var loadingView: LoadingView!
    
    private var account: AccountSession!
    
    var profession: MainCategory!
    var specialization: SubCategory!
    var serviceLocation: CLLocationCoordinate2D!
    var coupon: Coupon!
    
    private var genderId: Int!
    private var serviceDuration: Int!
    private var paymentMethod: Int!
    
    var isSubmit: Bool!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        account = AccountSession(delegate: self)
        
        loadingView = LoadingView(frame: view.frame)
        loadingView.setLoadingImage(image: UIImage(named: "loading")!)
        loadingView.backgroundColor = UIColor.white.withAlphaComponent(0.8)
        loadingView.isHidden = true
        self.view.addSubview(loadingView)
        
        imageViewPic.sd_setImage(with: URL(string: specialization.logo)) { (image, error, cacheType, url) in
            if let _ = error {
                
                self.imageViewPic.image = UIImage(named: "profile")
            }
        }
        
        labelProfession.text = specialization.name
        labelSpecialization.text = ""
        labelMotto.numberOfLines = 0
        labelMotto.text = specialization.description
        
        labelBaseFare.text = "\(specialization.baseFare ?? 0)"
        
        radioGroupPaymentMethod.delegate = self
        radioGroupPaymentMethod.radioButtonSelector = { deselectedView, selectedView in
            
            if let view = selectedView, let button = view as? UIButton {
                
                button.setImage(UIImage(named: "20_select_black"), for: .normal)
            }
            
            if let view = deselectedView, let button = view as? UIButton {
                
                button.setImage(UIImage(named: "20_deselect_black"), for: .normal)
            }
        }
        
        radioGroupGender.delegate = self
        radioGroupGender.radioButtonSelector = { deselectedView, selectedView in
            
            if let view = selectedView, let button = view as? UIButton {
                
                button.setImage(UIImage(named: "20_select_red"), for: .normal)
            }
            
            if let view = deselectedView, let button = view as? UIButton {
                
                button.setImage(UIImage(named: "20_deselect_red"), for: .normal)
            }
        }
        
        if let maxHours = specialization.maxHours {
        
            sliderServiceDuration.maximumValue = Float(maxHours)
        }
        
        if let minHours = specialization.minHours, minHours > 0 {
            
            sliderServiceDuration.minimumValue = Float(minHours)
        } else {
            
            labelServiceDuration.superview?.isHidden = true
        }
        
        sliderValueChanged(sliderServiceDuration)
        
        genderId = 3
        paymentMethod = 2
    }
    
    func didSelectButton(_ radioGroup: RadioGroup, _ selectedView: UIView, _ index: Int) {
        
        if radioGroup == radioGroupPaymentMethod {
            
            paymentMethod = index + 1
        } else /*if radioGroup == radioGroupGender*/ {
            
            genderId = index + 1
        }
    }
    
    @IBAction func sliderValueChanged(_ sender: UISlider) {
        
        let value = Int(sender.value * 60)
        let mins = value % 60
        let hours = value / 60
        
        labelServiceDuration.text = String(format: "%02d:00", hours, mins)
        
        serviceDuration = value
    }
    
    @IBAction func confirmCode(_ sender: UIButton) {
        
        if !textfieldCode.text!.isEmpty {
            isSubmit = false
            account.checkCopoun(code: textfieldCode.text!)
        }
    }
    
    @IBAction func submit(_ sender: UIButton) {
        
        if textfieldCode.text!.isEmpty || coupon != nil {
            
            if textfieldCode.text!.isEmpty {
                
                self.coupon = nil
            }
        
            guard let _ = serviceDuration else {
                
                Toast.showAlert(viewController: self, text: "Please select a valid service duration")
                return
            }
            
            guard let _ = paymentMethod else {
                
                Toast.showAlert(viewController: self, text: "Please select payment method")
                return
            }
            
            guard let _ = genderId else {
                
                Toast.showAlert(viewController: self, text: "Please select gender")
                return
            }
            
            let vc = self.storyboard!.instantiateViewController(withIdentifier: "HomeVisitViewController") as! HomeVisitViewController
            
            vc.homeVisitStep = .summary
            vc.profession = profession
            
            vc.specialization = specialization
            vc.serviceLocation = serviceLocation
            
            vc.genderId = genderId
            vc.paymentMethod = paymentMethod
            
            if let minHours = specialization.minHours, minHours > 0 {
                
                vc.serviceDuration = serviceDuration
            } else {
                
                vc.serviceDuration = 0
            }
            
            if let coupon = coupon {
                
                vc.coupon = coupon
            }
            
            self.show(vc, sender: self)
        } else {
            
            isSubmit = true
            account.checkCopoun(code: textfieldCode.text!)
        }
    }
    
    func onPreExecute(action: AccountSession.ActionType) {
        loadingView.setIsLoading(true)
    }
    
    func onPostExecute(status: BaseUrlSession.Status, action: AccountSession.ActionType, response: Any!) {
        loadingView.setIsLoading(false)
        if status.success {
            switch action {
            case .checkCoupon:
                coupon = response as! Coupon
                
                if isSubmit {
                    
                    submit(UIButton())
                } else {
                
                    Toast.showAlert(viewController: self, text: "Coupon code is valid")
                }
                break
            default:
                break
            }
        } else {
            
            Toast.showAlert(viewController: self, text: "Coupon code is invalid")
        }
    }
}

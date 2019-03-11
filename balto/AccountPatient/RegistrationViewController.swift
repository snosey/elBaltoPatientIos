//
//  RegistrationViewController.swift
//  kora
//
//  Created by Abanoub Osama on 3/9/18.
//  Copyright © 2018 Abanoub Osama. All rights reserved.
//

import UIKit
import FirebaseAuth
import CountryList

class RegistrationViewController: UIViewController, AccountDelegate, PickerDelegate ,CountryListDelegate{
    
    enum RegistrationSteps: Int {
        case Name, Gender, Email, Password, Number
    }
    
    let LANGUAGE_PICKER_TAG = 1
    let GENDER_PICKER_TAG = 2
    
    @IBOutlet weak var stackView: UIStackView!
    
    @IBOutlet weak var textFieldFirstName: UITextField!
    @IBOutlet weak var textFieldLastName: UITextField!
    
    @IBOutlet weak var buttonLanguage: UIButton!
    
    @IBOutlet weak var buttonGender: UIButton!
    
    @IBOutlet weak var textFieldEmail: UITextField!
    
    @IBOutlet weak var textFieldPassword: UITextField!
    @IBOutlet weak var textFieldConfPassword: UITextField!
    
    @IBOutlet weak var textFieldPhone: UITextField!
    @IBOutlet weak var textFieldCountryCode: UITextField!
    
    var account: AccountSession!
    var loadingView: LoadingView!
    
    var registrationStep = RegistrationSteps.Name
    
    var genders = [BaseModel]()
    
    var languages = [BaseModel]()
    
    var states = [BaseModel]()
    
    var language: BaseModel!
    
    var gender: BaseModel!
    
    var socialUser: SocialViewController.SocialUser!
    
    var countryList = CountryList()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        account = AccountSession(delegate: self)
        
        loadingView = LoadingView(frame: view.frame)
        loadingView.setLoadingImage(image: UIImage(named: "loading")!)
        loadingView.backgroundColor = UIColor.white.withAlphaComponent(0.8)
        loadingView.isHidden = true
        self.view.addSubview(loadingView)
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissMyKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
        countryList.delegate = self
        textFieldCountryCode.addTarget(self, action: #selector(self.viewPicker), for: .editingDidBegin)
        textFieldCountryCode.inputView = UIView()
        account.getRegistrationData(language: Constants.language)
        
        textFieldCountryCode.text = "20"
        
        if let user = socialUser {
            
            textFieldFirstName.text = user.fname
            textFieldFirstName.isUserInteractionEnabled = false
                
            textFieldLastName.text = user.lname
            textFieldLastName.isUserInteractionEnabled =  user.lname.isEmpty
            
            if let email = user.email {
                
                textFieldEmail.text = email
                textFieldEmail.isUserInteractionEnabled = false
            }
        }
    }
    
    @objc func viewPicker()  {
        let navController = UINavigationController(rootViewController: countryList)
        self.present(navController, animated: true, completion: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.isHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.navigationBar.isHidden = false
        
        let backItem = UIBarButtonItem()
        backItem.title = ""
        self.navigationItem.backBarButtonItem = backItem
    }
    
    @IBAction func next(_ sender: UIButton) {
        
        switch registrationStep {
        case .Name:
            checkNameAndNext()
            break
//        case .Language:
//            checkLanguageAndNext()
//            break
        case .Gender:
            checkGenderAndNext()
            break
        case .Email:
            checkEmailAndNext()
            break
        case .Password:
            checkPasswordAndNext()
            break
        case .Number:
            checkPhoneAndNext()
            break
        }
    }
    
    @IBAction func previous(_ sender: UIButton) {
        if registrationStep.rawValue == RegistrationSteps.Name.rawValue {
            
            self.navigationController?.popViewController(animated: true)
        } else {
            
            showPrevious()
        }
    }
    
    func checkNameAndNext() {
        
        let firstName = textFieldFirstName.text!
        if firstName.isEmpty {
            
            Toast.showAlert(viewController: self, text: LocalizationSystem.sharedInstance.localizedStringForKey(key: "first_name_empty", comment: ""))
            return
        }
        
        let lastName = textFieldLastName.text!
        if lastName.isEmpty {
            
            Toast.showAlert(viewController: self, text: LocalizationSystem.sharedInstance.localizedStringForKey(key: "last_name_empty", comment: ""))
            return
        }
        
        showNext()
        
        dismissMyKeyboard()
    }
    
    func checkLanguageAndNext() {
        
//        if language == nil {
//            
//            Toast.showAlert(viewController: self, text: "Please select language first")
//            return
//        }
        
        showNext()
    }
    
    func checkGenderAndNext() {
        
        if gender == nil {
            
            Toast.showAlert(viewController: self, text: "Please select gender first")
            return
        }
        
        showNext()
    }
    
    func checkEmailAndNext() {
        
        let email = textFieldEmail.text!
        if email.isEmpty {
            
            Toast.showAlert(viewController: self, text: LocalizationSystem.sharedInstance.localizedStringForKey(key: "mail_empty", comment: ""))
            return
        } else if email.range(of:  "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}", options: .regularExpression, range: nil, locale: nil) == nil {
            
            Toast.showAlert(viewController: self, text: LocalizationSystem.sharedInstance.localizedStringForKey(key: "enter_valid_email", comment: ""))
            return
        }
        
        account.checkEmail(email: email)
    }
    
    func checkPasswordAndNext() {
        
        let password = textFieldPassword.text!
        let confPassword = textFieldConfPassword.text!
        if password.count < 8 {
            
            Toast.showAlert(viewController: self, text: LocalizationSystem.sharedInstance.localizedStringForKey(key: "shortPassword", comment: ""))
            return
        } else if password.count > 16 {
            
            Toast.showAlert(viewController: self, text: LocalizationSystem.sharedInstance.localizedStringForKey(key: "shortPassword", comment: ""))
            return
        } else if password.compare(confPassword) != .orderedSame {
            
            Toast.showAlert(viewController: self, text: LocalizationSystem.sharedInstance.localizedStringForKey(key: "passwords_not_matching", comment: ""))
            return
        }
        
        showNext()
        
        dismissMyKeyboard()
    }
    
    func checkPhoneAndNext() {
        
        var phone = textFieldPhone.text!
        if phone.starts(with: "0") {
            phone.removeFirst()
        }
        if phone.isEmpty {
            
            Toast.showAlert(viewController: self, text: LocalizationSystem.sharedInstance.localizedStringForKey(key: "phone_empty", comment: ""))
            return
        } else if phone.range(of:  "^[\\d]{10}$", options: .regularExpression, range: nil, locale: nil) == nil {
            
            Toast.showAlert(viewController: self, text: LocalizationSystem.sharedInstance.localizedStringForKey(key: "phone_invalid", comment: ""))
            return
        }else if textFieldCountryCode.text!.isEmpty {
            Toast.showAlert(viewController: self, text: LocalizationSystem.sharedInstance.localizedStringForKey(key: "phone_invalid", comment: ""))
            return
        }
            
        loadingView.setIsLoading(true)
        PhoneAuthProvider.provider().verifyPhoneNumber("+\(textFieldCountryCode.text!)\(phone)", uiDelegate: nil) { (verificationID, error) in
            self.loadingView.setIsLoading(false)
            if let er = error as NSError? {
                Toast.showAlert(viewController: self, text: er.localizedDescription)
            } else {
                
                UserDefaults.standard.set(verificationID, forKey: "authVerificationID")
                
                self.showNext()
                
                self.dismissMyKeyboard()
            }
        }
    }
    func selectedCountry(country: Country) {
        textFieldCountryCode.text = country.phoneExtension
    }
    
    func showNext() {
        
        if registrationStep.rawValue < RegistrationSteps.Number.rawValue {
            
            stackView.arrangedSubviews[registrationStep.rawValue].isHidden = true
            
            registrationStep = RegistrationSteps.init(rawValue: registrationStep.rawValue + 1)!
            
            stackView.arrangedSubviews[registrationStep.rawValue].isHidden = false
        } else {
            
            register()
        }
    }
    
    func showPrevious() {
        
        if registrationStep.rawValue > RegistrationSteps.Name.rawValue {
            
            stackView.arrangedSubviews[registrationStep.rawValue].isHidden = true
            
            registrationStep = RegistrationSteps.init(rawValue: registrationStep.rawValue - 1)!
            
            stackView.arrangedSubviews[registrationStep.rawValue].isHidden = false
        }
    }
    
    @IBAction func pickLanguage(_ sender: UIButton) {
        
        var names = [String]()
        for item in languages {
            
            names.append(item.name)
        }
        
        let picker = PickerViewController.present(self, delegate: self, items: names)
        picker.pickerView.tag = LANGUAGE_PICKER_TAG
    }
    
    @IBAction func pickGender(_ sender: UIButton) {
        
        var names = [String]()
        for item in genders {
            
            names.append(item.name)
        }
        let picker = PickerViewController.present(self, delegate: self, items: names)
        picker.pickerView.tag = GENDER_PICKER_TAG
    }
    
    func register() {
        
        let firstName = textFieldFirstName.text!
        let lastName = textFieldLastName.text!
        
        let email = textFieldEmail.text!
        
        var phone = textFieldPhone.text!
        if phone.starts(with: "0") {
            phone.removeFirst()
        }
        
        let password = textFieldPassword.text!
        
        let user = User()
        
        user.firstName = firstName
        user.lastName = lastName
        
        user.email = email
        
        user.phone = "+\(textFieldCountryCode.text!)\(phone)"
        
        user.language = language
        
        user.gender = gender
        
        let vc = storyboard?.instantiateViewController(withIdentifier: "ConfirmationViewController") as! ConfirmationViewController
        vc.user = user
        vc.password = password
        vc.socialUser = socialUser
        
        self.show(vc, sender: nil)
    }
    
    func done(picker: PickerViewController) -> Bool {
        switch picker.pickerView.tag {
        case LANGUAGE_PICKER_TAG:
            language = languages[picker.pickerView.selectedRow(inComponent: 0)]
            buttonLanguage.setTitle(language.name, for: .normal)
            break
        case GENDER_PICKER_TAG:
            gender = genders[picker.pickerView.selectedRow(inComponent: 0)]
            buttonGender.setTitle(gender.name, for: .normal)
            break
        default:
            break
        }
        return false
    }
    
    func cancel(picker: PickerViewController) -> Bool {
        return false
    }
    
    func onPreExecute(action: AccountSession.ActionType) {
        loadingView.setIsLoading(true)
    }
    
    func onPostExecute(status: BaseUrlSession.Status, action: AccountSession.ActionType, response: Any!) {
        loadingView.setIsLoading(false)
        if status.success {
            
            switch action {
            case .getGender:
                
                self.genders = response as! [BaseModel]
                
                if let user = socialUser, let gender = user.gender {
                    
                    if gender.elementsEqual("male") {
                        
                        self.gender = genders.first(where: { (gender) -> Bool in
                            gender.id == 1
                        })
                    } else {
                        
                        self.gender = genders.first(where: { (gender) -> Bool in
                            gender.id == 2
                        })
                    }
                    
                    if let gender = self.gender {
                        
                        buttonGender.setTitle(gender.name, for: .normal)
                        buttonGender.isUserInteractionEnabled =  user.lname.isEmpty
                    }
                }
                break
            case .geState:
                
                self.states = response as! [BaseModel]
                break
            case .getLanguage:
                
                self.languages = response as! [BaseModel]
                break
            case .checkEmail:
                
                let isValid = response as! Bool
                
                if isValid {
                    showNext()
                    
                    dismissMyKeyboard()
                } else {
                    
                    Toast.showAlert(viewController: self, text: LocalizationSystem.sharedInstance.localizedStringForKey(key: "enter_valid_email", comment: ""))
                }
                break
            default:
                break
            }
        } else {
            Toast.showAlert(viewController: self, text: status.message)
        }
    }
    
    @objc func dismissMyKeyboard() {
        view.endEditing(true)
    }
}

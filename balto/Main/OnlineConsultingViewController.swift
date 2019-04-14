//
//  BookAppointmentViewController.swift
//  balto
//
//  Created by Abanoub Osama on 4/2/18.
//  Copyright © 2018 Abanoub Osama. All rights reserved.
//

import UIKit
import SwiftyJSON

class OnlineConsultingViewController: UIViewController, ContentDelegate, PickerDelegate ,DatePickerDelegate {
    
    
    let PROFESSION_PICKER_TAG = 3
    let SPECIALIZATION_PICKER_TAG = 4
    var forChat: Bool = false
    let any = LocalizationSystem.sharedInstance.localizedStringForKey(key: "any", comment: "Any")
    @IBOutlet weak var buttonProfession: UIButton!
    
    @IBOutlet weak var buttonSpecialization: UIButton!
    
    @IBOutlet weak var textFieldName: UITextField!
    
    @IBOutlet weak var labelDate: UILabel!
    @IBOutlet weak var labelDateView: UIView!
    
    var content: ContentSession!
    var loadingView: LoadingView!
    
    var categories = [Category]()
    
    var category: Category!
    
    var subcategory: BaseModel!
    
    var date:Date!
    var myNames = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        textFieldName.attributedPlaceholder = NSAttributedString(string: LocalizationSystem.sharedInstance.localizedStringForKey(key: "doctorName", comment: ""), attributes: [NSAttributedStringKey.foregroundColor: UIColor.white])
        
        content = ContentSession(delegate: self)
        
        loadingView = LoadingView(frame: view.frame)
        loadingView.setLoadingImage(image: UIImage(named: "loading")!)
        loadingView.backgroundColor = UIColor.white.withAlphaComponent(0.8)
        loadingView.isHidden = true
        self.view.addSubview(loadingView)
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissMyKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
        
        let any = LocalizationSystem.sharedInstance.localizedStringForKey(key: "any", comment: "Any")
        buttonProfession.setTitle(any, for: .normal)
        
        content.getDoctorFilters()
        
        if self.forChat == true {
            self.labelDateView.isHidden = true
            self.title = "Chat"
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.navigationController?.navigationBar.topItem?.title = LocalizationSystem.sharedInstance.localizedStringForKey(key: "onlineMain", comment: "")
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
         self.navigationController?.navigationBar.topItem?.title = ""
    }
    
    @IBAction func chooseDate(_ sender: UIButton) {
        let vc = DatePickerController.present(self, delegate: self)
        vc.pickerView.minimumDate = Date()
        vc.pickerView.maximumDate = Date(timeIntervalSince1970: Date().timeIntervalSince1970 + 7 * DateUtils.DAY_INTERVAL)
    }
    
    @IBAction func next(_ sender: UIButton) {
        
        if let name = textFieldName.text, !name.isEmpty {
            if forChat == true {
                content.getDoctorsForChat(name: name, subId: category?.id ?? nil, languageId: nil, genderId: nil)
            }else {
                content.getDoctors(date: date, name: name, subId: category?.id ?? nil, languageId: nil, genderId: nil)
            }
        } else {
            if forChat == true {
                content.getDoctorsForChat(subId: category?.id ?? nil, languageId: nil, genderId: nil)
            }else {
                content.getDoctors(date: date, subId: category?.id ?? nil, languageId: nil, genderId: nil)
            }
        }
    }
    
    @IBAction func pickProfession(_ sender: UIButton) {
        
        var names = [String]()
        
        let any = LocalizationSystem.sharedInstance.localizedStringForKey(key: "any", comment: "Any")
        names.append(any)
        for item in categories {
            names.append(item.name)
        }
        let picker = PickerViewController.present(self, delegate: self, items: names)
        picker.pickerView.tag = PROFESSION_PICKER_TAG
    }
    
    @IBAction func pickSpecialization(_ sender: UIButton) {
        
        var names = [String]()
        
        names.append(any)
        
        if let subCategories = category?.subCategories {
            for item in subCategories {
                names.append(item.name)
            }
        }
        let picker = PickerViewController.present(self, delegate: self, items: names)
        picker.pickerView.tag = SPECIALIZATION_PICKER_TAG
    }
    
    func done(picker: PickerViewController) -> Bool {
        switch picker.pickerView.tag {
        case PROFESSION_PICKER_TAG:
            let index = picker.pickerView.selectedRow(inComponent: 0)
            if index == 0 {
                
                category = nil
                buttonProfession.setTitle(self.any,  for: .normal)
                
                subcategory = nil
                buttonSpecialization.setTitle("", for: .normal)
            } else {
                
                category = categories[index - 1]
                buttonProfession.setTitle(category.name, for: .normal)
                
                buttonSpecialization.setTitle(self.any,  for: .normal)
            }
            break
        case SPECIALIZATION_PICKER_TAG:
            let index = picker.pickerView.selectedRow(inComponent: 0)
            if index == 0 {
                
                subcategory = nil
                buttonSpecialization.setTitle(self.any,  for: .normal)
            } else {
                
                subcategory = category.subCategories[index - 1]
                buttonSpecialization.setTitle(subcategory.name, for: .normal)
                next(buttonProfession)
            }
            break
            
        default:
            break
        }
        return false
    }
    
    func cancel(picker: PickerViewController) -> Bool {
        return false
    }
    
    
    func done(picker: DatePickerController, date: Date) -> Bool {
        
        self.date = date
        labelDate.text = DateUtils.getAppDateString(timeInMillis: date.timeIntervalSince1970)
        
        return false
    }
    
    func cancel(picker: DatePickerController) -> Bool {
        
        date = nil
        labelDate.text = LocalizationSystem.sharedInstance.localizedStringForKey(key: "chooseDate", comment: "")
        return false
    }
    
    func onPreExecute(action: ContentSession.ActionType) {
        loadingView.setIsLoading(true)
    }
    
    func onPostExecute(status: BaseUrlSession.Status, action: ContentSession.ActionType, response: Any!) {
        loadingView.setIsLoading(false)
        if status.success {
            
            switch action {
            case .getDoctorSubCategories:
                
                self.categories = response as! [Category]
                break
            case .getDoctors:
                let doctors = response as! [Doctor]
                
                if doctors.isEmpty {
                    
                    Toast.showAlert(viewController: self, text: "No result")
                } else {
                    
                    let vc = storyboard?.instantiateViewController(withIdentifier: "SearchResultsViewController") as! SearchResultsViewController
                    vc.doctors = doctors
                    self.show(vc, sender: self)
                
                }
                break
            case .getDoctorsForChat:
                
                let doctors = response as! [Doctor]
                
                if doctors.isEmpty {
                    
                    Toast.showAlert(viewController: self, text: "No result")
                } else {
                    
                    let vc = storyboard?.instantiateViewController(withIdentifier: "SearchResultsForChatViewController") as! SearchResultsViewController
                    vc.doctors = doctors
                    vc.forChat = true
                    self.show(vc, sender: self)
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

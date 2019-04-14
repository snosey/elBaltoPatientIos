//
//  BookAppointmentViewController.swift
//  balto
//
//  Created by Abanoub Osama on 4/2/18.
//  Copyright © 2018 Abanoub Osama. All rights reserved.
//

import UIKit

class DoctorFilterViewController: UIViewController, ContentDelegate, PickerDelegate, DatePickerDelegate {
    
    let PROFESSION_PICKER_TAG = 3
    let SPECIALIZATION_PICKER_TAG = 4
    let GENDER_PICKER_TAG = 5
    let LANGUAGE_PICKER_TAG = 6
    let DATE_PICKER_TAG = 7
    let any = LocalizationSystem.sharedInstance.localizedStringForKey(key: "any", comment: "Any")
    @IBOutlet weak var buttonProfession: UIButton!
    @IBOutlet weak var buttonSpecialization: UIButton!
    @IBOutlet weak var buttonGender: UIButton!
    @IBOutlet weak var buttonLanguage: UIButton!
    @IBOutlet weak var labelDate: UILabel!
    @IBOutlet weak var textFieldName: UITextField!
    
    var content: ContentSession!
    var loadingView: LoadingView!
    
    var categories = [Category]()
    var genders = [BaseModel]()
    var languages = [BaseModel]()
    
    var category: Category!
    
    var subcategory: BaseModel!
    
    var gender: BaseModel!
    
    var language: BaseModel!
    
    var date: Date!
    
    var searchResultsViewController: SearchResultsViewController!
    
    class func getInstance(searchResultsViewController: SearchResultsViewController) -> DoctorFilterViewController {
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "DoctorFilterViewController") as! DoctorFilterViewController
        vc.searchResultsViewController = searchResultsViewController
        return vc
    }
    
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
        
        buttonProfession.setTitle(self.any, for: .normal)
        buttonSpecialization.setTitle(self.any, for: .normal)
        buttonGender.setTitle(self.any, for: .normal)
        buttonLanguage.setTitle(self.any, for: .normal)
        
        content.getDoctorFilters()
    }
    
    @IBAction func next(_ sender: UIButton) {
        
        if let name = textFieldName.text, !name.isEmpty {
            
            content.getDoctors(date: date, name: name, subId: category?.id, languageId: language?.id, genderId: gender?.id)
        } else {
            
            content.getDoctors(date: date, subId: category?.id, languageId: language?.id, genderId: gender?.id)
        }
    }
    
    @IBAction func pickProfession(_ sender: UIButton) {
        
        var names = [String]()
        names.append(self.any)
        for item in categories {
            
            names.append(item.name)
        }
        let picker = PickerViewController.present(self, delegate: self, items: names)
        picker.pickerView.tag = PROFESSION_PICKER_TAG
    }
    
    @IBAction func pickSpecialization(_ sender: UIButton) {
        
        var names = [String]()
        names.append(self.any)
        if let subCategories = category?.subCategories {
            
            for item in subCategories {
                
                names.append(item.name)
            }
        }
        let picker = PickerViewController.present(self, delegate: self, items: names)
        picker.pickerView.tag = SPECIALIZATION_PICKER_TAG
    }
    
    @IBAction func pickLanguage(_ sender: UIButton) {
        
        var names = [String]()
        names.append(self.any)
        
        for item in languages {
            
            names.append(item.name)
        }
        
        let picker = PickerViewController.present(self, delegate: self, items: names)
        picker.pickerView.tag = LANGUAGE_PICKER_TAG
    }
    
    @IBAction func pickGender(_ sender: UIButton) {
        
        var names = [String]()
        names.append(self.any)
        
        for item in genders {
            
            names.append(item.name)
        }
        
        let picker = PickerViewController.present(self, delegate: self, items: names)
        picker.pickerView.tag = GENDER_PICKER_TAG
    }
    
    @IBAction func pickDate(_ sender: UIButton) {
        
        let vc = DatePickerController.present(self, delegate: self)
        vc.pickerView.minimumDate = Date()
        vc.pickerView.maximumDate = Date(timeIntervalSince1970: Date().timeIntervalSince1970 + 7 * DateUtils.DAY_INTERVAL)
    }
    
    func done(picker: PickerViewController) -> Bool {
        switch picker.pickerView.tag {
        case PROFESSION_PICKER_TAG:
            let index = picker.pickerView.selectedRow(inComponent: 0)
            if index == 0 {
                
                category = nil
                buttonProfession.setTitle(self.any, for: .normal)
                
                subcategory = nil
                buttonSpecialization.setTitle(self.any, for: .normal)
            } else {
                
                category = categories[index - 1]
                buttonProfession.setTitle(category.name, for: .normal)
            }
            break
        case SPECIALIZATION_PICKER_TAG:
            let index = picker.pickerView.selectedRow(inComponent: 0)
            if index == 0 {
                
                subcategory = nil
                buttonSpecialization.setTitle(self.any, for: .normal)
            } else {
                
                subcategory = category.subCategories[index - 1]
                buttonSpecialization.setTitle(subcategory.name, for: .normal)
            }
            break
        case LANGUAGE_PICKER_TAG:
            let index = picker.pickerView.selectedRow(inComponent: 0)
            if index == 0 {
                
                language = nil
                buttonLanguage.setTitle(self.any, for: .normal)
            } else {
                
                language = languages[index - 1]
                buttonLanguage.setTitle(language.name, for: .normal)
            }
            break
        case GENDER_PICKER_TAG:
            let index = picker.pickerView.selectedRow(inComponent: 0)
            if index == 0 {
                
                gender = nil
                buttonGender.setTitle(self.any, for: .normal)
            } else {
                
                gender = genders[index - 1]
                buttonGender.setTitle(gender.name, for: .normal)
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
        labelDate.text = LocalizationSystem.sharedInstance.localizedStringForKey(key: "choose_date", comment: "")
        
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
            case .getDoctorGenders:
                
                self.genders = response as! [BaseModel]
                break
            case .getDoctorLanguages:
                
                self.languages = response as! [BaseModel]
                break
            case .getDoctors:
                let doctors = response as! [Doctor]
                
                if doctors.isEmpty {
                    
                    Toast.showAlert(viewController: self, text: "No result")
                } else {
                    
                    searchResultsViewController.doctors = doctors
                    searchResultsViewController.tableView.reloadData()
                    
                    if let nav = self.navigationController {
                        
                        nav.popViewController(animated: true)
                    } else {
                    
                        self.dismiss(animated: true, completion: nil)
                    }
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


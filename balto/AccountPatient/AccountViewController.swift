//
//  AccountViewController.swift
//  balto
//
//  Created by Abanoub Osama on 3/21/18.
//  Copyright © 2018 Abanoub Osama. All rights reserved.
//

import UIKit

class AccountViewController: UIViewController {

    @IBOutlet weak var buttonLanguage: UIButton!
    
    override func viewDidLoad() {
        if LocalizationSystem.sharedInstance.getLanguage() == "ar" {
            LocalizationSystem.sharedInstance.setLanguage(languageCode: "ar")
            UIView.appearance().semanticContentAttribute = .forceRightToLeft
        }else {
            LocalizationSystem.sharedInstance.setLanguage(languageCode: "en")
            UIView.appearance().semanticContentAttribute = .forceLeftToRight
        }
        
        super.viewDidLoad()
        print("I was in viewDidLoad")
        self.navigationController?.navigationBar.tintColor = .white
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.isTranslucent = true
        self.navigationController?.view.backgroundColor = .clear
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        print("I was in viewWillAppear")
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.isHidden = true
    }
    
    @IBAction func toggleLanguage(_ sender: UIButton) {
        
        if LocalizationSystem.sharedInstance.getLanguage() == "ar" {
            print("was arabic")
            LocalizationSystem.sharedInstance.setLanguage(languageCode: "en")
            UIView.appearance().semanticContentAttribute = .forceLeftToRight
        }else {
            print("was english")
            LocalizationSystem.sharedInstance.setLanguage(languageCode: "ar")
            UIView.appearance().semanticContentAttribute = .forceRightToLeft
        }
        
        self.navigationController?.viewControllers.removeAll()
        self.navigationController?.pushViewController(self, animated: true)
        self.navigationController?.popToRootViewController(animated: false)
        
        let window = UIApplication.shared.keyWindow!
        let sb = UIStoryboard(name: "Account", bundle: nil)
        let tab = sb.instantiateInitialViewController()
        window.rootViewController = tab
        window.makeKeyAndVisible()
    }
}

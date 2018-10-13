//
//  HelpViewController.swift
//  Doctor ElBalto
//
//  Created by Abanoub Osama on 6/19/18.
//  Copyright © 2018 Abanoub Osama. All rights reserved.
//

import UIKit

class HelpViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func call(_ sender: UIButton) {
        
        if let url = URL(string: "tel://\(Constants.CONTACT_PHONE)"), UIApplication.shared.canOpenURL(url) {
            if #available(iOS 10, *) {
                UIApplication.shared.open(url)
            } else {
                UIApplication.shared.openURL(url)
            }
        }
    }
    
    @IBAction func email(_ sender: UIButton) {
        
        if let url = URL(string: "mailto://\(Constants.CONTACT_EMAIL)"), UIApplication.shared.canOpenURL(url) {
            if #available(iOS 10, *) {
                UIApplication.shared.open(url)
            } else {
                UIApplication.shared.openURL(url)
            }
        }
    }
    
    @IBAction func openWebsite(_ sender: UIButton) {
        
        if let url = URL(string: Constants.WEBSITE_URL), UIApplication.shared.canOpenURL(url) {
            if #available(iOS 10, *) {
                UIApplication.shared.open(url)
            } else {
                UIApplication.shared.openURL(url)
            }
        }
    }
}

//
//  amanMessageController.swift
//  ElBalto
//
//  Created by mac on 9/25/18.
//  Copyright © 2018 Abanoub Osama. All rights reserved.
//

import UIKit

class amanMessageController: UIViewController {

    @IBOutlet weak var amnaNumber: UILabel!
    
    /*
     | MARK:- variables
     |==============================
     |
     */
    var amanNumberSent: Int!
    var mainViewController: MainViewController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let message = LocalizationSystem.sharedInstance.localizedStringForKey(key: "amanDetails", comment: "")
            + String(amanNumberSent) + LocalizationSystem.sharedInstance.localizedStringForKey(key: "amanDetails2", comment: "")
         self.amnaNumber.text = message
        
        amnaNumber.sizeToFit()
        amnaNumber.adjustsFontSizeToFitWidth = true
    }

    @IBAction func amanMessageClicked(_ sender: UIButton){
        let first  = self.navigationController?.viewControllers.first
        self.navigationController?.popToRootViewController(animated: false)

        if let main = first as? MainViewController {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let vc = storyboard.instantiateViewController(withIdentifier: "newTransaction")
            main.replaceViewController(vc)
        }
    }
    
}


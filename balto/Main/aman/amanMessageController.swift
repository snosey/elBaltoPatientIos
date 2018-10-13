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
    var amanNumberSent: Int? = nil
    var mainViewController: MainViewController!
    override func viewDidLoad() {
        super.viewDidLoad()
         self.amnaNumber.text = "go to aman shops and ask about Madfouaat Mutanouea Accept then pay by this bill number \(amanNumberSent!)"
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


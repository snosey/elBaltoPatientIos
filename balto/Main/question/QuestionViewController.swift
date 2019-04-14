//
//  QuestionViewController.swift
//  ElBalto
//
//  Created by rocky on 4/13/19.
//  Copyright © 2019 Abanoub Osama. All rights reserved.
//

import UIKit
import SwiftyJSON

class QuestionViewController: UIViewController {

    @IBOutlet weak var consultTF: UITextField!
    @IBOutlet weak var secondTF: UITextField!
    @IBOutlet weak var thirdTF: UITextField!
    @IBOutlet weak var fourthTF: UITextField!
    @IBOutlet weak var firstS: UISwitch!
    @IBOutlet weak var secondS: UISwitch!
    @IBOutlet weak var thirdS: UISwitch!
    @IBOutlet weak var fourthS: UISwitch!
    @IBOutlet weak var pregnantBtn: UIButton!
    @IBOutlet weak var genderBtn: UIButton!
    @IBOutlet weak var ageBtn: UIButton!
    @IBOutlet weak var pregnantView: UIView!
    
    var content: ContentSession!
    var loadingView: LoadingView!
    //var categories = [JSON]()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadingView = LoadingView(frame: view.frame)
        loadingView.setLoadingImage(image: UIImage(named: "loading")!)
        loadingView.backgroundColor = UIColor.white.withAlphaComponent(0.8)
        loadingView.isHidden = true
        self.view.addSubview(loadingView)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
    }
    
    @IBAction func start(_ sender: UIButton) {
        
    }
    
    @IBAction func selectAge(_ sender: UIButton) {
        if let tap = PopupHandler.choose as? oneSelectorPopUPViewController {
            tap.arrayUsed = Array(7...71)
            self.present(tap, animated: true)
        }
    }
    
    @IBAction func selectGender(_ sender: UIButton) {
        if let tap = PopupHandler.choose as? oneSelectorPopUPViewController {
            tap.dicUsed = [1: "Male", 2: "Female"]
            self.present(tap, animated: true)
        }
    }

}

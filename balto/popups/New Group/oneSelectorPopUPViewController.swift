//
//  oneSelectorPopUPViewController.swift
//  2OnMarch
//
//  Created by rocky on 3/23/19.
//  Copyright © 2019 dinnova. All rights reserved.
//

import UIKit

class oneSelectorPopUPViewController: UIViewController {
    
    var arrayUsed = [Any]()
    var dicUsed = [Int: String]()
    
    @IBOutlet weak var selectorPV: UIPickerView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        // print("selected at view did appear : \(selectorPV.selectedRow(inComponent: 0))" )
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
    }
    
    @IBAction func confirm(_ sender: UIButton) {
        NotificationCenter.default.post(name: .choosePopUp, object: self)
        dismiss(animated: true)
    }
    
    func returnSelected() -> Any {
        if self.arrayUsed.count > 0 {
            return arrayUsed[selectorPV.selectedRow(inComponent: 0)]
        }else {
            return selectorPV.selectedRow(inComponent: 0)
        }
    }
    
}

extension oneSelectorPopUPViewController: UIPickerViewDataSource , UIPickerViewDelegate {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if arrayUsed.count > 0 {
            return arrayUsed.count
        }else {
            return dicUsed.count
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if arrayUsed.count > 0 {
            return "\(arrayUsed[row])"
        }else {
            return dicUsed[row]
        }
    }
    
}

//
//  DatePickerController.swift
//  kora
//
//  Created by Abanoub Osama on 3/16/18.
//  Copyright © 2018 Abanoub Osama. All rights reserved.
//

import UIKit

class DatePickerController: UIViewController {
    
    var buttonDone: UIButton!
    var buttonCancel: UIButton!
    
    var pickerView: UIDatePicker!
    
    private var delegate: DatePickerDelegate!
    
    class func getInstance(delegate: DatePickerDelegate) -> DatePickerController {
        
        let viewController = DatePickerController()
        viewController.view.backgroundColor = UIColor.black.withAlphaComponent(0.0)
        
        viewController.delegate = delegate
        
        let height = Int(viewController.view.frame.height * 2 / 5)
        
        let frame = CGRect(x: 0, y: Int(viewController.view.frame.height) - height, width: Int(viewController.view.frame.width), height: height)
        
        let view = ShadowView(frame: frame)
        view.backgroundColor = UIColor.white
        
        viewController.buttonDone = UIButton()
        viewController.buttonDone.setTitle("Done", for: .normal)
        viewController.buttonDone.setTitleColor(UIColor.darkText, for: .normal)
        viewController.buttonDone.sizeToFit()
        viewController.buttonDone.addTarget(viewController, action: #selector(DatePickerController.done), for: .touchUpInside)
        
        viewController.buttonDone.frame = CGRect(x: view.frame.width - viewController.buttonDone.frame.width - 25, y: 0, width: viewController.buttonDone.frame.width + 25, height: viewController.buttonDone.frame.height + 5)
        view.addSubview(viewController.buttonDone)
        
        viewController.buttonCancel = UIButton()
        viewController.buttonCancel.setTitle("Cancel", for: .normal)
        viewController.buttonCancel.setTitleColor(UIColor.black, for: .normal)
        viewController.buttonCancel.sizeToFit()
        viewController.buttonCancel.addTarget(viewController, action: #selector(DatePickerController.cancel), for: .touchUpInside)
        
        viewController.buttonCancel.frame = CGRect(x: 5, y: 0, width: viewController.buttonCancel.frame.width + 5, height: viewController.buttonCancel.frame.height + 5)
        view.addSubview(viewController.buttonCancel)
        
        viewController.pickerView = UIDatePicker()
        
        viewController.pickerView.frame = CGRect(x: 0, y: viewController.buttonCancel.frame.height, width: view.frame.width, height: view.frame.height - viewController.buttonCancel.frame.height)
        viewController.pickerView.datePickerMode = .date
        view.addSubview(viewController.pickerView)
        
        viewController.view.addSubview(view)
        
        return viewController
    }
    
    class func present(_ vc: UIViewController, delegate: DatePickerDelegate) -> DatePickerController {
        
        let viewController = DatePickerController.getInstance(delegate: delegate)
        
        viewController.modalPresentationStyle = .overCurrentContext
        vc.present(viewController, animated: true, completion: nil)
        
        return viewController
    }
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    
    @objc private func done() {
        if !delegate.done(picker: self, date: self.pickerView.date) {
            dismiss(animated: true, completion: nil)
        }
    }
    
    @objc private func cancel() {
        if !delegate.cancel(picker: self) {
            dismiss(animated: true, completion: nil)
        }
    }
}

protocol DatePickerDelegate {
    
    func done(picker: DatePickerController, date: Date) -> Bool
    
    func cancel(picker: DatePickerController) -> Bool
}

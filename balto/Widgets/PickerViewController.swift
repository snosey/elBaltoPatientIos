//
//  PickerViewController.swift
//  Syariti
//
//  Created by Mena on 9/26/17.
//  Copyright © 2017 Mena. All rights reserved.
//

import UIKit

public class PickerViewController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate {
    
    var buttonDone: UIButton!
    var buttonCancel: UIButton!
    
    var pickerView: UIPickerView!
    
    private var delegate: PickerDelegate!
    
    public var items: [String] = []
    
    class func getInstance(delegate: PickerDelegate, items: [String]) -> PickerViewController {
        
        let viewController = PickerViewController()
        viewController.view.backgroundColor = UIColor.black.withAlphaComponent(0.0)
        
        viewController.items = items
        viewController.delegate = delegate
        
        let height = Int(viewController.view.frame.height * 2 / 5)
        
        let frame = CGRect(x: 0, y: Int(viewController.view.frame.height) - height, width: Int(viewController.view.frame.width), height: height)
        
        let view = ShadowView(frame: frame)
        view.backgroundColor = UIColor.white
        
        viewController.buttonDone = UIButton()
        viewController.buttonDone.setTitle("Done", for: .normal)
        viewController.buttonDone.setTitleColor(UIColor.darkText, for: .normal)
        viewController.buttonDone.sizeToFit()
        viewController.buttonDone.addTarget(viewController, action: #selector(PickerViewController.done), for: .touchUpInside)
        
        viewController.buttonDone.frame = CGRect(x: view.frame.width - viewController.buttonDone.frame.width - 25, y: 0, width: viewController.buttonDone.frame.width + 25, height: viewController.buttonDone.frame.height + 5)
        view.addSubview(viewController.buttonDone)
        
        viewController.buttonCancel = UIButton()
        viewController.buttonCancel.setTitle("Cancel", for: .normal)
        viewController.buttonCancel.setTitleColor(UIColor.black, for: .normal)
        viewController.buttonCancel.sizeToFit()
        viewController.buttonCancel.addTarget(viewController, action: #selector(PickerViewController.cancel), for: .touchUpInside)
        
        viewController.buttonCancel.frame = CGRect(x: 5, y: 0, width: viewController.buttonCancel.frame.width + 5, height: viewController.buttonCancel.frame.height + 5)
        view.addSubview(viewController.buttonCancel)
        
        viewController.pickerView = UIPickerView()
        
        viewController.pickerView.frame = CGRect(x: 0, y: viewController.buttonCancel.frame.height, width: view.frame.width, height: view.frame.height - viewController.buttonCancel.frame.height)
        
        viewController.pickerView.dataSource = viewController
        viewController.pickerView.delegate = viewController
        
        view.addSubview(viewController.pickerView)
        
        viewController.view.addSubview(view)
        
        return viewController
    }
    
    class func present(_ vc: UIViewController, delegate: PickerDelegate, items: [String]) -> PickerViewController {
        
        let viewController = PickerViewController.getInstance(delegate: delegate, items: items)
        
        viewController.modalPresentationStyle = .overCurrentContext
        vc.present(viewController, animated: true, completion: nil)
        
        return viewController
    }
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    
    override public func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    public func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    public func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return items.count
    }
    
    public func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return items[row]
    }
    /*
    public func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        var label: UILabel!
        
        if let labelView = view as? UILabel {
            
            label = labelView
        } else {
            
            label = UILabel()
            
            label.textColor = UIColor.red
            label.highlightedTextColor = UIColor.blue
            label.textAlignment = .center
            
            label.font = UIFont.systemFont(ofSize: 15)
        }
        
        label.text = items[row]
        
        return label
    }
    */
    @objc private func done() {
        if !delegate.done(picker: self) {
            dismiss(animated: true, completion: nil)
        }
    }
    
    @objc private func cancel() {
        if !delegate.cancel(picker: self) {
            dismiss(animated: true, completion: nil)
        }
    }
}

protocol PickerDelegate {
    
    func done(picker: PickerViewController) -> Bool
    
    func cancel(picker: PickerViewController) -> Bool
}

//
//  RadioGroup.swift
//  balto
//
//  Created by Abanoub Osama on 4/30/18.
//  Copyright © 2018 Abanoub Osama. All rights reserved.
//

import UIKit

class RadioGroup: UIStackView {
    
    var delegate: RadioGroupDelegate!
    var radioButtonSelector: ((_ deselectedView: UIView?, _ selectedView: UIView?) -> Void)! {
        
        willSet {
            
            if let radioSelector = self.radioButtonSelector {
                
                for view in arrangedSubviews {
                    
                    radioSelector(nil, view)
                }
            }
        }
        
//        didSet {
//
//            if let radioSelector = self.radioButtonSelector {
//
//                for view in arrangedSubviews {
//
//                    radioSelector(view, nil)
//                }
//            }
//        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        if radioButtonSelector == nil {
            
            radioButtonSelector = { deselectedView, selectedView in
                
                if let view = selectedView {
                
                    view.alpha = 1.0
                }
                
                if let view = deselectedView {
                    
                    view.alpha = 0.5
                }
            }
        }
        
        for view in arrangedSubviews {
            
            let tap = UITapGestureRecognizer(target: self, action: #selector(touchUpInside(_:)))
            tap.cancelsTouchesInView = true
            
            view.addGestureRecognizer(tap)
            
            radioButtonSelector(view, nil)
            
            if let button = view as? UIButton {
                
                button.imageView?.contentMode = .scaleAspectFit
            }
        }
    }
    
    override func addArrangedSubview(_ view: UIView) {
        super.addArrangedSubview(view)
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(touchUpInside(_:)))
        tap.cancelsTouchesInView = true
        
        view.addGestureRecognizer(tap)
    }
    
    override func removeArrangedSubview(_ view: UIView) {
        super.removeArrangedSubview(view)
        
//        view.removeGestureRecognizer(tap)
    }
    
    @objc func touchUpInside(_ sender: UIGestureRecognizer) {
        
        if let view = sender.view {
            
            for view in arrangedSubviews {
                
                radioButtonSelector(view, nil)
            }
            
            radioButtonSelector(nil, view)
            
            if let delegate = delegate {
                
                delegate.didSelectButton(self, view, arrangedSubviews.index(of: view) ?? -1)
            }
        } else {
            print("\n\nfailed to cast sender\n\n\n")
        }
    }
}

protocol RadioGroupDelegate {
    
    func didSelectButton(_ radioGroup: RadioGroup, _ selectedView: UIView, _ index: Int)
}

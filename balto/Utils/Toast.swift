//
//  Toast.swift
//  Barek
//
//  Created by Abanoub Osama on 1/14/17.
//  Copyright © 2017 Abanoub Osama. All rights reserved.
//

import Foundation
import UIKit

public class Toast {
    
    private static var timer: Timer!
    
    public static func showAlert(viewController: UIViewController,  title: String! = nil, text: String, okActionHandler: ((UIAlertAction) -> Void)? = nil) {
        
        let action = UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: okActionHandler)
        
        action.setValue(UIColor(red: 0x51 / 255, green: 0xcf / 255, blue: 0x98 / 255, alpha: 1), forKey: "titleTextColor")
        
        Toast.showAlert(viewController: viewController, text: text, style: UIAlertControllerStyle.actionSheet, action)
    }
    
    public static func showAlert(viewController: UIViewController,  title: String! = nil, text: String, dismissAfter interval: TimeInterval) {
        
        var alert: UIAlertController!
        
        if #available(iOS 10.0, *) {
            
            alert = UIAlertController(title: title, message: text, preferredStyle: .actionSheet)
            
            Toast.timer = Timer.scheduledTimer(withTimeInterval: interval, repeats: false, block: { (timer) in
                
                alert.dismiss(animated: true, completion: {
                    
                    Toast.timer = nil
                })
                
                timer.invalidate()
            })
            
            if let presented = viewController.presentedViewController, presented is UIAlertController {
                
                presented.dismiss(animated: false) {
                    
                    viewController.present(alert, animated: true, completion: nil)
                }
            } else {
                
                viewController.present(alert, animated: true, completion: nil)
            }
        } else {
            // Fallback on earlier versions
        }
    }
    
    public static func showAlert(viewController: UIViewController, title: String! = nil, text: String, style: UIAlertControllerStyle, actionColors: [UIColor] = [], _ actions: UIAlertAction...) {
        
        let alert = UIAlertController(title: title, message: text, preferredStyle: style)
        
        if actions.count == 1 {
            
            let action = actions[0]
            
            action.setValue(actionColors.first ?? UIColor.green, forKey: "titleTextColor")
            
            alert.addAction(action)
            
            alert.preferredAction = action
        } else {
            
            for i in 0..<actions.count {
                let action = actions[i]
                let color = actionColors.isEmpty ? UIColor.green : actionColors[ i % actionColors.count]
                if i == 0 {
                    
                    action.setValue(color.withAlphaComponent(1), forKey: "titleTextColor")
                } else {
                    
                    action.setValue(color, forKey: "titleTextColor")
                }
                
                alert.addAction(action)
                alert.preferredAction = action
            }
        }
        
        if let presented = viewController.presentedViewController, presented is UIAlertController {
            
            presented.dismiss(animated: false) {
                
                viewController.present(alert, animated: true, completion: nil)
            }
        } else {
        
            viewController.present(alert, animated: true, completion: nil)
        }
    }
    
    public static func showAlert(viewController: UIViewController, title: String! = nil, text: String, fieldHints: [String], _ actions: UIAlertAction...) -> UIAlertController {
        
        let alert = UIAlertController(title: title, message: text, preferredStyle: .alert)
        
        for fieldHint in fieldHints {
            
            alert.addTextField { (textField) in
                
                textField.placeholder = fieldHint
                textField.keyboardType = UIKeyboardType.emailAddress
            }
        }
        
        if actions.count == 1 {
            
            let action = actions[0]
            
            action.setValue(UIColor(red: 0x51 / 255, green: 0xcf / 255, blue: 0x98 / 255, alpha: 1), forKey: "titleTextColor")
            
            alert.addAction(action)
            
            alert.preferredAction = action
        } else {
            
            for i in 0..<actions.count {
                let action = actions[i]
                if i == 0 {
                    
                    action.setValue(UIColor(red: 0x51 / 255, green: 0xcf / 255, blue: 0x98 / 255, alpha: 0.6), forKey: "titleTextColor")
                } else {
                    
                    action.setValue(UIColor(red: 0x51 / 255, green: 0xcf / 255, blue: 0x98 / 255, alpha: 1), forKey: "titleTextColor")
                }
                
                alert.addAction(action)
                alert.preferredAction = action
            }
        }
        
        alert.view.backgroundColor = UIColor.white
        alert.view.layer.cornerRadius = 10
        
        if let presented = viewController.presentedViewController, presented is UIAlertController {
            
            presented.dismiss(animated: false) {
                
                viewController.present(alert, animated: true, completion: nil)
            }
        } else {
            
            viewController.present(alert, animated: true, completion: nil)
        }
        
        return alert
    }
}


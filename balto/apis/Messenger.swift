//
//  Messenger.swift
//  2OnMarch
//
//  Created by rocky on 2/6/19.
//  Copyright © 2019 dinnova. All rights reserved.
//

import UIKit

class Messenger : UIViewController {
    
    static let defaultTitle: String = "OK"
    
    static func alert(_ object: UIViewController, _ title: String?, message: String, style: UIAlertController.Style) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: style)
        let action = UIAlertAction(title: defaultTitle, style: .cancel)
        
        alert.addAction(action)
        object.present(alert, animated: true)
    }
    
    
    static func alertWithActions(_ object: UIViewController, _ title: String?, message: String, style: UIAlertController.Style, actions: [String: UIAlertAction.Style], completion: @escaping (_ name: String) -> Void ) {
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: style)
        
        actions.forEach { (key, value) in
            let action = UIAlertAction(title: key, style: value, handler: { (name) in
                completion(key)
            })
            alert.addAction(action)
        }
        
        object.present(alert, animated: true)
    }
    
    static func currentController() -> UIViewController? {
        if let topController = UIApplication.shared.keyWindow?.rootViewController {
            while let presentedViewController = topController.presentedViewController {
                return presentedViewController
            }
        }
        return nil
    }
    
}

//
//  labelExetensions.swift
//  ElBalto
//
//  Created by mac on 10/3/18.
//  Copyright © 2018 Abanoub Osama. All rights reserved.
//

import Foundation
import UIKit

class LocalisableLabel: UILabel {
    
    @IBInspectable var localisedKey: String? {
        didSet {
            guard let key = localisedKey else { return }
            text = LocalizationSystem.sharedInstance.localizedStringForKey(key: key, comment: "")
        }
    }
    
}
class LocalisableButton: UIButton {
    
    @IBInspectable var localisedKey: String? {
        didSet {
            guard let key = localisedKey else { return }
            self.setTitle(LocalizationSystem.sharedInstance.localizedStringForKey(key: key, comment: ""), for: .normal)
        }
    }
    
}

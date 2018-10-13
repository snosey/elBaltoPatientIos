//
//  UILabel.swift
//  Doctor ElBalto
//
//  Created by Abanoub Osama on 5/29/18.
//  Copyright © 2018 Abanoub Osama. All rights reserved.
//

import Foundation
import UIKit

extension UILabel {
    
    @objc
    public var substituteFontName : String {
        get {
            return self.font.fontName
        }
        set {
            let fontNameToTest = self.font.fontName.lowercased()
            var fontName = newValue
            if fontNameToTest.range(of: "bold") != nil {
                fontName += "-Bold"
            } else if fontNameToTest.range(of: "medium") != nil {
                fontName += "-Medium"
            } else if fontNameToTest.range(of: "light") != nil {
                fontName += "-Light"
            } else if fontNameToTest.range(of: "ultralight") != nil {
                fontName += "-UltraLight"
            }
            self.font = UIFont(name: fontName, size: self.font.pointSize)
        }
    }
}

extension UITextField {
    
    @objc
    public var substituteFontName : String {
        get {
            return self.font!.fontName
        }
        set {
            let fontNameToTest = self.font?.fontName.lowercased() ?? ""
            var fontName = newValue
            if fontNameToTest.range(of: "bold") != nil {
                fontName += "-Bold"
            } else if fontNameToTest.range(of: "medium") != nil {
                fontName += "-Medium"
            } else if fontNameToTest.range(of: "light") != nil {
                fontName += "-Light"
            } else if fontNameToTest.range(of: "ultralight") != nil {
                fontName += "-UltraLight"
            }
            if let size = self.font?.pointSize {
                
                self.font = UIFont(name: fontName, size: size)
            }
        }
    }
}

extension UITextView {
    
    @objc
    public var substituteFontName : String {
        get {
            return self.font!.fontName
        }
        set {
            let fontNameToTest = self.font?.fontName.lowercased() ?? ""
            var fontName = newValue
            if fontNameToTest.range(of: "bold") != nil {
                fontName += "-Bold"
            } else if fontNameToTest.range(of: "medium") != nil {
                fontName += "-Medium"
            } else if fontNameToTest.range(of: "light") != nil {
                fontName += "-Light"
            } else if fontNameToTest.range(of: "ultralight") != nil {
                fontName += "-UltraLight"
            }
            if let size = self.font?.pointSize {
                
                self.font = UIFont(name: fontName, size: size)
            }
        }
    }
}

extension UIButton {
    
    @objc
    public var substituteFontName : String {
        get {
            return self.titleLabel?.font.fontName ?? ""
        }
        set {
            let fontNameToTest = self.titleLabel?.font.fontName.lowercased() ?? ""
            var fontName = newValue
            if fontNameToTest.range(of: "bold") != nil {
                fontName += "-Bold"
            } else if fontNameToTest.range(of: "medium") != nil {
                fontName += "-Medium"
            } else if fontNameToTest.range(of: "light") != nil {
                fontName += "-Light"
            } else if fontNameToTest.range(of: "ultralight") != nil {
                fontName += "-UltraLight"
            }
            if let size = self.titleLabel?.font.pointSize {
                
                self.titleLabel?.font = UIFont(name: fontName, size: size)
            }
        }
    }
}


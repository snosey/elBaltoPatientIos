//
//  ShadowView.swift
//  Syariti
//
//  Created by Mena on 9/17/17.
//  Copyright © 2017 Mena. All rights reserved.
//

import UIKit

class ShadowView: UIView {
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        self.layer.shadowColor = UIColor.black.withAlphaComponent(0.3).cgColor
        self.layer.shadowOpacity = 0.3
        self.layer.shadowOffset = CGSize.zero
        self.layer.shadowRadius = 2
        // sets the path for the shadow to save ondraw time
        self.layer.shadowPath = UIBezierPath(rect: self.bounds).cgPath
        // cache the shadow so it isn't redrawn
//        self.layer.shouldRasterize = true
    }
}

//
//  CircularImageView.swift
//  Tabeeb
//
//  Created by Abanoub Osama on 5/3/17.
//  Copyright © 2017 Abanoub Osama. All rights reserved.
//

import UIKit

class CircularImageView: UIImageView {
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let size = self.frame.size.width
        self.layer.cornerRadius = size / 2
        self.clipsToBounds = true
        self.contentMode = .scaleToFill
    }
}

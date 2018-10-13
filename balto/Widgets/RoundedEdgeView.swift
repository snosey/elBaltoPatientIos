//
//  RoundedEdgeView.swift
//  Syariti
//
//  Created by Mena on 9/17/17.
//  Copyright © 2017 Mena. All rights reserved.
//

import UIKit

class RoundedEdgeView: UIView {
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        layer.cornerRadius = 5
    }
}

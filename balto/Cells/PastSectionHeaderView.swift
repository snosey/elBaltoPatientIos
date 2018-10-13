//
//  HomeSectionHeaderView.swift
//  kora
//
//  Created by Abanoub Osama on 3/3/18.
//  Copyright © 2018 Abanoub Osama. All rights reserved.
//

import UIKit

class PastSectionHeaderView: UIView {
    
    @IBOutlet weak var buttonDate: UIButton!
    @IBOutlet weak var buttonAll: UIButton!
    
    class func instantiateFromNib(named: String = "PastSectionHeaderView") -> PastSectionHeaderView {
        
        let view =  UINib(nibName: named, bundle: nil).instantiate(withOwner: nil, options: nil)[0] as! PastSectionHeaderView
        view.buttonDate.imageView?.contentMode = .scaleAspectFit
        return view
    }
}

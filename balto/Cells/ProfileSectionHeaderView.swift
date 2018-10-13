//
//  HomeSectionHeaderView.swift
//  kora
//
//  Created by Abanoub Osama on 3/3/18.
//  Copyright © 2018 Abanoub Osama. All rights reserved.
//

import UIKit

class ProfileSectionHeaderView: UIView {
    
    @IBOutlet weak var labelName: UILabel!
    
    class func instantiateFromNib(named: String = "ProfileSectionHeaderView") -> ProfileSectionHeaderView {
        return UINib(nibName: named, bundle: nil).instantiate(withOwner: nil, options: nil)[0] as! ProfileSectionHeaderView
    }
}

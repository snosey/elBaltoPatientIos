//
//  specializationTableViewCell.swift
//  ElBalto
//
//  Created by rocky on 4/10/19.
//  Copyright © 2019 Abanoub Osama. All rights reserved.
//

import UIKit

class specializationTableViewCell: UITableViewCell {

    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var logo: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        backgroundColor = .white 
    }
    
    func setup(name: String, logo: String?) {
        self.name.text = name
        if var newLogo = logo {
            newLogo = "http://haseboty.com/doctor/public/images/" + newLogo
            self.logo.findMe(url: newLogo)
        }
    }
}

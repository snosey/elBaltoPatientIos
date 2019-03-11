//
//  messagesTableViewCell.swift
//  ElBalto
//
//  Created by rocky on 2/25/19.
//  Copyright © 2019 Abanoub Osama. All rights reserved.
//

import UIKit

class messagesTableViewCell: UITableViewCell {

    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var profession: UILabel!
    @IBOutlet weak var date: UILabel!
    @IBOutlet weak var rate: UILabel!
    @IBOutlet weak var imageProfile: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        backgroundColor = .white
        
        layer.cornerRadius = 10
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOffset = CGSize(width: 1.0, height: 3.0)
        layer.shadowOpacity = 0.2
        layer.shadowRadius = 1
        
        layer.masksToBounds = false
    }
    
    func configCell(title: String, profession: String, date: String, rate: Double) {
        self.title.text = title
        self.profession.text = profession
        self.date.text = date
        self.rate.text = String(rate)
    }
    
}

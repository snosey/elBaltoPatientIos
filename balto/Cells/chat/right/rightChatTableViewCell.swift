//
//  rightChatTableViewCell.swift
//  ElBalto
//
//  Created by rocky on 2/25/19.
//  Copyright © 2019 Abanoub Osama. All rights reserved.
//

import UIKit

class rightChatTableViewCell: UITableViewCell {

    @IBOutlet weak var imageMessage: UIImageView!
    @IBOutlet weak var labelMessage: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        layer.masksToBounds = true
        layer.cornerRadius = 8
    }
    
    func configCell(message: String) {
        if message.hasPrefix("http") == true {
            self.imageMessage.findMe(url: message)
        }else {
            self.imageMessage.isHidden = true
            self.labelMessage.text = message
        }
    }
    
    
}

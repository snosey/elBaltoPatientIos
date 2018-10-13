//
//  PromotionTableCell.swift
//  balto
//
//  Created by Abanoub Osama on 3/29/18.
//  Copyright © 2018 Abanoub Osama. All rights reserved.
//

import UIKit

class PromotionTableCell: UITableViewCell {
    
    @IBOutlet weak var labelCode: UILabel!
    @IBOutlet weak var labelValue: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    func setDetails(coupon: Coupon) {
        
        labelCode.text = coupon.name
        labelValue.text = "\(coupon.id)"
    }
    
    @IBAction func copyCode(_ sender: UIButton) {
        
        UIPasteboard.general.string = labelCode.text!
    }
}

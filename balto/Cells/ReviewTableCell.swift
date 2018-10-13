//
//  ReviewTableCell.swift
//  balto
//
//  Created by Mena Gamal on 4/3/18.
//  Copyright © 2018 Abanoub Osama. All rights reserved.
//

import UIKit
import SDWebImage

class ReviewTableCell: UITableViewCell {

    @IBOutlet weak var imageviewProfilePic: CircularImageView!
    @IBOutlet weak var labelName: UILabel!
    @IBOutlet weak var labelRate: UILabel!
    @IBOutlet weak var labelReview: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func setDetails(review: Review)  {
        
        if let image = review.userImage, !image.isEmpty {
        
            imageviewProfilePic.sd_setImage(with: URL(string: image), completed: nil)
        } else {
            
            imageviewProfilePic.image = UIImage(named: "logo_profile")
        }
        
        labelName.text = review.userName
        labelReview.text = review.name
        
        labelRate.text = "\(review.rate ?? 0)"
    }
}

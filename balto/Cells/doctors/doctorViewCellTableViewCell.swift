//
//  doctorViewCellTableViewCell.swift
//  ElBalto
//
//  Created by rocky on 2/27/19.
//  Copyright © 2019 Abanoub Osama. All rights reserved.
//

import UIKit

class doctorViewCellTableViewCell: UITableViewCell {

    @IBOutlet weak var imageviewProfilePic: CircularImageView!
    @IBOutlet weak var labelName: UILabel!
    @IBOutlet weak var labelSpecialization: UILabel!
    @IBOutlet weak var labelRate: UILabel!
    @IBOutlet weak var labelPrice: UILabel!
    
    private var vc: UIViewController!
    private var doctor: Doctor!
    var closure: (() -> ())?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func setDetails(vc: UIViewController, doctor:Doctor)  {
        self.vc = vc
        self.doctor = doctor
        
        if let image = doctor.image, !image.isEmpty {
            
            imageviewProfilePic.sd_setImage(with: URL(string: image), completed: nil)
        } else {
            
            imageviewProfilePic.image = UIImage(named: "logo_profile")
        }
        
        labelName.text = "\(doctor.firstName!) \(doctor.lastName!)"
        labelSpecialization.text = doctor.specialization.name
        if let price = doctor.price {
            labelPrice.text = "\(price) EGP"
        }
        labelRate.text = "\(doctor.rate!)"
    }
    
    @IBAction func book(_ sender: UIButton) {
        closure?()
    }

}

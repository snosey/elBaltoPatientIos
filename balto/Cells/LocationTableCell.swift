//
//  AreasTableCell.swift
//  Tabeeb
//
//  Created by Abanoub Osama on 5/19/17.
//  Copyright © 2017 Abanoub Osama. All rights reserved.
//

import UIKit

class LocationTableCell: UITableViewCell {
    
    @IBOutlet weak var imageViewCheckbox: UIImageView!
    @IBOutlet weak var labelName: UILabel!
    
    private var city: BaseModel!
    private var onSelected: ((_ isSelected: Bool, _ city: BaseModel) -> Void)!

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        if selected {
            imageViewCheckbox.image = UIImage(named: "ic_checkbox_checked")
        } else {
            imageViewCheckbox.image = UIImage(named: "ic_checkbox_unchecked")
        }
        
        if onSelected != nil {
            onSelected(selected, city)
        }
        
        super.setSelected(selected, animated: false)
    }
    
    func setDetails(city: BaseModel, onSelected: ((_ isSelected: Bool, _ city: BaseModel) -> Void)!) {
        self.city = city
        self.onSelected = onSelected
        
        labelName.text = city.name
    }
}

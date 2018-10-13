//
//  DocTableCell.swift
//  balto
//
//  Created by Abanoub Osama on 5/22/18.
//  Copyright © 2018 Abanoub Osama. All rights reserved.
//

import UIKit

class DocTableCell: UITableViewCell {
    
    @IBOutlet weak var imageViewDoc: UIImageView!
    
    private var vc: ProfileViewController!
    
    private var url: String!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func setDetails(_ vc: ProfileViewController, url: String) {
        self.vc = vc
        self.url = url
     
        imageViewDoc.sd_setImage(with: URL(string: url), completed: nil)
    }
}

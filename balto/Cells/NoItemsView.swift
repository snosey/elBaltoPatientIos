//
//  NoItemsView.swift
//  kora
//
//  Created by Abanoub Osama on 4/18/18.
//  Copyright © 2018 Abanoub Osama. All rights reserved.
//

import UIKit

class NoItemsView: UIView {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var label: UILabel!
    
    public class func loadFromNib() -> NoItemsView {
        return UINib(nibName: "NoItemsView", bundle: nil).instantiate(withOwner: nil, options: nil)[0] as! NoItemsView
    }
}

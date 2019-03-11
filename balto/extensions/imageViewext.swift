//
//  imageViewExt.swift
//  2By2
//
//  Created by rocky on 12/8/18.
//  Copyright © 2018 personal. All rights reserved.
//

import UIKit
import SDWebImage

extension UIImageView {
    
    func setImageColor(color: UIColor) {
        let templateImage = self.image?.withRenderingMode(UIImage.RenderingMode.alwaysTemplate)
        self.image = templateImage
        self.tintColor = color
    }
    
    
    func findMe(url: String) {
        DispatchQueue.main.async {
            let imagePath = url
            self.sd_setShowActivityIndicatorView(true)
            self.sd_setIndicatorStyle(.gray)
            self.sd_setImage(with: URL(string: imagePath), placeholderImage: UIImage(named: "logo_icon"))
        }
    }
    
    func imageRadius() {
        self.layer.masksToBounds = false
        self.layer.cornerRadius = self.frame.height/2
        self.clipsToBounds = true
    }
    
}


extension UIButton {
    
    func findMe(url: String) {
        DispatchQueue.main.async {
            let imagePath = url
            self.sd_setShowActivityIndicatorView(true)
            self.sd_setIndicatorStyle(.gray)
            self.sd_setImage(with: URL(string: imagePath), for: .normal, placeholderImage: UIImage(named: "profile-pic-size"), options: SDWebImageOptions(), completed: nil)
            //sd_setImage(with: URL(string: imagePath), for: .normal, completed: nil)
        }
    }
    
    func radiusButtonImage() {
        self.layer.masksToBounds = false
        self.layer.cornerRadius = self.frame.height/2
        self.clipsToBounds = true
    }
    
}

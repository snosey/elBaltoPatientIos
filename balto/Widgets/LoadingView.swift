//
//  LoadingImageView.swift
//  Tabeeb
//
//  Created by Abanoub Osama on 4/29/17.
//  Copyright © 2017 Abanoub Osama. All rights reserved.
//

import UIKit

class LoadingView: UIView {
    
    var loadingSize: Int = 70
    
    var imageView: UIImageView = UIImageView()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        //        addSubview(imageView)
        //
        //        self.translatesAutoresizingMaskIntoConstraints = false
        //
        //        let _1 = imageView.heightAnchor.constraint(equalToConstant: CGFloat(loadingSize))
        //        let _2 = imageView.widthAnchor.constraint(equalToConstant: CGFloat(loadingSize))
        //        let _3 = imageView.centerXAnchor.constraint(equalTo: self.centerXAnchor)
        //        let _4 = imageView.centerYAnchor.constraint(equalTo: self.centerYAnchor)
        //
        //        self.addConstraints([_1, _2, _3, _4])
    }
    
    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        
        //        let superview = superview!
        //
        //        self.translatesAutoresizingMaskIntoConstraints = false
        //
        //        let _1 = self.topAnchor.constraint(equalTo: superview.topAnchor)
        //        let _2 = imageView.widthAnchor.constraint(equalToConstant: CGFloat(loadingSize))
        //        let _3 = imageView.centerXAnchor.constraint(equalTo: self.centerXAnchor)
        //        let _4 = imageView.centerYAnchor.constraint(equalTo: self.centerYAnchor)
        //
        //        self.addConstraints([_1, _2, _3, _4])
        
    }
    
    func setLoadingImage(image: UIImage) {
        
        imageView.image = image
        
        imageView.frame = CGRect(x: self.frame.width / 2 - CGFloat(loadingSize / 2), y: self.frame.height / 2 - CGFloat(loadingSize / 2), width: CGFloat(loadingSize), height: CGFloat(loadingSize))
        
        addSubview(imageView)
    }
    
    func setIsLoading(_ isLoading: Bool) {
        
        if isLoading {
            
            OperationQueue.main.addOperation {
                
                self.isHidden = false
                self.superview?.bringSubview(toFront: self)
                self.imageView.startAnimating()
                if !self.imageView.isAnimating {
                    
                    let rotation = CABasicAnimation(keyPath: "transform.rotation")
                    rotation.fromValue = 0
                    rotation.toValue = (2 * Double.pi)
                    rotation.duration = 1.5
                    rotation.repeatCount = Float.greatestFiniteMagnitude
                    
                    self.imageView.layer.removeAllAnimations()
                    self.imageView.layer.add(rotation, forKey: "rotation")
                }
            }
        } else {
            
            OperationQueue.main.addOperation {
                
                self.isHidden = true
                self.imageView.stopAnimating()
            }
        }
    }
}



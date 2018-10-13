//
//  Profession.swift
//  balto
//
//  Created by Abanoub Osama on 4/27/18.
//  Copyright © 2018 Abanoub Osama. All rights reserved.
//

import UIKit

class SummaryView: UIView {
    
    @IBOutlet weak var labelPrice: UILabel!
    @IBOutlet weak var labelPaymentMethod: UILabel!
    @IBOutlet weak var labelSpecialization: UILabel!
    
    private var vc: HomeVisitViewController!
    
    class func instantiateFromNib(vc: HomeVisitViewController!) -> SummaryView {
        
        let view = UINib(nibName: "SummaryView", bundle: nil).instantiate(withOwner: nil, options: nil)[0] as! SummaryView
        
        view.vc = vc
        
        return view
    }
    
    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        
        let totalPrice = vc.specialization.baseFare + (vc.serviceDuration / 60) * vc.specialization.peicePerHour
        
        labelPrice.text = "\(totalPrice) EGP"
        
        switch vc.paymentMethod {
        case 1:
            labelPaymentMethod.text = "Cash"
            break
        case 2:
            labelPaymentMethod.text = "Credit"
            break
        default:
            break
        }
        
        labelSpecialization.text = vc.specialization.name
    }
    
    @IBAction func schedule(_ sender: UIButton) {
        vc.schedule()
    }
    
    @IBAction func confirm(_ sender: UIButton) {
        vc.confirm()
    }
}

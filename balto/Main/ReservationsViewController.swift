//
//  ReservationsViewController.swift
//  balto
//
//  Created by Abanoub Osama on 4/3/18.
//  Copyright © 2018 Abanoub Osama. All rights reserved.
//

import UIKit
import XLPagerTabStrip

class ReservationsViewController: ButtonBarPagerTabStripViewController {
    
    override func viewDidLoad() {
        
        settings.style.buttonBarBackgroundColor = .white
        settings.style.buttonBarItemBackgroundColor = .white
        settings.style.selectedBarBackgroundColor = UIColor.pink
        settings.style.buttonBarItemTitleColor = UIColor.black
        
        settings.style.buttonBarItemsShouldFillAvailiableWidth = true
        
        settings.style.buttonBarItemFont = .systemFont(ofSize: 14)
        
        changeCurrentIndexProgressive = { (oldCell, newCell, progress, changeCurrent, animated) in
            
            if changeCurrent {
                
                oldCell?.label.textColor =  UIColor.gray
                newCell?.label.textColor =  UIColor.black
            }
        }
        
        super.viewDidLoad()
        
        view.layoutSubviews()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.navigationController?.navigationBar.topItem?.title = LocalizationSystem.sharedInstance.localizedStringForKey(key: "reservation", comment: "")
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.navigationBar.topItem?.title = ""
    }
    
    override func viewControllers(for pagerTabStripController: PagerTabStripViewController) -> [UIViewController] {
        
        let upcoming = UpcomingReservationsViewController.getInstance()
        
        let past = PastReservationsViewController()
        past.title = LocalizationSystem.sharedInstance.localizedStringForKey(key: "past", comment: "")
        
        return [upcoming, past]
    }
}

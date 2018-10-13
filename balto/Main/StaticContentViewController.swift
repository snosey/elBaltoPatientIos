//
//  StaticContentViewController.swift
//  balto
//
//  Created by Abanoub Osama on 3/29/18.
//  Copyright © 2018 Abanoub Osama. All rights reserved.
//

import UIKit
import WebKit

class StaticContentViewController: UIViewController {
    
    public enum ViewcontrollerType : Int {
        case ContactUs, TermsAndConditions
    }
    
    @IBOutlet weak var webView: WKWebView!
    @IBOutlet weak var webView9: UIWebView!
    
    var viewControllerType: ViewcontrollerType!
    
    var url:URL!
    var request:URLRequest!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if viewControllerType == ViewcontrollerType.ContactUs {
            
            url = URL(string: "http://www.sda.ads/contact")
        } else if viewControllerType == ViewcontrollerType.TermsAndConditions {
            
            if LocalizationSystem.sharedInstance.getLanguage() == "ar" {
            
                url = Bundle.main.url(forResource: "terms_ar", withExtension: "html")
            } else {
                
                url = Bundle.main.url(forResource: "terms_en", withExtension: "html")
            }
        }
        
        request = URLRequest(url: url!)
        
        if #available(iOS 10.0, *) {
            
//            webView.load(request)
            webView9.loadRequest(request)
            
        } else {
            
            webView9.loadRequest(request)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        self.navigationController?.navigationBar.isHidden = false
        self.navigationController?.navigationBar.backgroundColor = UIColor.green
        self.navigationController?.navigationBar.isTranslucent = false
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if viewControllerType == .ContactUs {
            
            self.navigationController?.navigationBar.topItem?.title = LocalizationSystem.sharedInstance.localizedStringForKey(key: "contact_us", comment: "")
        } else {
            
            self.navigationController?.navigationBar.topItem?.title = LocalizationSystem.sharedInstance.localizedStringForKey(key: "termAndCondition", comment: "")
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.navigationBar.topItem?.title = ""
    }
}

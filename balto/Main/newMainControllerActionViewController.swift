//
//  newMainControllerActionViewController.swift
//  ElBalto
//
//  Created by rocky on 2/14/19.
//  Copyright © 2019 Abanoub Osama. All rights reserved.
//

import UIKit

class newMainControllerActionViewController: UIViewController, AccountDelegate {
    
    func onPreExecute(action: AccountSession.ActionType) {}
    
    func onPostExecute(status: BaseUrlSession.Status, action: AccountSession.ActionType, response: Any!) {}
    
    private var account: AccountSession!
    
    @IBOutlet weak var userNameLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        account = AccountSession(delegate: self)
        
        if LocalizationSystem.sharedInstance.getLanguage() == "ar" {
            self.shareImage.setImage(UIImage(named: "share_app_ar"), for: .normal)
            self.onlineImage.setImage(UIImage(named: "book_anappoinment_ar"), for: .normal)
            self.homeVisitImage.setImage(UIImage(named: "see_medical_report_ar"), for: .normal)
        }else {
            
            self.shareImage.setImage(UIImage(named: "share_app"), for: .normal)
            self.onlineImage.setImage(UIImage(named: "book_anappoinment"), for: .normal)
            self.homeVisitImage.setImage(UIImage(named: "see_medical_report"), for: .normal)
        }
        
        self.userNameLabel.text = "Hi, \(SettingsManager().getFullName())"
    }
    
    @IBAction func share(_ sender: UIButton) {
        UIGraphicsBeginImageContext(view.frame.size)
        view.layer.render(in: UIGraphicsGetCurrentContext()!)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        let textToShare = "Check out my app"
        
        if let myWebsite = URL(string: "http://itunes.apple.com/app/idXXXXXXXXX") {
            let objectsToShare = [textToShare, myWebsite, image ?? #imageLiteral(resourceName: "app-logo")] as [Any]
            let activityVC = UIActivityViewController(activityItems: objectsToShare, applicationActivities: nil)
            activityVC.excludedActivityTypes = [UIActivityType.airDrop, UIActivityType.addToReadingList]
            activityVC.popoverPresentationController?.sourceView = sender
            self.present(activityVC, animated: true, completion: nil)
        }
    }
    
    
    @IBOutlet weak var shareImage: UIButton!
    @IBOutlet weak var onlineImage: UIButton!
    @IBOutlet weak var homeVisitImage: UIButton!
   
    
    @IBAction func homeVisitClicked(_ sender: UIButton) {
        Toast.showAlert(viewController: self, text: "Coming Soon")
    }
    
    @IBAction func chatBtnClicked(_ sender: UIButton) {
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "openChooseDoctorTochatwithVC" {
            if let dest = segue.destination as? OnlineConsultingViewController {
                dest.forChat = true 
            }
        }
    }
    
}

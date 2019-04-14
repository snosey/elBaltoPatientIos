//
//  SideMenuControllerTableViewController.swift
//  kora
//
//  Created by Abanoub Osama on 3/2/18.
//  Copyright © 2018 Abanoub Osama. All rights reserved.
//

import UIKit
import SideMenu

class SideMenuTableViewController: UITableViewController, AccountDelegate {

    let itemNames = ["Home", "reservation", "myCredit", "promotions", "messages", "share", "termAndCondition", "help", "logout"]
    
    let itemImages = ["ic_home_blue", "reservation", "ic_payment_blue", "promo", "26_chat", "share-512", "terms and cond", "14_help", "log_out"]
    
    @IBOutlet weak var imageViewProfile: UIImageView!
    @IBOutlet weak var labelName: UILabel!
    @IBOutlet weak var versionLabel: UILabel!
    
    var sideMenu: UISideMenuNavigationController!
    
    private var account: AccountSession!
    
    var mainViewController: MainViewController!
    var vc: UIViewController!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        account = AccountSession(delegate: self)
        
        tableView.register(UINib(nibName: "SideMenuCell", bundle: nil), forCellReuseIdentifier: "cell")
        
        tableView.estimatedRowHeight = 100
        tableView.rowHeight = UITableViewAutomaticDimension
        
        tableView.estimatedSectionHeaderHeight = 10
        tableView.sectionHeaderHeight = UITableViewAutomaticDimension
        if let appVersion = Bundle.main.infoDictionary!["CFBundleShortVersionString"] as? String {
            self.versionLabel.text = "version \(appVersion)"
        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let settingsManager = SettingsManager()
        
        labelName.text = settingsManager.getFullName().components(separatedBy: " ")[0]
        
        if let image = settingsManager.getProfilePic(), !image.isEmpty, let url = URL(string: image) {
            
            imageViewProfile.sd_setImage(with: url, completed: nil)
        } else {
            
            imageViewProfile.image = UIImage(named: "logo_profile")
        }
    }
    
    @IBAction func showMyProfile(_ sender: UIButton) {
        
        let vc = storyboard?.instantiateViewController(withIdentifier: "PatientViewController")
        mainViewController.replaceViewController(vc!)
        mainViewController.dismiss(animated: true, completion: nil)
        
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        switch indexPath.row {
            // home (book appointment)
        case 0:
            vc = storyboard?.instantiateViewController(withIdentifier: "BookAppointmentViewController")
            break
            // reservations
        case 1:
            
            vc = storyboard?.instantiateViewController(withIdentifier: "ReservationsViewController")
            break
            // payment
        case 2:
            vc = storyboard?.instantiateViewController(withIdentifier: "newTransaction")
            break
            // promotions
        case 3:
            vc = PromotionsTableViewController()
            break
            // share
        case 5:
            let userId = SettingsManager().getUserId()
            account.addCoupon(userId: userId)
            return
            // language
        /*case 5:
           
            self.dismiss(animated: false, completion: nil)
            if LocalizationSystem.sharedInstance.getLanguage() == "ar" {
                LocalizationSystem.sharedInstance.setLanguage(languageCode: "en")
                UIView.appearance().semanticContentAttribute = .forceLeftToRight
            }else {
                LocalizationSystem.sharedInstance.setLanguage(languageCode: "ar")
                UIView.appearance().semanticContentAttribute = .forceRightToLeft
            }
            
            let window = UIApplication.shared.keyWindow!
            let sb = UIStoryboard(name: "Main", bundle: nil)
            let tab = sb.instantiateInitialViewController()
            
            self.navigationController?.viewControllers.removeAll()
            self.navigationController?.pushViewController(tab!, animated: true)
            self.navigationController?.popToRootViewController(animated: false)

            window.rootViewController = tab
            window.makeKeyAndVisible()
            
            
            
            return
            // terms_and_cond
        */case 6:
            let staticContent = storyboard?.instantiateViewController(withIdentifier: "StaticContentViewController") as! StaticContentViewController
            staticContent.viewControllerType = .TermsAndConditions
            
            vc = staticContent
            break
            //  help
        case 7:
            vc = storyboard?.instantiateViewController(withIdentifier: "HelpViewController")
            break
            // logout
        case 8:
            
            Toast.showAlert(viewController: self, text: LocalizationSystem.sharedInstance.localizedStringForKey(key:"areYouSure", comment: ""), style: .alert, actionColors: [UIColor.green, UIColor.pink], UIAlertAction(title: LocalizationSystem.sharedInstance.localizedStringForKey(key:"cancel", comment: ""), style: .cancel, handler: nil), UIAlertAction(title: LocalizationSystem.sharedInstance.localizedStringForKey(key:"logout", comment: ""), style: .default, handler: { (action) in
                
                self.mainViewController.dismiss(animated: true, completion: {
                    
//                    let domain = Bundle.main.bundleIdentifier!
//                    UserDefaults.standard.removePersistentDomain(forName: domain)
//                    UserDefaults.standard.synchronize()
                    
                    let settingsManager = SettingsManager()
                    settingsManager.setLoggedIn(value: false)
                    
                    let account = UIStoryboard(name: "Account", bundle: nil)
                    let vc = account.instantiateInitialViewController()
                    
                    let window = UIApplication.shared.keyWindow!
                    
                    window.rootViewController = vc
                    window.makeKeyAndVisible()
                })
            }))
            return
        case 4 :
            vc = storyboard?.instantiateViewController(withIdentifier: "messagesViewControllerSideMenu")
            break
        default:
            return
        }
        
        mainViewController.replaceViewController(vc!)
        mainViewController.dismiss(animated: true, completion: nil)
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return itemNames.count
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! SideMenuCell
        
        cell.imageViewIcon.image = UIImage(named: itemImages[indexPath.row])
        cell.labelName.text = LocalizationSystem.sharedInstance.localizedStringForKey(key: itemNames[indexPath.row], comment: "")
        
        if indexPath.row == itemNames.count - 1 {
            
            cell.labelName.textColor = UIColor.pink
        } else {
            
            cell.labelName.textColor = UIColor.black
        }

        return cell
    }
    
    func onPreExecute(action: AccountSession.ActionType) {
    }
    
    func onPostExecute(status: BaseUrlSession.Status, action: AccountSession.ActionType, response: Any!) {
        if status.success {
            
            let coupon = response as! Coupon
            
            let vc = UIActivityViewController(activityItems: Constants.getApplicationLink(coupon: coupon), applicationActivities: nil)
            self.present(vc, animated: true, completion: nil)
        } else {
            
            Toast.showAlert(viewController: self, text: status.message)
        }
    }

}

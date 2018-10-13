//
//  SideMenuController.swift
//  kora
//
//  Created by Abanoub Osama on 3/13/18.
//  Copyright © 2018 Abanoub Osama. All rights reserved.
//

import Foundation
import SideMenu
import Firebase

class MainViewController: UIViewController, ContentDelegate {
    
    var content: ContentSession!
    var sideMenu: UISideMenuNavigationController!
    
    @IBOutlet weak var containerView: UIView!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        sideMenu = storyboard!.instantiateViewController(withIdentifier: "MenuNavigationController") as? UISideMenuNavigationController
        
        let sideMenuTableViewController = sideMenu.viewControllers[0] as! SideMenuTableViewController
        sideMenuTableViewController.mainViewController = self
        
        if LocalizationSystem.sharedInstance.getLanguage() == "ar" {
            SideMenuManager.default.menuLeftNavigationController = nil
            SideMenuManager.default.menuRightNavigationController = sideMenu
            
        } else {
            SideMenuManager.default.menuRightNavigationController = nil
            SideMenuManager.default.menuLeftNavigationController = sideMenu
        }
        
        SideMenuManager.default.menuAddPanGestureToPresent(toView: self.navigationController!.navigationBar)
        SideMenuManager.default.menuAddScreenEdgePanGesturesToPresent(toView: self.navigationController!.view)
        
        SideMenuManager.default.menuPresentMode = .menuSlideIn
        SideMenuManager.default.menuShadowColor = .black
        SideMenuManager.default.menuFadeStatusBar = false
        SideMenuManager.default.menuAnimationFadeStrength = 0.7
        
        let vc = storyboard?.instantiateViewController(withIdentifier: "BookAppointmentViewController")
        replaceViewController(vc!)

        content = ContentSession(delegate: self)
        
        if let token = Messaging.messaging().fcmToken {
            content.updateUser(fcmToken: token)
        } else {
            content.updateUser(fcmToken: "")
        }
        
    }

    override func viewDidAppear(_ animated: Bool) {

//        let settingsManager = SettingsManager()
//        if settingsManager.isLoggedIn() {
//
//            super.viewDidAppear(animated)
//        } else {
//
//            let main = UIStoryboard(name: "Account", bundle: nil)
//            let vc = main.instantiateInitialViewController()
//
//            let window = UIApplication.shared.keyWindow!
//
//            window.rootViewController = vc
//            window.makeKeyAndVisible()
//        }
        
        let settingsManager = SettingsManager()
        if settingsManager.isLoggedIn() {

            super.viewDidAppear(animated)
        } else {

            if Constants.override {

                // settingsManager.setUserId(value: 880)
                settingsManager.setUserId(value: 1)
            } else {

                let main = UIStoryboard(name: "Account", bundle: nil)
                let vc = main.instantiateInitialViewController()

                let window = UIApplication.shared.keyWindow!

                window.rootViewController = vc
                window.makeKeyAndVisible()
            }
        }

    }
    
    @IBAction func toggleSideMenu(_ sender: UIBarButtonItem) {

        let isMenuShown = !sideMenu!.isHidden
        if isMenuShown {

            dismiss(animated: true, completion: nil)
        } else {

            if LocalizationSystem.sharedInstance.getLanguage() == "ar" {
                
                present(SideMenuManager.default.menuRightNavigationController!, animated: true, completion: nil)
            } else {
                
                present(SideMenuManager.default.menuLeftNavigationController!, animated: true, completion: nil)
            }
        }
    }
    
    public func replaceViewController(_ vc: UIViewController) {
        
        if let view = containerView.subviews.last {
            view.removeFromSuperview()
        }
        
        if let viewController = childViewControllers.last {
            
            viewController.removeFromParentViewController()
        }
        
        self.addChildViewController(vc)
        
        containerView.addSubview(vc.view)
        containerView.bringSubview(toFront: vc.view)
        vc.view.frame = CGRect(x: 0, y: 0, width: containerView.frame.width, height: containerView.frame.height)
    }

    func onPreExecute(action: ContentSession.ActionType) {
    }

    func onPostExecute(status: BaseUrlSession.Status, action: ContentSession.ActionType, response: Any!) {
        content = nil
    }
    
}


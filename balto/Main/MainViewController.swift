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

fileprivate let nib_identifier = "toOnlineCosultingViewControllerSegue"

class MainViewController: UIViewController, ContentDelegate {
    
    var content: ContentSession!
    var sideMenu: UISideMenuNavigationController!
    
    @IBOutlet weak var containerView: UIView!
    
    
    private var loadingView: LoadingView!
    
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
        
        loadingView = LoadingView(frame: view.frame)
        loadingView.setLoadingImage(image: UIImage(named: "loading")!)
        loadingView.backgroundColor = UIColor.white.withAlphaComponent(0.8)
        loadingView.isHidden = true
        self.view.addSubview(loadingView)
        
        
        // listen
        NotificationCenter.default.addObserver(self, selector: #selector(self.reloadReservation), name: Notification.Name("reloadReservation"), object: nil)
       
    }
    
    @objc func reloadReservation() {
        let first  = self.navigationController?.viewControllers.first
        self.navigationController?.popToRootViewController(animated: false)
        
        if let main = first as? MainViewController {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let vc = storyboard.instantiateViewController(withIdentifier: "ReservationsViewController")
            vc.automaticallyAdjustsScrollViewInsets = true 
            self.loadingView.setIsLoading(false)
            main.replaceViewController(vc)
        }
        
    }

    override func viewDidAppear(_ animated: Bool) {

        let settingsManager = SettingsManager()
        if settingsManager.isLoggedIn() {

            super.viewDidAppear(animated)
        } else {

            let main = UIStoryboard(name: "Account", bundle: nil)
            let vc = main.instantiateInitialViewController()

            let window = UIApplication.shared.keyWindow!

            window.rootViewController = vc
            window.makeKeyAndVisible()
        }
        
//        let settingsManager = SettingsManager()
//        if settingsManager.isLoggedIn() {
//
//            super.viewDidAppear(animated)
//        } else {
//
//            if Constants.override {
//
//                // settingsManager.setUserId(value: 880)
//                settingsManager.setUserId(value: 1)
//            } else {
//
//                let main = UIStoryboard(name: "Account", bundle: nil)
//                let vc = main.instantiateInitialViewController()
//
//                let window = UIApplication.shared.keyWindow!
//
//                window.rootViewController = vc
//                window.makeKeyAndVisible()
//            }
//        }
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(true)
        navigationController?.setNavigationBarHidden(false, animated: animated)
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
    
    @IBAction func changeLanguage(_ sender: UIBarButtonItem) {
        
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
   
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == nib_identifier {
            if let dest = segue.destination as? OnlineConsultingViewController {
                dest.forChat = true
            }
        }
    }
    
}




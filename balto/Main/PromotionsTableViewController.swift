//
//  PlayersTableViewController.swift
//  kora
//
//  Created by Abanoub Osama on 3/20/18.
//  Copyright © 2018 Abanoub Osama. All rights reserved.
//

import UIKit
import XLPagerTabStrip

class PromotionsTableViewController: UITableViewController, ContentDelegate, AccountDelegate {
    
    private var loadingView: LoadingView!
    
    private var content: ContentSession!
    private var account: AccountSession!
    
    private var coupons = [Coupon]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.clipsToBounds = true
        
        tableView.register(UINib(nibName: "PromotionTableCell", bundle: nil), forCellReuseIdentifier: "cell")
        tableView.estimatedRowHeight = 220
        tableView.rowHeight = UITableViewAutomaticDimension
        
        tableView.separatorStyle = .none
        
        tableView.tableFooterView = UIView()
        
        tableView.backgroundColor = UIColor.offWhite
        
        loadingView = LoadingView(frame: view.frame)
        loadingView.setLoadingImage(image: UIImage(named: "loading")!)
        loadingView.backgroundColor = UIColor.white.withAlphaComponent(0.8)
        loadingView.isHidden = true
        self.view.addSubview(loadingView)
        
        // replace with get promocodes
        
        content = ContentSession(delegate: self)
        account = AccountSession(delegate: self)
        
        content.getCoupons()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.navigationController?.navigationBar.topItem?.title = LocalizationSystem.sharedInstance.localizedStringForKey(key: "promotions", comment: "")
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.navigationBar.topItem?.title = ""
    }
    
    func showNoPromotionsAlert() {
        
        Toast.showAlert(viewController: self, text: LocalizationSystem.sharedInstance.localizedStringForKey(key: "noPromo", comment: ""), style: .alert, actionColors: [UIColor.pink, UIColor.green], UIAlertAction(title: LocalizationSystem.sharedInstance.localizedStringForKey(key: "cancel", comment: ""), style: .cancel, handler: { (action) in
            
            let first  = self.navigationController?.viewControllers.first
            self.navigationController?.popToRootViewController(animated: false)
            
            if let main = first as? MainViewController {
                
                DispatchQueue.main.async {
                    
                    let storyboard = UIStoryboard(name: "Main", bundle: nil)
                    let vc = storyboard.instantiateViewController(withIdentifier: "BookAppointmentViewController")
                    
                    main.replaceViewController(vc)
                }
            }
        }), UIAlertAction(title: LocalizationSystem.sharedInstance.localizedStringForKey(key: "share", comment: ""), style: .default, handler: { (action) in
            
            self.shareApplication()
        }))
    }
    
    func shareApplication() {
        
        let settingsManager = SettingsManager()
        
        account.addCoupon(userId: settingsManager.getUserId())
    }
    
    // start of tableView's datasource and delegate
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return coupons.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! PromotionTableCell
        
        cell.setDetails(coupon: coupons[indexPath.row])
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
    // end of tableView's datasource and delegate
    
    // start of contentSession's delegate
    func onPreExecute(action: ContentSession.ActionType) {
        loadingView.setIsLoading(true)
    }
    
    func onPostExecute(status: BaseUrlSession.Status, action: ContentSession.ActionType, response: Any!) {
        loadingView.setIsLoading(false)
        if status.success {
            
            self.coupons = response as! [Coupon]
            
            if coupons.isEmpty {
                
                showNoPromotionsAlert()
            } else {
                
                tableView.reloadData()
            }
        } else {
            
            Toast.showAlert(viewController: self, text: status.message)
        }
    }
    // end of contentSession's delegate
    func onPreExecute(action: AccountSession.ActionType) {
        loadingView.setIsLoading(true)
    }
    
    func onPostExecute(status: BaseUrlSession.Status, action: AccountSession.ActionType, response: Any!) {
        loadingView.setIsLoading(false)
        if status.success {
            
            let coupon = response as! Coupon
            
            let vc = UIActivityViewController(activityItems: Constants.getApplicationLink(coupon: coupon), applicationActivities: nil)
            self.present(vc, animated: true, completion: nil)
        } else {
            
            Toast.showAlert(viewController: self, text: status.message)
        }
    }
}

//
//  TransactionsViewController.swift
//  Doctor ElBalto
//
//  Created by mac on 9/22/18.
//  Copyright © 2018 Abanoub Osama. All rights reserved.
//

import UIKit
import SwiftyJSON
import Alamofire

class TransactionsViewController: UIViewController {

    @IBOutlet weak var transactionCount: UILabel!
    @IBOutlet weak var add_cart_button: UIButton!
    @IBOutlet weak var totalAmount: UILabel!
    @IBOutlet weak var totalOutstanding: UILabel!
    @IBOutlet weak var ourTableView: UITableView!
    
    let transactionsIdentifer: String = "transactionTableViewCell"
    let tranactionsNibName: String = "transactionTableViewCell"
    var transactions: [TransactionsModel] = Array()
    private var loadingView: LoadingView!
    var mainViewController : MainViewController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        ourTableView.register(UINib.init(nibName: tranactionsNibName, bundle: nil), forCellReuseIdentifier: transactionsIdentifer)
        
        ourTableView.tableFooterView = UIView()
        ourTableView.estimatedRowHeight = 70.0
        ourTableView.rowHeight = 70.0
        ourTableView.contentInset = .zero
        ourTableView.separatorInset = .zero
        
        loadingView = LoadingView(frame: view.frame)
        loadingView.setLoadingImage(image: UIImage(named: "loading")!)
        loadingView.backgroundColor = UIColor.white.withAlphaComponent(0.8)
        loadingView.isHidden = true
        self.view.addSubview(loadingView)
        
        // get doctorId
        let doctorId = SettingsManager().getUserId()
        requestDoctorPayments(doctorId: doctorId)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if !NetworkReachabilityManager()!.isReachable {
            let msg = LocalizationSystem.sharedInstance.localizedStringForKey(key: "FailToConnected", comment: "")
            Toast.showAlert(viewController: self, text: msg)
        }
        
        self.navigationController?.navigationBar.topItem?.title = LocalizationSystem.sharedInstance.localizedStringForKey(key: "wallet", comment: "")
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.navigationBar.topItem?.title = ""
    }
    

    func requestDoctorPayments(doctorId: Int) {
        loadingView.setIsLoading(true)
        let lang = LocalizationSystem.sharedInstance.getLanguage()
        
        DoctorsAPIS.getDoctorPayments(lang: lang, doctorId: doctorId) { (data, error) in
            if error != nil {
                print("error")
                self.loadingView.setIsLoading(false)
            }else {
                let json = JSON(data!)
                if json["status"] == "1" {
                    if let trans = json["data"].array {
                        trans.forEach({ (value) in
                            if let value = value.dictionary {
                                let transaction = TransactionsModel()
                                transaction.state = value["state"]?.string ?? ""
                                transaction.amount = value["amount"]?.double ?? 0.0
                                transaction.paymentWay = value["paymentName"]?.string ?? ""
                                transaction.created_at = value["created_at"]?.string ?? ""
                                self.transactions.append(transaction)
                            }
                        })
                        self.totalAmount.text = "\(LocalizationSystem.sharedInstance.localizedStringForKey(key: "Amount", comment: "")) \(json["Amount"].double ?? 0.0) \(LocalizationSystem.sharedInstance.localizedStringForKey(key: "egp", comment: ""))"
                        self.transactionCount.text = "\(LocalizationSystem.sharedInstance.localizedStringForKey(key: "transactionNumber", comment: "")) \(self.transactions.count)"
                        self.totalOutstanding.text = "\(LocalizationSystem.sharedInstance.localizedStringForKey(key: "TotalOutstanding", comment: "")) \(json["TotalOutstanding"].double ?? 0.0) \(LocalizationSystem.sharedInstance.localizedStringForKey(key: "egp", comment: ""))"
                        
                        self.ourTableView.reloadData()
                    }
                }
                self.loadingView.setIsLoading(false)
            }
        }
    }
    
    @IBAction func openPayment(_ sender: UIButton) {
        if let vc = storyboard?.instantiateViewController(withIdentifier:  "PaymentViewController") as? PaymentViewController  {
//            self.present(vc, animated: true, completion: nil)
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
}

//MARK:- UITableViewDataSource
extension TransactionsViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return transactions.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: transactionsIdentifer, for: indexPath)
        as! transactionTableViewCell
        
        let num = indexPath.row
        cell.configCell(params: transactions[num])
        
        return cell
    }
    
}









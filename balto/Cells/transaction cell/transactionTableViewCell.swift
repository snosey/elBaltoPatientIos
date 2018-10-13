//
//  transactionTableViewCell.swift
//  Doctor ElBalto
//
//  Created by mac on 9/23/18.
//  Copyright © 2018 Abanoub Osama. All rights reserved.
//

import UIKit

class transactionTableViewCell: UITableViewCell {

    @IBOutlet weak var totalMoney: UILabel!
    @IBOutlet weak var state: UILabel!
    @IBOutlet weak var paymentWay: UILabel!
    @IBOutlet weak var created_at: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    func configCell(params: TransactionsModel) {

        self.totalMoney.text = "\(LocalizationSystem.sharedInstance.localizedStringForKey(key: "Amount", comment: ""))\(params.amount) \(LocalizationSystem.sharedInstance.localizedStringForKey(key: "egp", comment: ""))"
        self.state.text = "\(LocalizationSystem.sharedInstance.localizedStringForKey(key: "state", comment: "")) \(params.state)"
        self.paymentWay.text = "\(LocalizationSystem.sharedInstance.localizedStringForKey(key: "paymentWay", comment: "")) \(params.paymentWay) "
        self.created_at.text = "\(params.created_at)"
    }
}

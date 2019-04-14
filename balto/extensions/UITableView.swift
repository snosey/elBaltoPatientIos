//
//  UITableView.swift
//  ElBalto
//
//  Created by rocky on 4/10/19.
//  Copyright © 2019 Abanoub Osama. All rights reserved.
//

import UIKit

extension UITableViewCell {
    class var identifier: String {
        return String(describing: self)
    }
}

extension UITableView {
    func register(identifiers: [String]) {
        identifiers.forEach { (identifier) in
            self.register(UINib(nibName: identifier, bundle: nil), forCellReuseIdentifier: identifier)
        }
    }
}

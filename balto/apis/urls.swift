//
//  urls.swift
//  ElBalto
//
//  Created by mac on 9/23/18.
//  Copyright © 2018 Abanoub Osama. All rights reserved.
//

import Foundation

struct APIS_URLS {
    static let doctorPayments: String = "http://haseboty.com/doctor/public/api/selectUserTransaction"
    static let amanPayment   : String = "http://haseboty.com/doctor/public/api/amanPaymentGuide"
    static let walletPayment : String = "http://haseboty.com/doctor/public/api/walletPaymentGuide"
    static let onlinePayment : String = "http://haseboty.com/doctor/public/api/onlinePaymentGuide"
    static let addUserTransaction : String = "http://haseboty.com/doctor/public/api/addTransaction"
    static let updateUserTransaction : String = "http://haseboty.com/doctor/public/api/updateWalletState"
    static let editRateBooking : String = "http://haseboty.com/doctor/public/api/editRateBooking"
    static let deleteRateBooking : String = "http://haseboty.com/doctor/public/api/deleteRateBooking"
    
    static let getMessages : String = "http://haseboty.com/doctor/public/api/getChats"
    static let getMessagesInchat : String = "http://haseboty.com/doctor/public/api/getMessages"
    static let createMessage : String = "http://haseboty.com/doctor/public/api/createMessage"
    static let createChat : String = "http://haseboty.com/doctor/public/api/createChat"
    static let specialization : String = "http://haseboty.com/doctor/public/api/doctorFiltterData"
    
}

//
//  AccountSession.swift
//  kora
//
//  Created by Abanoub Osama on 3/9/18.
//  Copyright © 2018 Abanoub Osama. All rights reserved.
//

import Foundation
import UIKit
import AcceptSDK

public class PaymentSession: BaseUrlSession, AcceptSDKDelegate {
    
    private var delegate: PaymentDelegate!
    
    private var vc: UIViewController!
    private var priceInCents: Int!
    
    private var savedToken: String!
    private var payData: PayResponse!
    
    private var token: String!
    private var paymentToken: String!
    
    private var isChangeCard: Bool = false
    private var isForcedPayment: Bool = false
    
    public enum ActionType {
        case askForAuth, order, paymentKeyRequest, payNowByCard, payNowByToken, presentPaymobViewController, updateUser
    }
    
    init<T: PaymentDelegate>(delegate: T, isForcedPayment: Bool = false)  {
        super.init()
        
        self.delegate = delegate
        self.isForcedPayment = isForcedPayment
    }
    
    public static func getSavedWith(key: String) -> String!  {
        
        let userDefault = UserDefaults.standard
        
        if let savedToken = userDefault.object(forKey: key) as? String {
            return savedToken
        } else {
            return nil
        }
    }
    
    public static func saveWith(key: String, value: String) -> Bool {
        
        let userDefault = UserDefaults.standard
        
        userDefault.set(value, forKey: key)
        
        return userDefault.synchronize()
    }
    
    func handlePayment(vc: UIViewController, priceInCents: Int) {
        self.vc = vc
        self.priceInCents = priceInCents
        
        self.savedToken = PaymentSession.getSavedWith(key: "savedToken")
        
        askForAuth()
    }
    
    func addCard(vc: UIViewController) {
        self.vc = vc
        self.priceInCents = 100
        self.isChangeCard = true
        
        askForAuth()
    }
    
    // first step
    private func askForAuth() {
        
        let actionType = ActionType.askForAuth
        
        let url = URL(string: "https://accept.paymobsolutions.com/api/auth/tokens")!
        
        var body = [String: Any]()
        body["username"] = "Elbalto"
        body["password"] = "Ec0n0mics@88"
        body["expiration"] = "36000"
        
        var header = [String: String]()
        header["Content-Type"] = "application/json"
        header["Accept"] = "application/json"
        
        requestConnectionLegacey(action: actionType, method: "post", url: url, body: body, header: header, shouldCache: false)
    }
    
    // second step
    private func order(token: String, profileId: Int) {
        self.token = token
        
        let actionType = ActionType.order
        
        let url = UrlBuilder(baseUrl: "https://accept.paymobsolutions.com/api/ecommerce/orders?")
            .put("token", token)
        
        var body = [String: Any]()
        body["merchant_id"] = profileId
        body["amount_cents"] = priceInCents
        
        var header = [String: String]()
        header["Content-Type"] = "application/json"
        header["Accept"] = "application/json"
        
        requestConnectionLegacey(action: actionType, method: "post", url: url.build(), body: body, header: header, shouldCache: false)
    }
    
    // third step
    private func paymentKeyRequest(orderId: Int, token: String) {
        
        let actionType = ActionType.paymentKeyRequest
        
        let url = UrlBuilder(baseUrl: "https://accept.paymobsolutions.com/api/acceptance/payment_keys?")
            .put("token", token)
        
        var body = [String: Any]()
        body["order_id"] = orderId
        body["expiration"] = "36000"
        body["currency"] = "EGP"
        body["amount_cents"] = priceInCents
        
        if let token = savedToken {
            
            body["token"] = token
            
            if Constants.override {
                body["integration_id"] = "241"// sand box
            } else {
                body["integration_id"] = "1428"// live
            }
        } else {
            
            if Constants.override {
                body["integration_id"] = "925"// sand box
            } else {
                body["integration_id"] = "725"// live
            }
        }
        
        var header = [String: String]()
        header["Content-Type"] = "application/json"
        header["Accept"] = "application/json"
        
        requestConnectionLegacey(action: actionType, method: "post", url: url.build(), body: body, header: header, shouldCache: false)
    }
    
    // fourth step if there is a token
    private func payNow(savedToken: String, paymentToken: String) {
        
        let actionType = ActionType.payNowByToken
        
        let url = URL(string: "https://accept.paymobsolutions.com/api/acceptance/payments/pay")!
        
        var body = [String: Any]()
        
        var source = [String: Any]()
        
        source["identifier"] = savedToken
        source["subtype"] = "TOKEN"
        source["cvn"] = "123"
        
        var billing = [String: Any]()
        billing["first_name"] = "NA"
        billing["last_name"] = "NA"
        billing["street"] = "NA"
        billing["building"] = "NA"
        billing["floor"] = "NA"
        billing["apartment"] = "NA"
        billing["city"] = "NA"
        billing["state"] = "NA"
        billing["country"] = "NA"
        billing["email"] = "NA"
        billing["phone_number"] = "NA"
        billing["postal_code"] = "NA"
        
        body["source"] = source
        body["billing"] = billing
        body["payment_token"] = paymentToken
        
        var header = [String: String]()
        header["Content-Type"] = "application/json"
        header["Accept"] = "application/json"
        
        requestConnectionLegacey(action: actionType, method: "post", url: url, body: body, header: header, shouldCache: false)
    }
    
    // fourth step if there is no token
    private func presentPaymobViewController() {
        
        let accept = AcceptSDK()
        accept.delegate = self
        
        var billing = [String: String]()
        billing["first_name"] = "NA"
        billing["last_name"] = "NA"
        billing["street"] = "NA"
        billing["building"] = "NA"
        billing["floor"] = "NA"
        billing["apartment"] = "NA"
        billing["city"] = "NA"
        billing["state"] = "NA"
        billing["country"] = "NA"
        billing["email"] = "NA"
        billing["phone_number"] = "NA"
        billing["postal_code"] = "NA"
        
        do {
            try accept.presentPayVC(vC: vc, billingData: billing, paymentKey: paymentToken ?? "", saveCardDefault: true, showSaveCard: false, showAlerts: true)
        } catch {
            Toast.showAlert(viewController: vc, text: error.localizedDescription)
        }
    }
    
    private func updateUser(savedCardData: SaveCardResponse) {
        
        let actionType = ActionType.updateUser
        
        let url = UrlBuilder(baseUrl: "http://haseboty.com/doctor/public/api/updateUser?")
        
        let userId = SettingsManager().getUserId()
        
        url.put("id", userId)
            .put("payment_token", savedCardData.token)
            .put("card_number", savedCardData.masked_pan)
            .put("card_type", savedCardData.card_subtype)
        
        requestConnection(action: actionType, url: url.build(), shouldCache: false)
    }
    
    public func userDidCancel() {
        
        delegate.onPostExecute(status: Status(301, false, NSLocalizedString("userDidCancel", comment: "")), action: PaymentSession.ActionType.presentPaymobViewController, response: nil)
    }
    
    public func paymentAttemptFailed(_ error: AcceptSDKError, detailedDescription: String) {
        
        delegate.onPostExecute(status: Status(301, false, NSLocalizedString("paymentAttemptFailed", comment: "").replacingOccurrences(of: "*X*", with: payData.dataMessage)), action: PaymentSession.ActionType.presentPaymobViewController, response: nil)
    }
    
    public func transactionRejected(_ payData: PayResponse) {
        
        delegate.onPostExecute(status: Status(301, false, NSLocalizedString("transactionRejected", comment: "").replacingOccurrences(of: "*X*", with: payData.dataMessage)), action: PaymentSession.ActionType.presentPaymobViewController, response: nil)
    }
    
    public func transactionAccepted(_ payData: PayResponse) {
        
        if let _ = paymentToken {
            
            delegate.onPostExecute(status: Status(200, payData.success, ""), action: .payNowByCard, response: payData.id)
        } else {
            
            delegate.onPostExecute(status: Status(200, true, ""), action: PaymentSession.ActionType.presentPaymobViewController, response: nil)
        }
    }
    
    public func transactionAccepted(_ payData: PayResponse, savedCardData: SaveCardResponse) {
        
        savedToken = savedCardData.token
        
        let _ = PaymentSession.saveWith(key: "savedToken", value: savedCardData.token)
        let _ = PaymentSession.saveWith(key: "masked_pan", value: savedCardData.masked_pan)
        let _ = PaymentSession.saveWith(key: "card_subtype", value: savedCardData.card_subtype)
        
        updateUser(savedCardData: savedCardData)
        
        if let _ = paymentToken {
            
            delegate.onPostExecute(status: Status(200, true, ""), action: .payNowByCard, response: payData.id)
        } else {
            
            delegate.onPostExecute(status: Status(200, true, ""), action: PaymentSession.ActionType.presentPaymobViewController, response: nil)
        }
    }
    
    public func userDidCancel3dSecurePayment(_ pendingPayData: PayResponse) {
        
        delegate.onPostExecute(status: Status(301, false, NSLocalizedString("userDidCancel", comment: "")), action: PaymentSession.ActionType.presentPaymobViewController, response: nil)
    }
    
    override func onPreExecute(action: Any) {
        
        if let delegate = delegate as? ContentDelegate {
            
            delegate.onPreExecute(action: ContentSession.ActionType.PaymentSession)
        }
    }
    
    func onPreExecute(action: ActionType) {
        
        if let delegate = delegate as? ContentDelegate {
            
            delegate.onPreExecute(action: ContentSession.ActionType.PaymentSession)
        }
    }
    
    override func onSuccess(action: Any, response: URLResponse!, data: Data!) {
        let actionType: ActionType = action as! PaymentSession.ActionType
        do {
            let res = String(data: data, encoding: .ascii)
            print(res ?? "")
            var jsonResponse = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String: Any] ?? [String: Any]()
            
            let success = jsonResponse["status"] as? Bool ?? true
            
            if success {
                switch actionType {
                case .askForAuth:
                    
                    let token = jsonResponse["token"] as! String
                    let profile = jsonResponse["profile"] as! [String: Any]
                    let id = profile["id"] as! Int
                    
                    order(token: token, profileId: id)
                    break
                case .order:
                    
                    let id = jsonResponse["id"] as! Int
                    
                    paymentKeyRequest(orderId: id, token: self.token)
                    break
                case .paymentKeyRequest:
                    
                    self.paymentToken = jsonResponse["token"] as! String
                    
                    if let savedToken = savedToken, !isChangeCard {
                        
                        if isForcedPayment {
                            
                            self.payNow(savedToken: savedToken, paymentToken: self.paymentToken)
                        } else {
                            
                            Toast.showAlert(viewController: vc, text: NSLocalizedString("use_saved_card", comment: ""), style: .alert, actionColors: [UIColor.pink, UIColor.green],  UIAlertAction(title: NSLocalizedString("change", comment: ""), style: .default, handler: { (action) in
                                
                                self.presentPaymobViewController()
                            }), UIAlertAction(title: NSLocalizedString("Use", comment: ""), style: .cancel, handler: { (action) in
                                
                                self.payNow(savedToken: savedToken, paymentToken: self.paymentToken)
                            }))
                        }
                    } else {
                        
                        presentPaymobViewController()
                    }
                    break
                case .payNowByToken:
                    
                    let id = jsonResponse["id"] as? Int
                    
                    delegate.onPostExecute(status: Status(200, id != nil, res ?? ""), action: actionType, response: id)
                    break
                case .updateUser:
                    break
                default:
                    delegate.onPostExecute(status: Status(200, true, ""), action: actionType, response: nil)
                    break
                }
            } else {
                let code = jsonResponse["error_code"] as? Int ?? -1
                var codeMessage = "..."
                
                if let message = jsonResponse["messages"] as? [String: Any],
                    let messages = message[message.keys.first!] as? [String] {
                    
                    codeMessage = messages[0]
                } else if let message = jsonResponse["messages"] as? String {
                    
                    codeMessage = message
                }
                onFailure(action: actionType, error: NSError(domain: codeMessage, code: code, userInfo: nil))
            }
        } catch {
            onFailure(action: actionType, error: error as NSError)
        }
    }
    
    override func onFailure(action: Any, error: NSError) {
        delegate.onPostExecute(status: Status(error: error), action: action as! PaymentSession.ActionType, response: nil)
    }
}

public protocol PaymentDelegate {
    
    func onPostExecute(status: BaseUrlSession.Status, action: PaymentSession.ActionType, response: Any!)
}


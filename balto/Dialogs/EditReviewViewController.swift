//
//  WarningViewController.swift
//  Tabeeb
//
//  Created by Abanoub Osama on 8/15/17.
//  Copyright © 2017 Abanoub Osama. All rights reserved.
//

import UIKit
import Cosmos

class EditReviewViewController: UIViewController, ContentDelegate, UIPickerViewDelegate {
    
    @IBOutlet weak var cosmosViewRate: CosmosView!
    @IBOutlet weak var textViewReview: UITextField!
    
    @IBOutlet weak var viewBack: UIView!
    
    @IBOutlet weak var scrollView: UIScrollView!
    
    @IBOutlet weak var loadingView: LoadingView!
    
    private var content: ContentSession!
    
    private var bookingId: Int!
    
    private var reservation: Reservation!
    
    private var afterAction: ((_ vc: UIViewController) -> Bool)!
    
    init(bookingId: Int, afterAction: ((_ vc: UIViewController) -> Bool)! = nil) {
        super.init(nibName: "EditReviewViewController", bundle: nil)
        self.modalPresentationStyle = UIModalPresentationStyle.overCurrentContext
        self.bookingId = bookingId
        self.afterAction = afterAction
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadingView.setLoadingImage(image: UIImage(named: "loading")!)
        loadingView.backgroundColor = UIColor.white.withAlphaComponent(0.8)
        loadingView.isHidden = true
        
        content = ContentSession(delegate: self)
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismiss(_:)))
        tap.cancelsTouchesInView = true
        view.addGestureRecognizer(tap)
        
        let tap2:  UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismisssKeyboard))
        tap2.cancelsTouchesInView = true
        viewBack.addGestureRecognizer(tap2)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name:NSNotification.Name.UIKeyboardWillShow, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name:NSNotification.Name.UIKeyboardWillHide, object: nil)
        
        content.bookingData(bookingId: bookingId)
    }
    
  
    
    @objc func dismiss(_ ite: Any) {
        
        self.dismiss(animated: true, completion: nil)
    }
    
    func onPreExecute(action: ContentSession.ActionType) {
        
        loadingView.setIsLoading(true)
    }
    
    func onPostExecute(status: BaseUrlSession.Status, action:
        ContentSession.ActionType, response: Any!) {
        
        loadingView.setIsLoading(false)
        
        if status.success {
            
            switch action {
            case .addPayment:
                break
            case .getBookingData:
                
                self.reservation = response as! Reservation
                
                break
            case .rateBooking:
                
                if let reservation = reservation, reservation.stateId < 5 {
                    
                    content.updateBooking(with: bookingId, toState: 5)
                } else {
                    
                    fallthrough
                }
                break
            default:
                
                if let action = afterAction {
                    
                    if !action(self) {
                        
                        self.dismiss(animated: true, completion: nil)
                    }
                } else {
                    
                    self.dismiss(animated: true, completion: nil)
                }
                break
            }
        } else {
            Toast.showAlert(viewController: self, text: status.message)
        }
    }
    
    @objc func dismisssKeyboard() {
        view.endEditing(true)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.cosmosViewRate.rating = Double(ReservationTableCell.rate!)
        self.textViewReview.text = ReservationTableCell.review
    }
    
    @objc func keyboardWillShow(notification:NSNotification) {
        //give room at the bottom of the scroll view, so it doesn't cover up anything the user needs to tap
        var userInfo = notification.userInfo!
        var keyboardFrame:CGRect = (userInfo[UIKeyboardFrameBeginUserInfoKey] as! NSValue).cgRectValue
        keyboardFrame = self.view.convert(keyboardFrame, from: nil)
        
        var contentInset:UIEdgeInsets = self.scrollView.contentInset
        contentInset.bottom = keyboardFrame.size.height / 2
        self.scrollView.contentInset = contentInset
        self.scrollView.contentOffset = CGPoint(x: 0, y: keyboardFrame.size.height / 2)
    }
    
    @objc func keyboardWillHide(notification:NSNotification) {
        let contentInset:UIEdgeInsets = UIEdgeInsets.zero
        self.scrollView.contentInset = contentInset
    }
    
    
    @IBAction func deleteClicked(_ sender: UIButton) {
        
        loadingView.setIsLoading(true)
        let params = [
            "id": reservation.id_rate as! Int,
        ] as [String: Any]
        
        RateBookingAPI.deleteRateBooking(params: params) { (response, error) in
            if error != nil {
                print("Error");
                self.loadingView.setIsLoading(false)
                return
            }else {
                self.dismiss(animated: true, completion: {
                    self.loadingView.setIsLoading(false)
                    NotificationCenter.default.post(name: .pastReservation, object: self)
                })
            }
        }
    }
    
    @IBAction func editClicked(_ sender: UIButton) {
        loadingView.setIsLoading(true)
        print(reservation.id_rate)
        
        let params = [
            "id": reservation.id_rate as! Int,
            "review": textViewReview.text ?? "",
            "rate": Int(cosmosViewRate.rating),
        ] as [String: Any]
        
        RateBookingAPI.editRateBooking(params: params) { (response, error) in
            if error != nil {
                print("Error");
                self.loadingView.setIsLoading(false)
                return
            }else {
                self.dismiss(animated: true, completion: {
                    self.loadingView.setIsLoading(false)
                    NotificationCenter.default.post(name: .pastReservation, object: self)
                })
            }
        }

    }
    
}




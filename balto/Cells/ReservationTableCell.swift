//
//  ScheduleTableCell.swift
//  balto
//
//  Created by Abanoub Osama on 4/3/18.
//  Copyright © 2018 Abanoub Osama. All rights reserved.
//

import UIKit
import SDWebImage

class ReservationTableCell: UITableViewCell {
    
    @IBOutlet weak var imageViewProfile: UIImageView!
    
    @IBOutlet weak var labelName: UILabel!
    @IBOutlet weak var labelSpecialization: UILabel!
    @IBOutlet weak var labelDate: UILabel!
    @IBOutlet weak var labelPrice: UILabel!
    @IBOutlet weak var labelRate: UILabel!
    
    @IBOutlet weak var buttonCall: UIButton!
    // default cancel
    @IBOutlet weak var buttonAction1: UIButton!
    // default med report
    @IBOutlet weak var buttonAction2: UIButton!
    // default hidden
    @IBOutlet weak var buttonAction3: UIButton!
    
    @IBOutlet weak var labelType: UILabel!
    
    var vc: UIViewController!
    var reservation: Reservation!
    
    var isOnlineConsulting = true
    var isUpcoming: Bool = true
    
    var parentViewController:UIViewController!
    
    private var canRate: Bool!
    
    
    static var rate: Int? = nil
    static var review: String? = nil
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        buttonCall.imageView?.contentMode = .scaleAspectFit
    }
    
    @IBAction func buttonAction(_ sender: UIButton) {
    
        if sender === buttonCall {
            
            if isOnlineConsulting {
                
                let startDate = DateUtils.getDate(dateString: reservation.date, dateFormat: "\(DateUtils.SERVER_DATE_FORMAT) \(DateUtils.SERVER_TIME_SHORT_FORMAT)")
                let serviceDuration = reservation.serviceDuration!
                let endDate = startDate.addingTimeInterval(TimeInterval(serviceDuration * 60))
                // ask Eng: ElSnosey first if he wanna remove this first (this's useless)
               let mins = reservation.orignalDate.timeIntervalSinceNow / 60
                
                if mins > 0 {
                    
                    Toast.showAlert(viewController: vc, text: LocalizationSystem.sharedInstance.localizedStringForKey(key: "waitToBookTime", comment: ""))
                    
                } else {
                    
                    if Constants.override || reservation.stateId >= 3 {
                        
                        if Constants.override || endDate > Date() {
                            
                            let videoViewController = VideoChatViewController.getInstance(reservation: reservation)
                            
                            if let content = getContentSesion() {
                                content.updateBooking(with: self.reservation, toState: 4)
                                vc.show(videoViewController, sender: nil)
                            }
                            
                        } else {
                            Toast.showAlert(viewController: vc, text: LocalizationSystem.sharedInstance.localizedStringForKey(key: "wrongAppoinment", comment: ""))
                        }
                    } else {
                        // doctor's didn't come yet but time has been started
                        if let content = getContentSesion() {
                            if endDate <= Date() {
                                // TODO: //CHECK IF TIME ENDED
                                content.updateBooking(with: self.reservation, toState: 9)
                                
                                if let wallet_id = self.reservation.wallet_id, wallet_id != 0 {
                                    
                                    let params = [
                                        "id": wallet_id,
                                        "state": 6,
                                    ] as [String : Any]
                                    DoctorsAPIS.updateUserTransaction(params: params, completion: { (success, error) in
                                    })
                                }
                                
                            }
                            Toast.showAlert(viewController: vc, text: LocalizationSystem.sharedInstance.localizedStringForKey(key: "pleaseWaitDoctor", comment: ""))
                        }
                    }
                }
                // HOME VISIT .
            } else {
                let phone = reservation.phone
                if let url = URL(string: "tel://\(phone!)"), UIApplication.shared.canOpenURL(url) {
                    if #available(iOS 10, *) {
                        UIApplication.shared.open(url)
                    } else {
                        UIApplication.shared.openURL(url)
                    }
                }
            }
            
            // Button call ended
        } else if sender === buttonAction1 {
            
            //TODO:// HERE I ADDED SOME CODE
            if isOnlineConsulting {
                
                // cancel
                let mins = reservation.orignalDate.timeIntervalSinceNow / 60
                
                // you can cancel
                if mins > 59 && reservation.stateId <= 3 {
                    
                    if let content = getContentSesion() {
                        
                        Toast.showAlert(viewController: vc, text: LocalizationSystem.sharedInstance.localizedStringForKey(key: "areYouSure", comment: ""), style: .alert, actionColors: [UIColor.green, UIColor.pink], UIAlertAction(title: LocalizationSystem.sharedInstance.localizedStringForKey(key: "cancel", comment: ""), style: .cancel, handler: nil), UIAlertAction(title: LocalizationSystem.sharedInstance.localizedStringForKey(key: "ok", comment: ""), style: .default, handler: { (action) in
                            
                            if let wallet_id = self.reservation.wallet_id as? Int {
                                
                                let params = [
                                    "id": wallet_id,
                                    "state": 6,
                                ] as [String : Any]
                                DoctorsAPIS.updateUserTransaction(params: params, completion: { (success, error) in
                                })
                            }
                            content.updateBooking(with: self.reservation, toState: 6)
                            
                        }))
                    }
                    
                }else if reservation.stateId <= 3 && mins <= 0 {
                    // cannot cancel because of time
                    
                    Toast.showAlert(viewController: vc, text: LocalizationSystem.sharedInstance.localizedStringForKey(key: "doctor is in", comment: ""))
                    
                } else {
                    // cannot cancel because of reservation already started .
                    Toast.showAlert(viewController: vc, text: LocalizationSystem.sharedInstance.localizedStringForKey(key: "cantCancel", comment: ""))
                    
                }
                
                // HOME VISIT NO NEED TO UPDATE OR CHANGE ANYTHING HERE .
                
            } else {
                // check
                if let vc = vc, reservation.stateId >= 3 {
                    
                    vc.show(TrackDoctorViewController.getInstance(doctorId: reservation.idDoctor), sender: self)
                } else {
                    Toast.showAlert(viewController: vc, text: LocalizationSystem.sharedInstance.localizedStringForKey(key: "pleaseWaitDoctor", comment: ""))
                }
            }
            
        } else if sender === buttonAction2 {
            
            if isUpcoming {
                //cancel
                let mins = reservation.orignalDate.timeIntervalSinceNow / 60
                if mins > 59 && reservation.stateId < 3 {
                    
                    if let content = getContentSesion() {
                        
                        Toast.showAlert(viewController: vc, text: LocalizationSystem.sharedInstance.localizedStringForKey(key: "areYouSure", comment: ""), style: .alert, actionColors: [UIColor.green, UIColor.pink], UIAlertAction(title: LocalizationSystem.sharedInstance.localizedStringForKey(key: "cancel", comment: ""), style: .cancel, handler: nil), UIAlertAction(title: LocalizationSystem.sharedInstance.localizedStringForKey(key: "ok", comment: ""), style: .default, handler: { (action) in
                            
                            content.updateBooking(with: self.reservation, toState: 7)
                        }))
                    }
                } else if reservation.stateId < 3 {
                    
                    Toast.showAlert(viewController: vc, text: "Reservation can not be cancelled less than 1 hour in advance")
                    
                } else {
                    
                    Toast.showAlert(viewController: vc, text: LocalizationSystem.sharedInstance.localizedStringForKey(key: "cantCancel", comment: ""))
                }
            } else {
                // med report
                let vc = MedReportViewController.getInstance(reservation: reservation)
                self.vc.show(vc, sender: self)
            }
        } else /*if sender === buttonAction3*/ {
            // done
            let vc = AddReviewViewController(bookingId: reservation.id) { _ in
                
                self.vc.viewDidAppear(true)
                
                return false
            }
            self.vc.present(vc, animated: true, completion: nil)
        }
        
    }
    
    @IBAction func rate(_ sender: UIButton) {
        if canRate {
            
            let vc = AddReviewViewController(bookingId: reservation.id) { _ in
                
                self.vc.viewDidAppear(true)
                
                return false
            }
            self.vc.present(vc, animated: true, completion: nil)
        }else {
            
            if let rate = reservation.rate as? String {
                ReservationTableCell.rate = Int(rate)
            }
            
            if let review = reservation.review as? String {
                ReservationTableCell.review = review
            }
            
            let vc = EditReviewViewController(bookingId: reservation.id) { _ in
                
                self.vc.viewDidAppear(true)
                
                return false
            }
            self.vc.present(vc, animated: true, completion: nil)
            
        }
    }
    
    func setDetails(vc: UIViewController, isUpcoming: Bool, reservation: Reservation) {
        
        self.vc = vc
        self.isUpcoming = isUpcoming
        self.reservation = reservation
        
        if let rate = reservation.rate {
            
            labelRate.text = rate
            labelRate.superview?.isHidden = false
            canRate = false
        } else {
            
            labelRate.text = LocalizationSystem.sharedInstance.localizedStringForKey(key: "addRate", comment: "")
            labelRate.superview?.isHidden = isUpcoming
            canRate = true
        }
        
        self.isOnlineConsulting = reservation.doctorKind.id == 2
        
        if let imagePath = reservation.image, !imagePath.isEmpty {
            
//            imageViewProfile.sd_setImage(with: URL(string: imagePath), completed: nil)
            
            let image = imagePath.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)!
            
            DispatchQueue.main.async {
                self.imageViewProfile.sd_setShowActivityIndicatorView(true)
                self.imageViewProfile.sd_setIndicatorStyle(.gray)
                self.imageViewProfile.sd_setImage(with: URL(string: image), placeholderImage: UIImage(named: "\(image).png"))
            }

            
        } else {
            imageViewProfile.image = UIImage(named: "logo_profile")
        }
        
        if isOnlineConsulting {
            
            setupForOnlineConsulting(isUpcoming: isUpcoming)
        } else {
            
            setupForHomeVisit(isUpcoming: isUpcoming)
        }
        
    }
    
    func setupForHomeVisit(isUpcoming: Bool) {
        
        labelName.text = reservation.name
        labelSpecialization.text = reservation.subCategoryName
        labelDate.text = reservation.date
        labelPrice.text = "\(reservation.price!) EGP"
        
        buttonCall.setImage(UIImage(named: "31_32_phone"), for: .normal)
        buttonCall.tag = 4
        
        if isUpcoming {
            
            buttonAction1.setImage(nil, for: .normal)
            buttonAction1.setTitle(LocalizationSystem.sharedInstance.localizedStringForKey(key: "check", comment: ""), for: .normal)
            buttonAction1.setTitleColor(UIColor.white, for: .normal)
            buttonAction1.setBackgroundImage(UIImage(named: "book_button"), for: .normal)
            buttonAction1.tag = 4
            
            buttonAction2.setImage(nil, for: .normal)
            buttonAction2.setTitle(LocalizationSystem.sharedInstance.localizedStringForKey(key: "cancel", comment: ""), for: .normal)
            buttonAction2.setTitleColor(UIColor.white, for: .normal)
            buttonAction2.setBackgroundImage(UIImage(named: "cancel_button"), for: .normal)
            buttonAction2.tag = 3
        } else {
            
            buttonAction2.setImage(nil, for: .normal)
            buttonAction2.setTitle(LocalizationSystem.sharedInstance.localizedStringForKey(key: "medReport", comment: ""), for: .normal)
            buttonAction2.setTitleColor(UIColor.white, for: .normal)
            buttonAction2.setBackgroundImage(UIImage(named: "book_button"), for: .normal)
            buttonAction2.tag = 6
        }
        
        buttonCall.isHidden = !isUpcoming
        buttonAction1.isHidden = !isUpcoming
        buttonAction2.isHidden = false || reservation.stateId == 9
        buttonAction3.isHidden = true
        
        labelType.text = reservation.doctorKind.name
    }
    
    func setupForOnlineConsulting(isUpcoming: Bool) {
        
        labelName.text = reservation.name
        labelSpecialization.text = reservation.subCategoryName
        labelDate.text = reservation.date
        
        labelPrice.text = "\(reservation.price!) EGP"
        
        buttonAction1.setImage(nil, for: .normal)
        buttonAction1.setTitle(LocalizationSystem.sharedInstance.localizedStringForKey(key: "cancel", comment: ""), for: .normal)
        buttonAction1.setTitleColor(UIColor.white, for: .normal)
        buttonAction1.setBackgroundImage(UIImage(named: "cancel_button"), for: .normal)
        buttonAction1.tag = 3
        
        if reservation.orignalDate > Date() {
            buttonCall.setImage(UIImage(named: "video_call_disabled"), for: .normal)
        }else {
            buttonCall.setImage(UIImage(named: "video_call"), for: .normal)
        }
        
        buttonAction2.setImage(nil, for: .normal)
        buttonAction2.setTitle(LocalizationSystem.sharedInstance.localizedStringForKey(key: "medReport", comment: ""), for: .normal)
        buttonAction2.setTitleColor(UIColor.white, for: .normal)
        buttonAction2.setBackgroundImage(UIImage(named: "book_button"), for: .normal)
        buttonAction2.tag = 6
        
        buttonCall.isHidden = !isUpcoming
        buttonAction1.isHidden = !isUpcoming
        buttonAction2.isHidden = isUpcoming || reservation.stateId == 9
        buttonAction3.isHidden = true
        
        labelType.text = reservation.doctorKind.name
    }
    
    func getContentSesion() -> ContentSession! {
        
        var content: ContentSession!
        
        if let upcoming = vc as? UpcomingReservationsViewController {
            
            content = upcoming.content
        } else if let past = vc as? PastReservationsViewController {
            
            content = past.content
        }
        
        return content
    }
}

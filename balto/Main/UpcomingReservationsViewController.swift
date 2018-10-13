//
//  UpcomingReservationsViewController.swift
//  balto
//
//  Created by Abanoub Osama on 4/3/18.
//  Copyright © 2018 Abanoub Osama. All rights reserved.
//

import UIKit
import XLPagerTabStrip

class UpcomingReservationsViewController: UIViewController, ContentDelegate, PaymentDelegate, UITableViewDataSource, UITableViewDelegate, IndicatorInfoProvider, DatePickerDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var stackViewDays: UIStackView!
    
    private var selectedDayView: UIView!
    
    var buttonDate: UIButton!
    
    var loadingView: LoadingView!
    
    var content: ContentSession!
    var payment: PaymentSession!
    
    var userId: Int!
    
    var date: Date!
    
    var reservations = [Reservation]()
    
    var reservationToUpdate: Reservation!
    
    public class func getInstance(title: String = LocalizationSystem.sharedInstance.localizedStringForKey(key:"coming", comment: "")) -> UpcomingReservationsViewController {
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "UpcomingReservationsViewController") as! UpcomingReservationsViewController
        vc.title = title
        
        return vc
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.dataSource = self
        tableView.delegate = self
        
        tableView.register(UINib(nibName: "ReservationTableCell", bundle: nil), forCellReuseIdentifier: "cell")
        tableView.estimatedRowHeight = 150
        tableView.rowHeight = UITableViewAutomaticDimension
        
        tableView.tableFooterView = UIView()
        
        loadingView = LoadingView(frame: view.frame)
        loadingView.setLoadingImage(image: UIImage(named: "loading")!)
        loadingView.backgroundColor = UIColor.white.withAlphaComponent(0.8)
        loadingView.isHidden = true
        self.view.addSubview(loadingView)
        
        content = ContentSession(delegate: self)
        
        payment = PaymentSession(delegate: self, isForcedPayment: true)
        
        userId = SettingsManager().getUserId()
        
        let calendar = Calendar.current
        let date = Date()
        
        selectedDayView = stackViewDays.arrangedSubviews[0]
        let button = selectedDayView.viewWithTag(1) as! UIButton
        button.setBackgroundImage(UIImage(named: "9_28_circle"), for: .normal)
        button.setTitleColor(UIColor.white, for: .normal)
        
        for i in 0..<stackViewDays.arrangedSubviews.count {
            
            let view = stackViewDays.arrangedSubviews[i]
            
            let daysDate = calendar.date(byAdding: Calendar.Component.day, value: i, to: date)!
            
            let button = view.viewWithTag(1) as! UIButton
            let label = view.viewWithTag(2) as! UILabel
            
            button.addTarget(self, action: #selector(updateDate(_:)), for: UIControlEvents.touchUpInside)
            
            button.setTitle("\(calendar.component(Calendar.Component.day, from: daysDate))", for: .normal)
            label.text = DateFormatter().shortWeekdaySymbols[calendar.component(Calendar.Component.weekday, from: daysDate) - 1]
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        getContent()
    }
    
    func indicatorInfo(for pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
        return IndicatorInfo(title: self.title?.uppercased())
    }
    
    func getContent() {
        
        content.getReservations(userId: userId, state: "coming", type: "client", date: date)
    }
    
    @objc func updateDate(_ sender: UIButton) {
        
        let superView = sender.superview!
        if let index = stackViewDays.arrangedSubviews.index(of: superView) {
            
            if superView !== selectedDayView {
                
                let button = superView.viewWithTag(1) as! UIButton
                button.setBackgroundImage(UIImage(named: "9_28_circle"), for: .normal)
                
                let buttonOld = selectedDayView.viewWithTag(1) as! UIButton
                buttonOld.setBackgroundImage(nil, for: .normal)
                
                selectedDayView = superView
            }
            
            let date = Date().addingTimeInterval(DateUtils.DAY_INTERVAL * TimeInterval(index))
            
            dateDidChange(date: date)
        }
    }
    
    func dateDidChange(date: Date) {
        
        content.getReservations(userId: userId, state: "coming", type: "client", date: date)
    }
    
    @objc func setDate(_ sender: UIButton) {
        
        let vc = DatePickerController.present(self, delegate: self)
        vc.pickerView.datePickerMode = .date
        
        if let date = date {
        
            vc.pickerView.date = date
        }
        
        vc.pickerView.minimumDate = Date()
        
        let maxDate = Calendar.current.date(byAdding: .weekOfYear, value: 1, to: Date())
        vc.pickerView.maximumDate = maxDate
    }
    
    @objc func resetDate(_ sender: UIButton) {
        
        self.date = nil
        
        getContent()
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let view = PastSectionHeaderView.instantiateFromNib(named: "PastSectionHeaderView")
        
        if let date = date {
            
            view.buttonDate.setTitle(DateUtils.getAppDateString(timeInMillis: date.timeIntervalSince1970), for: .normal)
        }
        
        view.buttonDate.addTarget(self, action: #selector(setDate), for: .touchUpInside)
        view.buttonAll.addTarget(self, action: #selector(resetDate), for: .touchUpInside)
        
        self.buttonDate = view.buttonDate
        
        return view
    }
    
    // MARK: - Table view data source
    func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return reservations.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! ReservationTableCell
        cell.parentViewController = self
        cell.setDetails(vc: self, isUpcoming: true, reservation: reservations[indexPath.row])
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "ProfileViewController") as! ProfileViewController
        vc.doctorId = reservations[indexPath.row].idDoctor
        self.show(vc, sender: nil)
    }
    
    func done(picker: DatePickerController, date: Date) -> Bool {
        
        self.date = date
        
        buttonDate.setTitle(DateUtils.getAppDateString(timeInMillis: date.timeIntervalSince1970), for: .normal)
        
        getContent()
        return false
    }
    
    func cancel(picker: DatePickerController) -> Bool {
        return false
    }
    
    func onPreExecute(action: ContentSession.ActionType) {
        loadingView.setIsLoading(true)
    }
    
    func onPostExecute(status: BaseUrlSession.Status, action: ContentSession.ActionType, response: Any!) {
        loadingView.setIsLoading(false)
        if status.success {
            
            switch action {
            case .getReservations:
                var reservations = response as! [Reservation]
                
                var noNeedToUpdate = true
                
                for i in 0..<reservations.count {
                    
                    let reservation = reservations[i]
                    
                    let serviceDuration = reservation.serviceDuration!
                    
                    var endDate = DateUtils.getDate(dateString: reservation.date, dateFormat: "\(DateUtils.SERVER_DATE_FORMAT) \(DateUtils.SERVER_TIME_SHORT_FORMAT)")
                    endDate = endDate.addingTimeInterval(TimeInterval(serviceDuration * 60))
                    
                    var now = Date()
                    
                    if Constants.override {
                    
                      //  now.addTimeInterval(DateUtils.DAY_INTERVAL)
                    }
                    
                    if reservation.stateId > 4 {
                        
                        reservations.remove(at: i)
                    } else if endDate < now {
                        
                        noNeedToUpdate = false
                        
                        if Constants.override {
                        
                           // reservation.stateId = 3
                        }
                        
                        if reservation.stateId < 3 {
                            
                            content.updateBooking(with: reservation, toState: 9)
                        } else {
                            
                            // credit
                            if reservation.paymentMethodId == 2 {
                                
                                reservationToUpdate = reservation
                                
                                if let copounId = reservation.idCouponClient, copounId > 0 {
                                    
                                    self.content.checkCopoun(copounId: copounId)
                                } else {
                                    
                                    self.payment.handlePayment(vc: self, priceInCents: (reservation.price! as NSString).integerValue * 100)
                                }
                                return
                            } else {
                                
                                content.updateBooking(with: reservation, toState: 5)
                            }
                        }
                    } else {
                        
                        if #available(iOS 10.0, *) {
                            NotificationHandler.scheduleNotificationFor(reservation: reservation)
                        }
                    }
                }
                
                if noNeedToUpdate {
                    
                    self.reservations = reservations
                    
                    tableView.reloadData()
                }
                break
            case .checkCoupon:
                
                let c = response as! Coupon
                
                let price = Float((reservationToUpdate.price as NSString).integerValue)
                
                let newPrice = (price - price * c.discount).rounded(.up)
                
                self.payment.handlePayment(vc: self, priceInCents: Int(newPrice * 100))
                break
            case .addPayment:
                break
            default:
                getContent()
                break
            }
        } else {
            Toast.showAlert(viewController: self, text: status.message)
        }
    }
    
    func onPostExecute(status: BaseUrlSession.Status, action: PaymentSession.ActionType, response: Any!) {
        loadingView.setIsLoading(false)
        if status.success {
            
            switch action {
            case .payNowByToken:
                
                let payMobId = response as! Int
                
                content.addPayment(bookingId: reservationToUpdate.id, payMobId: payMobId, typeId: 2, totalMoney: (reservationToUpdate.price as NSString).integerValue, kindId: 2, subId: reservationToUpdate.subId ?? 0, userId: reservationToUpdate.idDoctor)
                
                content.updateBooking(with: reservationToUpdate, toState: 5)
                break
            case .payNowByCard:
                
                let payMobId = response as! Int
                
                content.addPayment(bookingId: reservationToUpdate.id, payMobId: payMobId, typeId: 2, totalMoney: (reservationToUpdate.price as NSString).integerValue, kindId: 2, subId: reservationToUpdate.subId ?? 0, userId: reservationToUpdate.idDoctor)
                
                content.updateBooking(with: reservationToUpdate, toState: 5)
                break
            default:
                break
            }
        } else {
            
            Toast.showAlert(viewController: self, text: status.message)
        }
    }
}

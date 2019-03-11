//
//  PastReservationsViewController.swift
//  balto
//
//  Created by Abanoub Osama on 4/3/18.
//  Copyright © 2018 Abanoub Osama. All rights reserved.
//

import UIKit
import XLPagerTabStrip

class PastReservationsViewController: UITableViewController, ContentDelegate, IndicatorInfoProvider, DatePickerDelegate {
    
    var loadingView: LoadingView!
    
    var buttonDate: UIButton!
    
    var userId: Int!
    
    var content: ContentSession!
    
    var date: Date!
    
    var reservations = [Reservation]()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.register(UINib(nibName: "ReservationTableCell", bundle: nil), forCellReuseIdentifier: "cell")
        tableView.estimatedRowHeight = 150
        tableView.rowHeight = UITableViewAutomaticDimension
        
        tableView.tableFooterView = UIView()
        tableView.separatorStyle = .none
        
        view.backgroundColor = UIColor.offWhite
        
        loadingView = LoadingView(frame: view.frame)
        loadingView.setLoadingImage(image: UIImage(named: "loading")!)
        loadingView.backgroundColor = UIColor.white.withAlphaComponent(0.8)
        loadingView.isHidden = true
        self.view.addSubview(loadingView)
        
        content = ContentSession(delegate: self)
        
        userId = SettingsManager().getUserId()
        
        NotificationCenter.default.addObserver(forName: .pastReservation, object: nil, queue: OperationQueue.main) { (notification) in
            self.viewDidAppear(true)
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        content.getReservations(userId: userId, state: "past", type: "client", date: date)
    }
    
    func indicatorInfo(for pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
        return IndicatorInfo(title: self.title?.uppercased())
    }
    
    @objc func setDate(_ sender: UIButton) {
        
        let vc = DatePickerController.present(self, delegate: self)
        vc.pickerView.datePickerMode = .date
        
        if let date = date {
            
            vc.pickerView.date = date
        }
        
        vc.pickerView.maximumDate = Date()
    }
    
    @objc func resetDate(_ sender: UIButton) {
        
        self.date = nil
        
        content.getReservations(userId: userId, state: "past", type: "client", date: date)
    }
    
    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let view = PastSectionHeaderView.instantiateFromNib(named: "PastSectionHeaderView")
        
        if let date = date {
            
            view.buttonDate.setTitle(DateUtils.getAppDateString(timeInMillis: date.timeIntervalSince1970), for: .normal)
        }
        
        view.buttonDate.addTarget(self, action: #selector(setDate), for: .touchUpInside)
        view.buttonAll.addTarget(self, action: #selector(resetDate), for: .touchUpInside)
        
        self.buttonDate = view.buttonDate
        
        return view
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return reservations.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! ReservationTableCell
        
        cell.setDetails(vc: self, isUpcoming: false, reservation: reservations[indexPath.row])

        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "ProfileViewController") as! ProfileViewController
        vc.doctorId = reservations[indexPath.row].idDoctor
        self.show(vc, sender: nil)
    }
    
    func done(picker: DatePickerController, date: Date) -> Bool {
        
        self.date = date
        
        buttonDate.setTitle(DateUtils.getAppDateString(timeInMillis: date.timeIntervalSince1970), for: .normal)
        
        content.getReservations(userId: userId, state: "past", type: "client", date: date)
        
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
                reservations = response as! [Reservation]
                
                tableView.reloadData()
                break
            default:
                
                let user = SettingsManager().getUser()
                
                content.getReservations(userId: user.id, state: "past", type: "client")
                break
            }
        } else {
            Toast.showAlert(viewController: self, text: status.message)
        }
    }
}

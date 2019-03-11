//
//  DoctorScheduleViewController.swift
//  balto
//
//  Created by Abanoub Osama on 4/3/18.
//  Copyright © 2018 Abanoub Osama. All rights reserved.
//

import UIKit
import SDWebImage

class DoctorScheduleViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, ContentDelegate {
    
    @IBOutlet weak var imageViewPic: CircularImageView!
    @IBOutlet weak var labelName: UILabel!
    @IBOutlet weak var labelSpecialization: UILabel!
    @IBOutlet weak var labelRating: UILabel!
    @IBOutlet weak var labelFees: UILabel!
    
    @IBOutlet weak var stackViewDays: UIStackView!
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    private var loadingView: LoadingView!
    
    private var noItemsView: NoItemsView!
    
    private var selectedDayView: UIView!
    
    private var doctor: Doctor!
    
    private var schedules = [Schedule]()
    
    private var content: ContentSession!
    
    private var date = Date()
    
    var mainViewController: MainViewController!
    
    class func getInstance(doctor: Doctor) -> DoctorScheduleViewController {
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "DoctorScheduleViewController") as! DoctorScheduleViewController
        vc.doctor = doctor
        
        return vc
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadingView = LoadingView(frame: view.frame)
        loadingView.setLoadingImage(image: UIImage(named: "loading")!)
        loadingView.backgroundColor = UIColor.white.withAlphaComponent(0.8)
        loadingView.isHidden = true
        self.view.addSubview(loadingView)
        
        noItemsView = NoItemsView.loadFromNib()
        noItemsView.label.text = LocalizationSystem.sharedInstance.localizedStringForKey(key: "notAvailable", comment: "")
        let frame = CGRect(x: 0, y: 0, width: view.frame.width, height: view.frame.height - view.frame.origin.y)
        noItemsView.frame = frame
        noItemsView.isHidden = true
        self.view.addSubview(noItemsView)
        
        content = ContentSession(delegate: self)
        
        collectionView.dataSource = self
        collectionView.delegate = self
        
        collectionView.register(UINib(nibName: "ScheduleCollectionCell", bundle: nil), forCellWithReuseIdentifier: "cell")
        
        self.content.getDoctorSchedule(doctorId: doctor.id, date: self.date)
        
        if let image = doctor.image, !image.isEmpty {
            imageViewPic.sd_setImage(with: URL(string: image), completed: nil)
        }
        labelName.text = doctor.name
        labelSpecialization.text = doctor.specialization.name
        labelRating.text = "\(doctor.rate!)"
        labelFees.text = doctor.price
        
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
        
        // listen
//        NotificationCenter.default.addObserver(self, selector: #selector(self.reloadReservation), name: Notification.Name("reloadReservation"), object: nil)
        
    }
    
    /* @objc func reloadReservation() {
        
        let first  = self.navigationController?.viewControllers.first
        self.navigationController?.popToRootViewController(animated: false)
        
        if let main = first as? MainViewController {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let vc = storyboard.instantiateViewController(withIdentifier: "ReservationsViewController")
            self.loadingView.setIsLoading(false)
            main.replaceViewController(vc)
        }
        
    } */
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.navigationController?.navigationBar.topItem?.title = LocalizationSystem.sharedInstance.localizedStringForKey(key: "reservation2", comment: "")
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.navigationBar.topItem?.title = ""
    }
    
    @objc func updateDate(_ sender: UIButton) {
        
        let superView = sender.superview!
        if let index = stackViewDays.arrangedSubviews.index(of: superView) {
            
            if superView !== selectedDayView {
            
                let button = superView.viewWithTag(1) as! UIButton
                button.setBackgroundImage(UIImage(named: "9_28_circle"), for: .normal)
                button.setTitleColor(UIColor.white, for: .normal)
                
                let buttonOld = selectedDayView.viewWithTag(1) as! UIButton
                buttonOld.setBackgroundImage(nil, for: .normal)
                buttonOld.setTitleColor(UIColor.black, for: .normal)
                
                selectedDayView = superView
            }
            
            date = Date().addingTimeInterval(DateUtils.DAY_INTERVAL * TimeInterval(index))
            
            self.content.getDoctorSchedule(doctorId: doctor.id, date: date)
        }
    }
    
    // start of collectionView's dataSource, delegate and flowDelegate
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        var isLarge = schedules[indexPath.row].isBooked
        
        if !isLarge {
            
            if indexPath.row % 2 == 0 && indexPath.row + 1 < schedules.count {
                
                isLarge = schedules[indexPath.row + 1].isBooked
            } else if indexPath.row % 2 != 0 && indexPath.row != 0 {
                
                isLarge = schedules[indexPath.row - 1].isBooked
            }
        }
        
        let height = isLarge ? 100 : 80
        
        return CGSize(width: collectionView.frame.size.width / 2.1, height: CGFloat(height))
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return schedules.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! ScheduleCollectionCell
        
        let schedule = schedules[indexPath.row]
        
        if schedule.isBooked {
            
            cell.labelSchedule.text = "\(schedule.from!) - \(schedule.to!)\n\(LocalizationSystem.sharedInstance.localizedStringForKey(key: "booked", comment: ""))"
            cell.labelSchedule.superview?.backgroundColor = schedule.isMine ? .black : .pink
        } else {
            
            cell.labelSchedule.text = "\(schedule.from!) - \(schedule.to!)"
            cell.labelSchedule.superview?.backgroundColor = .cyan
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let schedule = schedules[indexPath.row]
        
        if !schedule.isBooked {
        
            let vc = ConfirmScheduleViewController(doctor: doctor, schedule: schedule) { isSuccess in
                
                let first  = self.navigationController?.viewControllers.first
                self.navigationController?.popToRootViewController(animated: false)
                
                if let main = first as? MainViewController {
                    
                    DispatchQueue.main.async {
                        
                        let vc = self.storyboard!.instantiateViewController(withIdentifier: "ReservationsViewController")
                        
                        main.replaceViewController(vc)
                    }
                }
                return false
            }
            self.present(vc, animated: true, completion: nil)
        }
    }
    // end of collectionView's dataSource, delegate and flowDelegate
    
    func onPreExecute(action: ContentSession.ActionType) {
        loadingView.setIsLoading(true)
    }
    
    func onPostExecute(status: BaseUrlSession.Status, action: ContentSession.ActionType, response: Any!) {
        loadingView.setIsLoading(false)
        if status.success {
            
            switch action {
            case .getDoctorSchedule:
                
                let isNotToday = !Calendar.current.isDateInToday(date)
                
                let currentDate = Date()
                
                let schedules = response as! [Schedule]
                self.schedules = []
                
                var serviceDuration = TimeInterval(20 * 60)
                // is a crazies doctor
                if doctor.specialization.id == 13 {
                    
                    serviceDuration = TimeInterval(30 * 60)
                }
                
                for mainSchedule in schedules {
                    
                    let from = DateUtils.getDate(dateString: "\(mainSchedule.date!) \(mainSchedule.from!)", dateFormat: DateUtils.SERVER_DATE_TIME_FORMAT).timeIntervalSince1970
                    let to = DateUtils.getDate(dateString: "\(mainSchedule.date!) \(mainSchedule.to!)", dateFormat: DateUtils.SERVER_DATE_TIME_FORMAT).timeIntervalSince1970
                    
                    let count = Int((to - from) / serviceDuration)
                    
                    for i in 0..<count {
                        
                        let from = from + serviceDuration * TimeInterval(i)
                        
                        if from > Date().timeIntervalSince1970 {
                            
                            let schedule = Schedule(date: Date(timeIntervalSince1970: from), serviceDuration: Int(serviceDuration / 60))
                            schedule.type = "online"

                            let diff = schedule.originalDate.interval(ofComponent: .minute, fromDate: currentDate)
                            
                            if diff > 59 || isNotToday {
                                
                                self.schedules.append(schedule)
                            }
                        }
                    }
                }
                
                self.schedules.sort(by: { (s1, s2) -> Bool in
                    
                    return s1.originalDate < s2.originalDate
                })
     
                if self.schedules.isEmpty {
                    
                    self.noItemsView.isHidden = false
                } else {
                    
                    self.noItemsView.isHidden = true
                }
                
                content.getReservations(userId: doctor.id, state: "coming", type: "doctor", date: date)
                break
                
            case .getReservations:
                
                let reservations = response as! [Reservation]
                
                let userId = SettingsManager().getUserId()
                
                for schedule in schedules {
                    
                    let from = DateUtils.getDate(dateString: "\(schedule.date!) \(schedule.from!)", dateFormat: "\(DateUtils.SERVER_DATE_FORMAT) \(DateUtils.SERVER_TIME_SHORT_FORMAT)").timeIntervalSince1970
                    
                    for reservation in reservations {
                        
                        let start = DateUtils.getDate(dateString: reservation.date, dateFormat: "\(DateUtils.SERVER_DATE_FORMAT) \(DateUtils.SERVER_TIME_SHORT_FORMAT)").timeIntervalSince1970
                        
                        if abs(start.distance(to: from)) < 5 * 60 {
                            
                            schedule.isBooked = true
                            
                            schedule.isMine = reservation.idClient == userId
                            break
                        }
                    }
                }
                
                collectionView.reloadData()
                break
            default:
                break
            }
        } else {
            Toast.showAlert(viewController: self, text: status.message)
        }
    }
}

public extension Date {
    
    func interval(ofComponent comp: Calendar.Component, fromDate date: Date) -> Int {
        
        let currentCalendar = Calendar.current
        
        guard let start = currentCalendar.ordinality(of: comp, in: .era, for: date) else { return 0 }
        guard let end = currentCalendar.ordinality(of: comp, in: .era, for: self) else { return 0 }
        
        return end - start
    }
}

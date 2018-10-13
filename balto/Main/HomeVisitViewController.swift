//
//  HomeVisitViewController.swift
//  balto
//
//  Created by Abanoub Osama on 4/27/18.
//  Copyright © 2018 Abanoub Osama. All rights reserved.
//

import UIKit
import GoogleMaps
import GooglePlaces

class HomeVisitViewController: UIViewController, CLLocationManagerDelegate, GMSMapViewDelegate, DatePickerDelegate, ContentDelegate, PaymentDelegate, GMSAutocompleteViewControllerDelegate {
    
    public enum HomeVisitStep {
        case profession, specialization, summary
    }
    
    @IBOutlet weak var mapView: GMSMapView!
    
    @IBOutlet weak var stackView: UIStackView!
    
    @IBOutlet weak var textFieldSearch: UITextField!
    
    private var loadingView: LoadingView!
    
    private var manager: CLLocationManager!
    
    private var content: ContentSession!
    private var payment: PaymentSession!
    
    private var payMobId: Int!
    private var date: Date!
    
    var homeVisitStep: HomeVisitStep = .profession
    
    var profession: MainCategory!
    
    var specialization: SubCategory!
    var serviceLocation: CLLocationCoordinate2D!
    
    var genderId: Int!
    var serviceDuration: Int = 0
    var paymentMethod: Int!
    var coupon: Coupon!
    
    private var doctors: [Doctor]!
    
    private var tempDoc: Doctor!
    
    private var searchDistance = 10
    private var appointmentCreatedAt: TimeInterval!
    
    private var createReservation: Reservation!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupLocation()
        
        switch homeVisitStep {
        case .profession:
            
            setupForProfessions()
            break
        case .specialization:
            
            setupForSpecialization()
            break
        case .summary:
            
            loadingView = LoadingView(frame: view.frame)
            loadingView.setLoadingImage(image: UIImage(named: "loading")!)
            loadingView.backgroundColor = UIColor.white.withAlphaComponent(0.8)
            loadingView.isHidden = true
            self.view.addSubview(loadingView)
            
            content = ContentSession(delegate: self)
            payment = PaymentSession(delegate: self)
            
            setupForSummary()
            break
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.navigationController?.navigationBar.topItem?.title = LocalizationSystem.sharedInstance.localizedStringForKey(key: "home_visit", comment: "")
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.navigationBar.topItem?.title = ""
    }
    
    @IBAction func placesSearch(_ sender: UIButton) {
        
        let filter = GMSAutocompleteFilter()
        filter.country = "eg"
        
        let vc = GMSAutocompleteViewController()
        vc.delegate = self
        vc.autocompleteFilter = filter
        present(vc, animated: true, completion: nil)
    }
    
    func viewController(_ viewController: GMSAutocompleteViewController, didAutocompleteWith place: GMSPlace) {
        
        mapView.clear()
        
        let camera = GMSCameraPosition.camera(withLatitude: place.coordinate.latitude, longitude: place.coordinate.longitude, zoom: 15.0)
        
        mapView.camera = camera
        
        self.serviceLocation = place.coordinate
        
        let marker = GMSMarker()
        marker.position = place.coordinate
        marker.title = "Service location"
        marker.map = mapView
        
        textFieldSearch.text = place.formattedAddress
        
        viewController.dismiss(animated: true, completion: nil)
    }
    
    func viewController(_ viewController: GMSAutocompleteViewController, didFailAutocompleteWithError error: Error) {
        
        viewController.dismiss(animated: true, completion: nil)
        Toast.showAlert(viewController: self, text: error.localizedDescription)
    }
    
    func wasCancelled(_ viewController: GMSAutocompleteViewController) {
        
        viewController.dismiss(animated: true, completion: nil)
    }
    
    func setupLocation() {
        
        if let url = Bundle.main.url(forResource: "gms_style", withExtension: "json"), let style = try? GMSMapStyle(contentsOfFileURL: url) {
            
            mapView.mapStyle = style
        }
        
        mapView.isMyLocationEnabled = true
        mapView.settings.myLocationButton = true
        
        manager = CLLocationManager()
        manager.delegate = self
        
        if CLLocationManager.locationServicesEnabled() {
            switch(CLLocationManager.authorizationStatus()) {
            case .notDetermined, .restricted:
                
                manager.requestWhenInUseAuthorization()
                break
            case .denied :
                
                Toast.showAlert(viewController: self, text: "Location Accees Requested", style: .alert, UIAlertAction(title: "Settings", style: .default, handler: { (action) in
                    if let appSettings = URL(string: UIApplicationOpenSettingsURLString) {
                        if #available(iOS 10.0, *) {
                            UIApplication.shared.open(appSettings as URL)
                        } else {
                            UIApplication.shared.openURL(appSettings as URL)
                        }
                    }
                }), UIAlertAction(title: "Cancel", style: .default, handler: nil))
                break
            case .authorizedAlways, .authorizedWhenInUse:
                
                if let location = manager.location {
                    mapView.clear()
                    
                    let camera = GMSCameraPosition.camera(withLatitude: location.coordinate.latitude, longitude: location.coordinate.longitude, zoom: 15.0)
                    
                    mapView.camera = camera
                    
                    let marker = GMSMarker()
                    marker.position = serviceLocation ?? location.coordinate
                    marker.title = "Service location"
                    marker.map = mapView
                    
                    if self.serviceLocation == nil {
                        
                        self.serviceLocation = location.coordinate
                    }
                } else {
                    
                    manager.requestLocation()
                }
                break
            }
        } else {
            Toast.showAlert(viewController: self, text: "Please enable location services first")
        }
    }
    
    func setupForProfessions() {
        
        textFieldSearch.superview!.isHidden = true
        
        clearStackView()
        
        let professionview = ProfessionView.instantiateFromNib(vc: self) { (profession) in
            
            let vc = self.storyboard!.instantiateViewController(withIdentifier: "HomeVisitViewController") as! HomeVisitViewController
            vc.homeVisitStep = .specialization
            vc.profession = profession
            self.show(vc, sender: self)
        }
        stackView.addArrangedSubview(professionview)
    }
    
    func setupForSpecialization() {
        
        mapView.delegate = self
        
        textFieldSearch.superview!.isHidden = false
        
        clearStackView()
        
        let specializationView = SpecializationView.instantiateFromNib(vc: self, mainCategory: profession) { (specialization) in
            
            if let serviceLocation = self.serviceLocation {
                
                let vc = self.storyboard!.instantiateViewController(withIdentifier: "HomeVisitPaymentViewController") as! HomeVisitPaymentViewController
                vc.profession = self.profession
                vc.specialization = specialization
                vc.serviceLocation = serviceLocation
                self.show(vc, sender: self)
            } else {
                
                Toast.showAlert(viewController: self, text: "Please tap map to select service location")
            }
        }
        
        stackView.addArrangedSubview(specializationView)
    }
    
    func setupForSummary() {
        
        textFieldSearch.superview!.isHidden = true
        
        clearStackView()
        
        let summaryView = SummaryView.instantiateFromNib(vc: self)
        
        stackView.addArrangedSubview(summaryView)
        
        content.nearestDoctor(location: serviceLocation, idGender: genderId, idSub: specialization.idSub, distance: searchDistance)
    }
    
    func clearStackView() {
        
        for view in stackView.arrangedSubviews {
            
            stackView.removeArrangedSubview(view)
            view.removeFromSuperview()
        }
    }
    
    func schedule() {
        let vc = DatePickerController.present(self, delegate: self)
        vc.pickerView.datePickerMode = .date
        vc.pickerView.minimumDate = Date()
        vc.pickerView.maximumDate = Date().addingTimeInterval(7 * DateUtils.DAY_INTERVAL)
    }
    
    func confirm(date: Date = Date()) {
        self.date = date
        
        let schedule = Schedule(date: date, serviceDuration: serviceDuration)
        
        let totalPrice = specialization.baseFare + (serviceDuration / 60) * specialization.peicePerHour
       
        addBooking(schedule: schedule, totalPrice: totalPrice)
    }
    
    func addBooking(schedule: Schedule, totalPrice: Int) {
        
        let userId = SettingsManager().getUserId()
        
        // credit
        if paymentMethod == 2 {
            
            if let token = PaymentSession.getSavedWith(key: "savedToken"), !token.isEmpty {
                
                let totalPrice = specialization.baseFare + (serviceDuration / 60) * specialization.peicePerHour
                
                content.addBooking(subId: specialization.idSub, price: totalPrice, userId: userId, schedule: schedule, scheduleKind: 1, paymentMethod: paymentMethod, coupon: coupon, serviceLocation: self.serviceLocation)
            } else {
                
                payment.addCard(vc: self)
            }
        } else {
        
            content.addBooking(subId: specialization.idSub, price: totalPrice, userId: userId, schedule: schedule, scheduleKind: 1, paymentMethod: paymentMethod, coupon: coupon, serviceLocation: self.serviceLocation)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch(CLLocationManager.authorizationStatus()) {
        case .notDetermined, .restricted:
            
            manager.requestWhenInUseAuthorization()
            break
        case .authorizedAlways, .authorizedWhenInUse:
            
            if let location = manager.location {
                
                mapView.clear()
                
                let camera = GMSCameraPosition.camera(withLatitude: location.coordinate.latitude, longitude: location.coordinate.longitude, zoom: 15.0)
                
                mapView.camera = camera
                
                let marker = GMSMarker()
                marker.position =  serviceLocation ?? location.coordinate
                marker.title = "Service location"
                marker.map = mapView
                
                if self.serviceLocation == nil {
                
                    self.serviceLocation = location.coordinate
                }
            } else {
                
                manager.requestLocation()
            }
            break
        default:
            break
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        if !locations.isEmpty {
            
            mapView.clear()
            
            let location = locations[0]
            
            let camera = GMSCameraPosition.camera(withLatitude: location.coordinate.latitude, longitude: location.coordinate.longitude, zoom: 15.0)
            
            mapView.camera = camera
            
            let marker = GMSMarker()
            marker.position = serviceLocation ?? location.coordinate
            marker.title = "Service location"
            marker.map = mapView
            
            if self.serviceLocation == nil {
            
                self.serviceLocation = location.coordinate
            }
        } else {
            
            manager.requestLocation()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
    }
    
    func mapView(_ mapView: GMSMapView, didTapAt coordinate: CLLocationCoordinate2D) {
        mapView.clear()
        
        self.serviceLocation = coordinate
        
        let marker = GMSMarker()
        marker.position = coordinate
        marker.title = "Service location"
        marker.map = mapView
        
        textFieldSearch.text = ""
    }
    
    func done(picker: DatePickerController, date: Date) -> Bool {
        switch picker.pickerView.datePickerMode {
        case .date:
            
            picker.pickerView.datePickerMode = .time
            return true
        case .time:
            
            confirm(date: date)
            break
        default:
            break
        }
        return false
    }
    
    func cancel(picker: DatePickerController) -> Bool {
        return false
    }
    
    var timer: Timer!
    
    func onPreExecute(action: ContentSession.ActionType) {
        
        if action == .notify || action == .getBookingData {
            
        } else {
            
            loadingView.setIsLoading(true)
        }
    }
    
    func onPostExecute(status: BaseUrlSession.Status, action: ContentSession.ActionType, response: Any!) {
        if status.success || action == .nearestDoctor {
            
            switch action {
            case .nearestDoctor:
                
                loadingView.setIsLoading(false)
                
                let doctors = response as? [Doctor]
                if let doctors = doctors, !doctors.isEmpty {
                    
                    self.doctors = doctors
                    
                    let doctor = try? Doctor(jsonDic: [String : Any]())
                    doctor!.id = 144
                    self.doctors.append(doctor!)
                } else {
                    
                    if self.searchDistance < 50 {
                        
                        self.searchDistance += 10
                        
                        content.nearestDoctor(location: serviceLocation, idGender: genderId, idSub: specialization.idSub, distance: self.searchDistance)
                    } else {
                        
                        Toast.showAlert(viewController: self, text: LocalizationSystem.sharedInstance.localizedStringForKey(key: "all_profs_are_busy", comment: ""), style: UIAlertControllerStyle.actionSheet, UIAlertAction(title: "ok", style: .default, handler: { (action) in
                            
                            self.navigationController?.popToRootViewController(animated: true)
                        }))
                        
                        if let timer = timer {
                            timer.invalidate()
                            self.timer = nil
                        }
                    }
                }
                break
            case .addBooking:
                
                let reservation = response as! Reservation
                self.createReservation = reservation
                self.appointmentCreatedAt = Date().timeIntervalSince1970
                    
                for doctor in doctors {
                    
                    if let fcmToken = doctor.fcmToken, !fcmToken.isEmpty {
                        
                        content.sendNotification(bookingId: reservation.id, fcmToken: doctor.fcmToken, kind: NotificationHandler.Kind.bookingRequest, title: "", message: "")
                    }
                }
                
                content.bookingData(bookingId: reservation.id)
                break
            case .getBookingData:
                
                let reservation = response as! Reservation
                self.createReservation = reservation
                
                let now = Date().timeIntervalSince1970
                let appointmentCreatedAt = self.appointmentCreatedAt!
                let timeSinceCreated =  now - appointmentCreatedAt
                
                if reservation.stateId < 2 {
                    
                    if timeSinceCreated < 30 {
                        
                        if #available(iOS 10.0, *) {
                            
                            if timer == nil {
                                
                                timer = Timer.scheduledTimer(withTimeInterval: 5, repeats: true, block: { (timer) in
                                    
                                    self.content.bookingData(bookingId: self.createReservation.id)
                                })
                            }
                        } else {
                            self.content.bookingData(bookingId: self.createReservation.id)
                        }
                    } else {
                        
                        Toast.showAlert(viewController: self, text: LocalizationSystem.sharedInstance.localizedStringForKey(key: "all_profs_are_busy", comment: ""), style: UIAlertControllerStyle.actionSheet, UIAlertAction(title: "ok", style: .default, handler: { (action) in
                            
                            self.navigationController?.popToRootViewController(animated: true)
                        }))
                        
                        if let timer = timer {
                            timer.invalidate()
                            self.timer = nil
                        }
                    }
                } else {
                    
                    Toast.showAlert(viewController: self, text: "Home visit created", style: UIAlertControllerStyle.actionSheet, UIAlertAction(title: "ok", style: .default, handler: { (action) in
                        
                        self.navigationController?.popToRootViewController(animated: true)
                    }))
                    
                    if let timer = timer {
                        timer.invalidate()
                        self.timer = nil
                    }
                }
                break
            case .cancelBooking:
                
                loadingView.setIsLoading(false)
                
                Toast.showAlert(viewController: self, text: "No doctors found", style: UIAlertControllerStyle.actionSheet, UIAlertAction(title: "ok", style: .default, handler: { (action) in
                    
                    self.navigationController?.popToRootViewController(animated: true)
                }))
                
                if let timer = timer {
                    timer.invalidate()
                    self.timer = nil
                }
                break
            case .updateBooking:
                
                loadingView.setIsLoading(false)
                
                content.sendNotification(bookingId: createReservation?.id ?? 0, fcmToken: tempDoc.fcmToken, kind: NotificationHandler.Kind.bookingRequest, title: "", message: "")
                
                break
            default:
                break
            }
        } else {
            
            if let timer = timer {
                timer.invalidate()
                self.timer = nil
            }
            
            loadingView.setIsLoading(false)
            Toast.showAlert(viewController: self, text: status.message)
        }
    }
    
    func onPostExecute(status: BaseUrlSession.Status, action: PaymentSession.ActionType, response: Any!) {
        loadingView.setIsLoading(false)
        if status.success {
            
            switch action {
            case .payNowByToken:
                
                self.payMobId = response as! Int
                
                let userId = SettingsManager().getUserId()
                
                let schedule = Schedule(date: date, serviceDuration: serviceDuration)
                
                let totalPrice = specialization.baseFare + (serviceDuration / 60) * specialization.peicePerHour
                
                content.addBooking(subId: specialization.idSub, price: totalPrice, userId: userId, schedule: schedule, scheduleKind: 1, paymentMethod: paymentMethod, coupon: coupon, serviceLocation: self.serviceLocation)
                
                Toast.showAlert(viewController: self, text: "Transaction successfull", dismissAfter: TimeInterval(5))
                break
            case .payNowByCard:
                
                self.payMobId = response as! Int
                
                let userId = SettingsManager().getUserId()
                
                let schedule = Schedule(date: date, serviceDuration: serviceDuration)
                
                let totalPrice = specialization.baseFare + (serviceDuration / 60) * specialization.peicePerHour
                
                content.addBooking(subId: specialization.idSub, price: totalPrice, userId: userId, schedule: schedule, scheduleKind: 1, paymentMethod: paymentMethod, coupon: coupon, serviceLocation: self.serviceLocation)
                break
            default:
                break
            }
        } else {
            
            Toast.showAlert(viewController: self, text: status.message)
        }
    }
}


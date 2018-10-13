//
//  HomeVisitViewController.swift
//  balto
//
//  Created by Abanoub Osama on 4/27/18.
//  Copyright © 2018 Abanoub Osama. All rights reserved.
//

import UIKit
import GoogleMaps

class TrackDoctorViewController: UIViewController, ContentDelegate {
    
    private var mapView: GMSMapView!
    
    private var loadingView: LoadingView!
    
    private var content: ContentSession!
    
    private var doctorId: Int!
    
    private var doctor: Doctor!
    
    private var timer: Timer!
    
    private var reservationId: Int!
    
    class func getInstance(reservationId: Int) -> TrackDoctorViewController {
        
        let vc = TrackDoctorViewController()
        vc.reservationId = reservationId
        return vc
    }
    
    class func getInstance(doctorId: Int) -> TrackDoctorViewController {
        
        let vc = TrackDoctorViewController()
        vc.doctorId = doctorId
        return vc
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mapView = GMSMapView(frame: view.frame)
        view.addSubview(mapView)
        
        if let url = Bundle.main.url(forResource: "gms_style", withExtension: "json"), let style = try? GMSMapStyle(contentsOfFileURL: url) {
            
            mapView.mapStyle = style
        }
        
        mapView.isMyLocationEnabled = true
        mapView.settings.myLocationButton = true
        
        loadingView = LoadingView(frame: view.frame)
        loadingView.setLoadingImage(image: UIImage(named: "loading")!)
        loadingView.backgroundColor = UIColor.white.withAlphaComponent(0.8)
        loadingView.isHidden = true
        self.view.addSubview(loadingView)
        
        content = ContentSession(delegate: self)
        
        if let doctorId = doctorId {
        
            content.getDoctor(doctorId: doctorId)
        } else {
            
            content.bookingData(bookingId: reservationId)
        }
    }
    
    func onPreExecute(action: ContentSession.ActionType) {
        if doctor == nil {
        
            loadingView.setIsLoading(true)
        }
    }
    
    func onPostExecute(status: BaseUrlSession.Status, action: ContentSession.ActionType, response: Any!) {
        if doctor == nil {
        
            loadingView.setIsLoading(false)
        }
        if status.success {
            
            switch action {
            case .getBookingData:
                let reservation = response as! Reservation
                
                content.getDoctor(doctorId: reservation.idDoctor)
                break
            case .getDoctorData:
                self.doctor = response as! Doctor
                
                if #available(iOS 10.0, *) {
                    
                    timer = Timer.scheduledTimer(withTimeInterval: 10, repeats: true, block: { (timer) in
                        
                        self.content.getDoctorLocation(doctorId: self.doctorId)
                    })
                } else {
                    // Fallback on earlier versions
                }
                content.getDoctorLocation(doctorId: doctor.id)
                break
            case .getDoctorLocation:
                
                let location = response as! CLLocationCoordinate2D
                
                mapView.clear()
                
                let marker = GMSMarker()
                marker.position = location
                marker.title = doctor.name
                marker.map = mapView
                
                let camera = GMSCameraPosition.camera(withLatitude: location.latitude, longitude: location.longitude, zoom: 15.0)
                
                mapView.camera = camera
                break
            default:
                if let nav = navigationController {
                
                    nav.popToRootViewController(animated: true)
                } else {
                    
                    dismiss(animated: true, completion: nil)
                }
                break
            }
        } else {
            Toast.showAlert(viewController: self, text: status.message)
        }
    }
}


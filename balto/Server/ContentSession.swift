
//
//  ContentSession.swift
//  Syariti
//
//  Created by Mena on 9/20/17.
//  Copyright © 2017 Mena. All rights reserved.
//

import Foundation
import UIKit
import CoreLocation
import Alamofire
import SwiftyJSON

public class ContentSession: BaseUrlSession {
    
    var delegate: ContentDelegate!
    let baseUrl = Constants.BASE_URL
    var token = ""
    
    private let count = 50
    
    public enum ActionType {
        case getDoctorFilters, getDoctorSubCategories, getDoctorGenders, getDoctorLanguages, getDoctors,
             getDoctorsForChat, getDoctorSchedule, addSchedule, getReservations, addBooking, updateBooking, cancelBooking, getCoupons, nearestDoctor, getDoctorData, mainCategories, subCategories, notify, createRoom, rateBooking, getDoctorLocation, getBookingData, updateUser, getDoctorReviews, PaymentSession, addPayment, doctorPercentageMoney, getUserData, uploadImage, checkCoupon
    }
    
    override init() {
    }
    
    init<T: ContentDelegate>(delegate: T)  {
        super.init()
        
        self.delegate = delegate
    }
    
    func getDoctorFilters() {
        
        let actionType = ActionType.getDoctorFilters
        
        let url = UrlBuilder(baseUrl: "http://haseboty.com/doctor/public/api/doctorFiltterData?")
            .put("type", LocalizationSystem.sharedInstance.getLanguage())
        
        requestConnection(action: actionType, url: url.build(), shouldLoadFromCache: true)
    }
    
    func getDoctors(date: Date! = nil, name: String = "", subId: Int! = nil, languageId: Int! = nil, genderId: Int! = nil) {
        
        let actionType = ActionType.getDoctors
        
        let url = UrlBuilder(baseUrl: "http://haseboty.com/doctor/public/api/fillterOnlineDoctor?")
            .put("name", name)
            .put("type", LocalizationSystem.sharedInstance.getLanguage())
        
        if let sub = subId {
            
            url.put("id_sub", "\(sub)")
        }
        
        if let language = languageId {
            
            url.put("id_language", "\(language)")
        }
        
        if let gender = genderId {
            
            url.put("id_gender", "\(gender)")
        }
        
        if let date = date {
            
            let calendar = Calendar.current
            
            url.put("day", String(format: "%02d", calendar.component(Calendar.Component.day, from: date)))
                .put("month", String(format: "%02d", calendar.component(Calendar.Component.month, from: date)))
                .put("year", String(format: "%02d", calendar.component(Calendar.Component.year, from: date)))
        }
        
        requestConnection(action: actionType, url: url.build(), shouldCache: true)
    }
    
    
    func getDoctorsForChat(name: String = "", subId: Int! = nil, languageId: Int! = nil, genderId: Int! = nil) {
        
        let actionType = ActionType.getDoctorsForChat
        
        let url = UrlBuilder(baseUrl: "http://haseboty.com/doctor/public/api/getAvailableDoctorToChat?")
            .put("name", name)
            .put("type", LocalizationSystem.sharedInstance.getLanguage())
        
        if let sub = subId {
            
            url.put("id_sub", "\(sub)")
        }
        
        if let language = languageId {
            
            url.put("id_language", "\(language)")
        }
        
        if let gender = genderId {
            
            url.put("id_gender", "\(gender)")
        }
        
        requestConnection(action: actionType, url: url.build(), shouldCache: true)
    }
    
    func getDoctorSchedule(doctorId: Int, date: Date! = nil) {
        
        let actionType = ActionType.getDoctorSchedule
        
        let url = UrlBuilder(baseUrl: "http://haseboty.com/doctor/public/api/getScheduleByDate?")
        
        url.put("id_user", doctorId)
        
        if let date = date {
            
            let calendar = Calendar.current
            
            url.put("day", String(format: "%02d", calendar.component(Calendar.Component.day, from: date)))
                .put("month", String(format: "%02d", calendar.component(Calendar.Component.month, from: date)))
                .put("year", String(format: "%02d", calendar.component(Calendar.Component.year, from: date)))
        }
        
        requestConnection(action: actionType, url: url.build(), shouldCache: true)
    }
    
    func addSchedule(doctorId: Int, userId: Int, schedule: Schedule) {
        
        let actionType = ActionType.addSchedule
        
        let url = UrlBuilder(baseUrl: "http://haseboty.com/doctor/public/api/addSchedule?")
        
        url.put("id_doctor", doctorId)
            .put("id_user", userId)
            .put("type", "home")
            .put("from_hour", schedule.from.components(separatedBy: ":")[0])
            .put("from_minutes", schedule.from.components(separatedBy: ":")[1])
            .put("to_hour", schedule.to.components(separatedBy: ":")[0])
            .put("to_minutes", schedule.to.components(separatedBy: ":")[1])
            .put("day", String(format: "%02d", (schedule.date.components(separatedBy: "-")[2] as NSString).integerValue))
            .put("month", String(format: "%02d", (schedule.date.components(separatedBy: "-")[1] as NSString).integerValue))
            .put("year", String(format: "%02d", (schedule.date.components(separatedBy: "-")[0] as NSString).integerValue))
        
        requestConnection(action: actionType, url: url.build(), shouldCache: false)
    }
    
    func addBooking(subId: Int, price: Int, userId: Int, schedule: Schedule, scheduleKind: Int, paymentMethod: Int, coupon: Coupon!, serviceLocation: CLLocationCoordinate2D! = nil, wallet_id: Int? = nil) {
        
        let actionType = ActionType.addBooking
        
        let url = UrlBuilder(baseUrl: "http://haseboty.com/doctor/public/api/addBooking?")
        
        url.put("id_sub", subId)
            .put("id_client", userId)
            .put("id_doctor_kind", scheduleKind)
            .put("id_state", 1)
            .put("id_payment_way", paymentMethod)
            .put("duration", subId == 13 ? "30" : "20") // 13 is crazies doctor
            .put("receive_hour", String(format: "%02d", (schedule.from.components(separatedBy: ":")[0] as NSString).integerValue))
            .put("receive_minutes", String(format: "%02d", (schedule.from.components(separatedBy: ":")[1] as NSString).integerValue))
            .put("receive_day", String(format: "%02d", (schedule.date.components(separatedBy: "-")[2] as NSString).integerValue))
            .put("receive_month", String(format: "%02d", (schedule.date.components(separatedBy: "-")[1] as NSString).integerValue))
            .put("receive_year", String(format: "%02d", (schedule.date.components(separatedBy: "-")[0] as NSString).integerValue))
        
        if let my_wallet_id = wallet_id {
            url.put("wallet_id", my_wallet_id)
        }
        if let c = coupon {
            
            let price = Float(price)
            
            let newPrice = price - price * c.discount
            
            url.put("total_price", newPrice.rounded(.up))
                .put("id_coupon_client", coupon.id)
        } else {
            url.put("total_price", price)
        }
        if let location = serviceLocation {
            
            let loc = CLLocation(latitude: location.latitude, longitude: location.longitude)
            
            let geocoder = CLGeocoder()
            geocoder.reverseGeocodeLocation(loc, completionHandler: { (markers, error) in
                
                url.put("client_latitude", location.latitude)
                    .put("client_longitude", location.longitude)
                
                if let error = error {
                    
                    print(error.localizedDescription)
                    
                    url.put("client_address", "...")
                } else {
                    
                    if let markers = markers, !markers.isEmpty {
                        
                        let place = markers[0]
                        
                        var address = ""
                        if let thoro = place.thoroughfare {
                            address = address + thoro + " - "
                        }
                        if let thoro = place.administrativeArea {
                            address = address + thoro + " - "
                        }
                        if let thoro = place.administrativeArea {
                            address = address + thoro + " - "
                        }
                        if let thoro = place.country {
                            address = address + thoro
                        }
                        
                        url.put("client_address", address)
                    } else {
                        
                        url.put("client_address", "...")
                    }
                }
                
                self.requestConnection(action: actionType, url: url.build(), shouldCache: false)
            })
            
            return
        }
        requestConnection(action: actionType, url: url.build(), shouldCache: false)
    }
    
    func addBooking(doctor: Doctor, userId: Int, schedule: Schedule, scheduleKind: Int, paymentMethod: Int, coupon: Coupon!, serviceLocation: CLLocationCoordinate2D! = nil, wallet_id: Int? = nil) {
        
        
        print("doctor price is : \(String(doctor.price))")
        
        let actionType = ActionType.addBooking
        
        let url = UrlBuilder(baseUrl: "http://haseboty.com/doctor/public/api/addBooking?")
            .put("id_doctor", doctor.id)
            .put("id_sub", doctor.specialization.id)
            .put("id_client", userId)
            .put("id_doctor_kind", scheduleKind)
            .put("id_state", 1)
            .put("id_payment_way", paymentMethod)
            .put("total_price", "\(String(doctor.price))")
//            .put("total_price", "95")
            .put("duration", doctor.specialization.id == 13 ? "30" : "20")
            .put("receive_hour", String(format: "%02d", (schedule.from.components(separatedBy: ":")[0] as NSString).integerValue))
            .put("receive_minutes", String(format: "%02d", (schedule.from.components(separatedBy: ":")[1] as NSString).integerValue))
            .put("receive_day", String(format: "%02d", (schedule.date.components(separatedBy: "-")[2] as NSString).integerValue))
            .put("receive_month", String(format: "%02d", (schedule.date.components(separatedBy: "-")[1] as NSString).integerValue))
            .put("receive_year", String(format: "%02d", (schedule.date.components(separatedBy: "-")[0] as NSString).integerValue))
        
            if let my_wallet_id = wallet_id {
                url.put("wallet_id", my_wallet_id)
            }
        
            if let c = coupon {
                url.put("id_coupon_client", c.id)
            }
            if let location = serviceLocation {
                
                let loc = CLLocation(latitude: location.latitude, longitude: location.longitude)
                
                let geocoder = CLGeocoder()
                geocoder.reverseGeocodeLocation(loc, completionHandler: { (markers, error) in
                    
                    url.put("client_latitude", location.latitude)
                        .put("client_longitude", location.longitude)
                    
                    if let error = error {
                        
                        print(error.localizedDescription)
                        
                        url.put("client_address", "...")
                    } else {
                        
                        if let markers = markers, !markers.isEmpty {
                            
                            let place = markers[0]
                            
                            var address = ""
                            if let thoro = place.thoroughfare {
                                address = address + thoro + " - "
                            }
                            if let thoro = place.administrativeArea {
                                address = address + thoro + " - "
                            }
                            if let thoro = place.administrativeArea {
                                address = address + thoro + " - "
                            }
                            if let thoro = place.country {
                                address = address + thoro
                            }
                        
                            url.put("client_address", address)
                        } else {
                            
                            url.put("client_address", "...")
                        }
                    }
                    
                    self.requestConnection(action: actionType, url: url.build(), shouldCache: false)
                })
                
                return
            }
        requestConnection(action: actionType, url: url.build(), shouldLoadFromCache: false) { (success, failure) in
            if failure != nil {
                print("errror")
            }else {
                NotificationCenter.default.post(name: Notification.Name("reloadReservation"), object: nil)
            }
        }
//        requestConnection(action: actionType, url: url.build(), shouldCache: false)
        
    }
    
    func updateBooking(with reservation: Reservation, toState state: Int, doctorId: Int! = nil) {
        updateBooking(with: reservation.id, toState: state, doctorId: doctorId)
        
        switch state {
        case 3:
            sendNotification(bookingId: reservation.id, fcmToken: reservation.fcmToken, kind: NotificationHandler.Kind.doctorStart, title: "", message: "")
            break
        case 4:
//            sendNotification(bookingId: reservation.id, fcmToken: reservation.fcmToken, kind: NotificationHandler.Kind.bookingStateWorking, title: "", message: "")
            break
        case 5:
            sendNotification(bookingId: reservation.id, fcmToken: reservation.fcmToken, kind: NotificationHandler.Kind.bookingStateDone, title: "", message: "")
            break
        case 6, 7, 8:
            sendNotification(bookingId: reservation.id, fcmToken: reservation.fcmToken, kind: NotificationHandler.Kind.bookingStateCancel, title: "", message: "")
            break
        default:
            break
        }
    }
    
    func updateBooking(with id: Int, toState state: Int, doctorId: Int! = nil) {
        
        let actionType = ActionType.updateBooking
        
        let url = UrlBuilder(baseUrl: "http://haseboty.com/doctor/public/api/updateBooking?")
        
        url.put("id_state", state)
            .put("id", id)
        
        if let drId = doctorId {
            
            url.put("id_doctor", drId)
        }
        
        requestConnection(action: actionType, url: url.build(), shouldCache: false)
    }
    
    func getReservations(userId: Int, state: String, type: String, date: Date! = nil) {
        
        let actionType = ActionType.getReservations
        
        let url = UrlBuilder(baseUrl: "http://haseboty.com/doctor/public/api/reservationsData?")
        
        url.put("id_\(type)", userId)
            .put("type", type)
            .put("lang", LocalizationSystem.sharedInstance.getLanguage())
            .put("state", state)
        
        if let date = date {
            
            let calendar = Calendar.current
            
            url.put("receive_day", String(format: "%02d", calendar.component(Calendar.Component.day, from: date)))
                .put("receive_month", String(format: "%02d", calendar.component(Calendar.Component.month, from: date)))
                .put("receive_year", String(format: "%02d", calendar.component(Calendar.Component.year, from: date)))
        }
        
        requestConnection(action: actionType, url: url.build(), shouldCache: true)
    }
    
    func bookingData(bookingId: Int) {
        
        let actionType = ActionType.getBookingData
        
        let url = UrlBuilder(baseUrl: "http://haseboty.com/doctor/public/api/bookingData?")
            .put("id_booking", bookingId)
            .put("type", "client")
            .put("language", LocalizationSystem.sharedInstance.getLanguage())
        
        requestConnection(action: actionType, url: url.build(), shouldCache: false)
    }
    
    func deleteBooking(bookingId: Int) {
        
        let actionType = ActionType.cancelBooking
        
        let url = UrlBuilder(baseUrl: "http://haseboty.com/doctor/public/api/deleteBooking?")
        
        url.put("id", bookingId)
        
        requestConnection(action: actionType, url: url.build(), shouldCache: false)
    }
    
    func getCoupons() {
        
        let userId = SettingsManager().getUserId()
        
        let actionType = ActionType.getCoupons
        
        let url = UrlBuilder(baseUrl: "http://haseboty.com/doctor/public/api/CouponsByUser?")
        url.put("id_user", userId)
        
        requestConnection(action: actionType, url: url.build(), shouldCache: true)
    }
    
    func nearestDoctor(location: CLLocationCoordinate2D, idGender: Int, idSub: Int, distance: Int) {
        
        let actionType = ActionType.nearestDoctor
        
        let url = UrlBuilder(baseUrl: "http://haseboty.com/doctor/public/api/nearestDoctor?")
        url.put("latitude", location.latitude)
            .put("longitude", location.longitude)
            .put("distance", distance)
            .put("id_gender", idGender)
            .put("id_sub", idSub)
        
        requestConnection(action: actionType, url: url.build(), shouldCache: true)
    }
    
    func getDoctor(doctorId: Int) {
        
        let actionType = ActionType.getDoctorData
        
        let url = UrlBuilder(baseUrl: "http://haseboty.com/doctor/public/api/doctorData?")
            .put("id_doctor", doctorId)
            .put("type", LocalizationSystem.sharedInstance.getLanguage())
        
        requestConnection(action: actionType, url: url.build(), shouldCache: true)
    }
    
    func getReviewsBy(doctorId: Int) {
        
        let actionType = ActionType.getDoctorReviews
        
        let url = UrlBuilder(baseUrl: "http://haseboty.com/doctor/public/api/userRateData?")
        url.put("id_user", doctorId)
            .put("type", "doctor")
        
        requestConnection(action: actionType, url: url.build(), shouldCache: true)
    }
    
    func getReviewsBy(patientId: Int) {
        
        let actionType = ActionType.getDoctorReviews
        
        let url = UrlBuilder(baseUrl: "http://haseboty.com/doctor/public/api/userRateData?")
        url.put("id_user", patientId)
        .put("type", "client")
        
        requestConnection(action: actionType, url: url.build(), shouldCache: true)
    }
    
    func getDoctorLocation(doctorId: Int) {
        
        let actionType = ActionType.getDoctorLocation
        
        let url = UrlBuilder(baseUrl: "http://haseboty.com/doctor/public/api/doctorLocation?")
        url.put("id", doctorId)
        
        requestConnection(action: actionType, url: url.build(), shouldCache: false)
    }
    
    func mainCategories() {
        
        let actionType = ActionType.mainCategories
        
        let url = UrlBuilder(baseUrl: "http://haseboty.com/doctor/public/api/mainCategory?")
            .put("type", LocalizationSystem.sharedInstance.getLanguage())
        
        requestConnection(action: actionType, url: url.build(), shouldLoadFromCache: true)
    }
    
    func subCategoriesBy(mainId: Int) {
        
        let actionType = ActionType.subCategories
        
        let url = UrlBuilder(baseUrl: "http://haseboty.com/doctor/public/api/subCategoryByMain?")
        
        url.put("type", LocalizationSystem.sharedInstance.getLanguage())
            .put("id_main", mainId)
            .put("id_doctor_kind", "1")
        
        requestConnection(action: actionType, url: url.build(), shouldLoadFromCache: true)
    }
    
    func sendNotification(bookingId: Int, fcmToken: String!, kind: NotificationHandler.Kind, title: String, message: String) {
        
        if let fcmToken = fcmToken, !fcmToken.isEmpty {
            
        } else {
            return
        }
        
        var title : String = ""
        var kindName: String!
        
        switch kind {
        case .bookingStateStart:
            kindName = "3"
            title = "video_room_is_created"
            break
        case .bookingStateWorking:
            kindName = "4"
            title = "doctorArrive"
            break
        case .bookingStateDone:
            kindName = "5"
            title = "doctorFinished"
            break
        case .bookingStateCancel:
            if #available(iOS 10.0, *) {
                NotificationHandler.cancelNotificationFor(reservationId: bookingId)
            }
            kindName = "8"
            title = "reservationPatientCancel"
            break
        default:
            kindName = kind.rawValue
            
            if kind.rawValue == "bookingRequest" {
                title = "bookingRequestMessage"
            }
            if kind.rawValue == "bookingRequestOnline" {
                title = "newReservation"
            }
            if kind.rawValue == "video_room_is_created" {
                title = "video_room_is_created"
                return 
            }
            break
        }
        
        title = LocalizationSystem.sharedInstance.localizedStringForKey(key: title, comment: "")
        let message = ""
        
//        if title.elementsEqual("\(kind.rawValue)TitleD") {
//            return
//        }bookingStateStart
        
        let actionType = ActionType.notify
        
        let url = UrlBuilder(baseUrl: "http://haseboty.com/sendNotification/sendNotification.php?")
        
        url.put("reg_id[]", "\(fcmToken ?? "")")
            .put("data", "\(bookingId)")
            .put("kind", "\(kindName ?? "")")
            .put("title", "\(title)")
            .put("message", "\(message)")
            .put("FIREBASE_API_KEY", "AAAAg9tN8oI:APA91bE_9tV2K5V98_ZcimKSJ0Uk3EQ_qLIznI3SH7IFOjgjWCRxEdkwf-zTfIHFaJ1gN8z56GN3gghaxqR_WdlSBZASqwzjJdEGPqD2ewz9iIlkK387OWzcz20fpot1L48S6l1RTeak")
        
        requestConnection(action: actionType, url: url.build(), shouldCache: false)
    }
    
    func createRoom(bookingId: Int) {
        
        let userId = SettingsManager().getUserId()
        
        let actionType = ActionType.createRoom
        
        let url = UrlBuilder(baseUrl: "http://haseboty.com/doctor/public/api/createRoom?")
            .put("id_user", userId)
            .put("id_booking", bookingId)
        
        requestConnection(action: actionType, url: url.build(), shouldCache: false)
    }
    
    func rateBooking(bookingId: Int, rate: Int, review: String) {
        
        let userId = SettingsManager().getUserId()
        
        let actionType = ActionType.rateBooking
        
        let url = UrlBuilder(baseUrl: "http://haseboty.com/doctor/public/api/rateBooking?")
        
        url.put("id_user", userId)
            .put("rate", rate)
            .put("review", review.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)!)
            .put("id_booking", bookingId)
        
        requestConnection(action: actionType, url: url.build(), shouldCache: false)
    }
    
    func changePassword(to password: String) {
        
        let userId = SettingsManager().getUserId()
        
        let actionType = ActionType.updateUser
        
        let url = UrlBuilder(baseUrl: "http://haseboty.com/doctor/public/api/updateUser?")
            .put("id", userId)
            .put("password", password)
        
        requestConnection(action: actionType, url: url.build(), shouldCache: false)
    }
    
    func updateUser(fcmToken: String) {
        
        let actionType = ActionType.updateUser
        
        let url = UrlBuilder(baseUrl: "http://haseboty.com/doctor/public/api/updateUser?")
        
        let userId = SettingsManager().getUserId()
        
        url.put("id", userId)
            .put("fcm_token", fcmToken)
        
        requestConnection(action: actionType, url: url.build(), shouldCache: false)
    }
    
    private var user: User!
    
    private func updateUser(user: User, imageName image: String?) {
        
        let userId = SettingsManager().getUserId()
        
        let actionType = ActionType.updateUser
        
        let url = UrlBuilder(baseUrl: "http://haseboty.com/doctor/public/api/updateUser?")

        url.put("id", userId)
        .safePut("first_name_ar", user.firstName)
        .safePut("last_name_en", user.lastName)
        .safePut("first_name_ar", user.firstName)
        .safePut("last_name_en", user.lastName)
        .safePut("phone", user.phone)
        .safePut("email", user.email)
        if self.imageName != nil {
            url.safePut("image", self.imageName)
        }
        requestConnection(action: actionType, url: url.build(), shouldCache: false)
    }
    
    func updateUser(user: User, profileImage image: UIImage? = nil) {
        
        if let image = image {
            self.user = user
            uploadImage(file: image)
        } else {
            
            let userId = SettingsManager().getUserId()
            
            let actionType = ActionType.updateUser
            
            let url = UrlBuilder(baseUrl: "http://haseboty.com/doctor/public/api/updateUser?")
            
            url.put("id", userId)
                .safePut("first_name_ar", user.firstName)
                .safePut("last_name_ar", user.lastName)
                .safePut("first_name_en", user.firstName)
                .safePut("last_name_en", user.lastName)
                .safePut("phone", user.phone)
                .safePut("email", user.email)
            
            requestConnection(action: actionType, url: url.build(), shouldCache: false)
        }
    }
    
    private var imageName: String!
    
    private func uploadImage(file: UIImage) {
        
        let actionType = ActionType.uploadImage
        
        let url = UrlBuilder(baseUrl: "http://haseboty.com/doctor/public/images/uploadImage.php")
        
        imageName = "\(Date().timeIntervalSince1970).jpeg"
        
        requestConnection(action: actionType, method: "post", url: url.build(), body: nil, header: nil, image: resizeImage(image: file, newWidth: 300), imageKey: "file", fileName: imageName)
    }
    
    private func resizeImage(image: UIImage, newWidth: CGFloat) -> UIImage {
        
        let scale = newWidth / image.size.width
        
        let newHeight = image.size.height * scale
        
        UIGraphicsBeginImageContext(CGSize(width: newWidth, height: newHeight))
        
        image.draw(in: CGRect(x: 0, y: 0, width: newWidth, height: newHeight))
        
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage ?? image
    }
    
    private var bookingId: Int!
    private var payMobId: Int!
    private var typeId: Int!
    private var totalMoney: Int!
    private var userId: Int!
    
    func addPayment(bookingId: Int, payMobId: Int! = nil, typeId: Int, totalMoney: Int, kindId: Int, subId: Int, userId: Int) {
        
        self.bookingId = bookingId
        self.payMobId = payMobId
        self.typeId = typeId
        self.totalMoney = totalMoney
        self.userId = userId
        
        let actionType = ActionType.doctorPercentageMoney
        
        let url = UrlBuilder(baseUrl: "http://haseboty.com/doctor/public/api/doctorPercentageMoney?")
            .put("id_doctor_kind", kindId)
            .put("id_sub", subId)
        
        requestConnection(action: actionType, url: url.build(), shouldCache: false)
    }
    
    private func addPayment(bookingId: Int, payMobId: Int! = nil, adminMoney: Double, doctorMoney: Double, typeId: Int, userId: Int) {
        
        let actionType = ActionType.addPayment
        
        let url = UrlBuilder(baseUrl: "http://haseboty.com/doctor/public/api/addPayment?")
        
        url.put("id_user", userId)
            .put("type", "depet")
            .put("total_money", adminMoney + doctorMoney)
            .put("id_payment_way", typeId)
            .put("id_booking", bookingId)
            .put("admin_money", adminMoney)
            .put("doctor_money", doctorMoney)
        
        if let payMobId = payMobId {
            
            url.put("payMob_Id", payMobId)
        }
        
        requestConnection(action: actionType, url: url.build(), shouldCache: false)
    }
    
    func getUserData(userId: Int) {
        
        let actionType = ActionType.getUserData
        
        let url = UrlBuilder(baseUrl: "http://haseboty.com/doctor/public/api/clientData?")
            .put("id_client", userId)
            .put("type", LocalizationSystem.sharedInstance.getLanguage())
        
        requestConnection(action: actionType, url: url.build(), shouldCache: true)
    }
    
    func checkCopoun(copounId: Int)  {
        
        let actionType = ActionType.checkCoupon
        
        let url = UrlBuilder(baseUrl: "http://haseboty.com/doctor/public/api/checkCoupon?")
            .put("id", copounId)
        
        requestConnection(action: actionType, url: url.build(), shouldCache: true)
    }
    
    func checkCopoun(code: String)  {
        
        let actionType = ActionType.checkCoupon
        
        let url = UrlBuilder(baseUrl: "http://haseboty.com/doctor/public/api/checkCoupon?")
        url.put("code", code)
        
        requestConnection(action: actionType, url: url.build(), shouldCache: true)
    }
    
    func checkCopoun(code: String, id_user: Int)  {
        
        let actionType = ActionType.checkCoupon
        
        let url = UrlBuilder(baseUrl: "http://haseboty.com/doctor/public/api/checkCouponNew?")
        url.put("code", code)
        url.put("id_user", id_user)
        
        requestConnection(action: actionType, url: url.build(), shouldCache: true)
    }
    
    override func onPreExecute(action: Any) {
        delegate.onPreExecute(action: action as! ContentSession.ActionType)
    }
    
    func onPreExecute(action: ActionType) {
        delegate.onPreExecute(action: action)
    }
    
    override func onSuccess(action: Any, response: URLResponse!, data: Data!) {
        
        let actionType: ActionType = action as! ContentSession.ActionType
        let res = String(data: data, encoding: .utf8)
        
        print(data)
        print(response)
        
        print(res ?? "")
        
        do {
            
            var jsonObject = [String: Any]()
            var jsonArray = [[String: Any]]()
            if let object = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String: Any] {
                
                jsonObject = object
            } else if let array = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [[String: Any]] {
                
                jsonArray = array
            }
            
            let success = jsonObject["status"] as? Bool ?? true 
            
            if success {
                switch actionType {
                case .getDoctorFilters:
                    
                    jsonArray = jsonObject["spoken_language"] as! [[String: Any]]
                    
                    var languages = [BaseModel]()
                    
                    for item in jsonArray {
                        
                        let language = BaseModel(id: item["id"] as! Int, name: item["name"] as! String)
                        
                        languages.append(language)
                    }
                    
                    delegate.onPostExecute(status: Status(200, true, ""), action: .getDoctorLanguages, response: languages)
                    
                    jsonArray = jsonObject["gender"] as! [[String: Any]]
                    
                    var genders = [BaseModel]()
                    
                    for item in jsonArray {
                        
                        let gender = BaseModel(id: item["id"] as! Int, name: item["name"] as! String)
                        
                        genders.append(gender)
                    }
                    
                    delegate.onPostExecute(status: Status(200, true, ""), action: .getDoctorGenders, response: genders)
                    
                    jsonArray = jsonObject["subCategory"] as! [[String: Any]]
                    
                    var categories = [Category]()
                    
                    for item in jsonArray {
                        
                        let category = Category(jsonDic: item)
                        
                        categories.append(category)
                    }
                    
                    delegate.onPostExecute(status: Status(200, true, ""), action: .getDoctorSubCategories, response: categories)
                    break
                case .getDoctors:
                    
                    jsonArray = jsonObject["users"] as! [[String: Any]]
                    
                    var doctors = [Doctor]()
                    
                    for item in jsonArray {
                        
                        if let doctor = try? Doctor(jsonDic: item) {
                            
                            doctors.append(doctor)
                        }
                    }
                    
                    delegate.onPostExecute(status: Status(200, true, ""), action: actionType, response: doctors)
                    break
                case .getDoctorsForChat :
                    jsonArray = jsonObject["users"] as! [[String: Any]]
                    
                    var doctors = [Doctor]()
                    
                    for item in jsonArray {
                        
                        if let doctor = try? Doctor(jsonDic: item) {
                            
                            doctors.append(doctor)
                        }
                    }
                    
                    delegate.onPostExecute(status: Status(200, true, ""), action: actionType, response: doctors)
                    break
                case .getDoctorSchedule:
                    
                    jsonArray = jsonObject["schedule"] as! [[String: Any]]
                    
                    var schedules = [Schedule]()
                    
                    for item in jsonArray {
                        
                        if let schedule = try? Schedule(jsonDic: item) {
                            
                            schedules.append(schedule)
                        }
                    }
                    
                    delegate.onPostExecute(status: Status(200, true, ""), action: actionType, response: schedules)
                    break
                case .getReservations:
                    
                    var reservations = [Reservation]()
                    
                    jsonArray = jsonObject["booking"] as! [[String: Any]]
                    
                    for item in jsonArray {
                        
                        if let Reservation = try? Reservation(jsonDic: item) {
                        
                            reservations.append(Reservation)
                        }
                    }
                    
                    delegate.onPostExecute(status: Status(200, true, ""), action: actionType, response: reservations)
                    break
                case .getBookingData:
                    
                    let booking = jsonObject["booking"] as! [String: Any]
                    
                    let reservation = Reservation(jsonDic: booking)
                    
                    delegate.onPostExecute(status: Status(200, true, ""), action: actionType, response: reservation)
                    break
                case .addBooking:
                    
                    let booking = jsonObject["booking"] as! [String: Any]
                    
                    let reservation = Reservation(jsonDic: booking)
                    
                    delegate.onPostExecute(status: Status(200, true, ""), action: actionType, response: reservation)
                    break
                case .updateBooking:
                    
                    let booking = jsonObject["booking"] as! [String: Any]
                    
                    let reservation = Reservation(jsonDic: booking)
                    
                    delegate.onPostExecute(status: Status(200, true, ""), action: actionType, response: reservation)
                    break
                case .getDoctorData:
                    
                    jsonArray = jsonObject["users"] as! [[String: Any]]
                    
                    for item in jsonArray {
                        
                        if let doctor = try? Doctor(jsonDic: item) {
                            
                            delegate.onPostExecute(status: Status(200, true, ""), action: actionType, response: doctor)
                            return
                        }
                    }
                    
                    delegate.onPostExecute(status: Status(404, false, ""), action: actionType, response: nil)
                    break
                case .getDoctorReviews:
                    
                    jsonArray = jsonObject["reviews"] as! [[String: Any]]
                    
                    var reviews = [Review]()
                    
                    for item in jsonArray {
                        
                        if let review = try? Review(jsonDic: item) {
                            
                            reviews.append(review)
                        }
                    }
                    
                    delegate.onPostExecute(status: Status(200, true, ""), action: actionType, response: reviews)
                    break
                    
                case .addSchedule:
                    delegate.onPostExecute(status: Status(200, true, ""), action: actionType, response: nil)
                    break
                case .getCoupons:
                    
                    jsonArray = jsonObject["coupons"] as! [[String: Any]]
                    
                    var coupons = [Coupon]()
                    
                    for item in jsonArray {
                        
                        if let coupon = try? Coupon(jsonDic: item) {
                            
                            coupons.append(coupon)
                        }
                    }
                    
                    delegate.onPostExecute(status: Status(200, true, ""), action: actionType, response: coupons)
                    break
                case .nearestDoctor:
                    
                    jsonArray = jsonObject["user"] as! [[String: Any]]
                    
                    var doctors = [Doctor]()
                    
                    for item in jsonArray {
                        
                        if let doctor = try? Doctor(jsonDic: item) {
                            
                            doctors.append(doctor)
                        }
                    }
                    
                    delegate.onPostExecute(status: Status(200, true, ""), action: actionType, response: doctors)
                    break
                case .getDoctorLocation:
                    
                    if let userLocation = jsonObject["userLocation"] as? [String: Any], let lat = userLocation["latitude"] as? NSString, let lng = userLocation["longitude"] as? NSString {
                        
                        let location = CLLocationCoordinate2D(latitude: lat.doubleValue, longitude: lng.doubleValue)
                        
                        delegate.onPostExecute(status: Status(200, true, ""), action: actionType, response: location)
                    } else {
                        
                        delegate.onPostExecute(status: Status(404, false, LocalizationSystem.sharedInstance.localizedStringForKey(key: "no_location_found", comment: "")), action: actionType, response: nil)
                    }
                    break
                case .mainCategories:
                    
                    jsonArray = jsonObject["mainCategory"] as! [[String: Any]]
                    
                    var mainCategories = [MainCategory]()
                    
                    for item in jsonArray {
                        
                        if let mainCategory = try? MainCategory(jsonDic: item) {
                            
                            mainCategories.append(mainCategory)
                        }
                    }
                    
                    delegate.onPostExecute(status: Status(200, true, ""), action: actionType, response: mainCategories)
                    break
                case .subCategories:
                    
                    jsonArray = jsonObject["subCategory"] as! [[String: Any]]
                    
                    var subCategories = [SubCategory]()
                    
                    for item in jsonArray {
                        
                        if let subCategory = try? SubCategory(jsonDic: item) {
                            
                            subCategories.append(subCategory)
                        }
                    }
                    
                    delegate.onPostExecute(status: Status(200, true, ""), action: actionType, response: subCategories)
                    break
                case .createRoom:
                    
                    let videoToken = jsonObject["video_token"] as! String
                    
                    delegate.onPostExecute(status: Status(200, true, ""), action: actionType, response: videoToken)
                    break
                case .doctorPercentageMoney:
                    
                    var online = (jsonObject["online_percentage"] as! NSString).doubleValue
                    let home = (jsonObject["home_percentage"] as! NSString).doubleValue
                    
                    if online < 1 {
                        online = home
                    }
                    
                    let adminMoney = Double(totalMoney!) * online / 100
                    let doctorMoney = Double(totalMoney) - adminMoney
                    
                    addPayment(bookingId: bookingId, payMobId: payMobId, adminMoney: adminMoney, doctorMoney: doctorMoney, typeId: typeId, userId: userId)
                    break
                case .addPayment:
                    
                    delegate.onPostExecute(status: Status(200, true, ""), action: actionType, response: nil)
                    break
                case .getUserData:
                    
                    jsonArray = jsonObject["users"] as! [[String: Any]]
                    
                    var user: User!
                    for item in jsonArray {
                        
                        if let usr = try? User(jsonDic: item) {
                            
                            if usr.id == SettingsManager().getUserId() {
                                
                                SettingsManager().updateUser(user: usr)
                            }
                            
                            user = usr
                            break
                        }
                    }
                    
                    delegate.onPostExecute(status: Status(200, user != nil, ""), action: actionType, response: user)
                    break
                case .uploadImage:
                    
                    updateUser(user: user, imageName: imageName)
                    break
                case .checkCoupon:
                    
                    let success = jsonObject["status"] as! Bool
                    
                    let couponDic = jsonObject["coupon"] as! [String: Any]
                    
                    let coupon = try? Coupon(jsonDic: couponDic)
                    
                    delegate.onPostExecute(status: Status(200, success, ""), action: actionType, response: coupon)
                    break
                default:
                    
                    delegate.onPostExecute(status: Status(200, true, ""), action: actionType, response: nil)
                    break
                }
            } else {
                let code = jsonObject["error_code"] as? Int ?? -1
                var codeMessage = "..."
                
                if let message = jsonObject["messages"] as? [String: Any],
                    let messages = message[message.keys.first!] as? [String] {
                    
                    codeMessage = messages[0]
                } else if let message = jsonObject["messages"] as? String {
                    
                    codeMessage = message
                }
                
                switch actionType {
                case .doctorPercentageMoney:
                    
                    delegate.onPostExecute(status: Status(code, false, codeMessage), action: .addPayment, response: nil)
                    break
                case .uploadImage:
                    
                    delegate.onPostExecute(status: Status(code, false, codeMessage), action: .updateUser, response: nil)
                    break
                default:
                    
                    onFailure(action: actionType, error: NSError(domain: codeMessage, code: code, userInfo: nil))
                    break
                }
            }
        } catch {
            print(error.localizedDescription)
            onFailure(action: actionType, error: error as NSError)
        }
    }
    
    override func onFailure(action: Any, error: NSError) {
        delegate.onPostExecute(status: Status(error: error), action: action as! ContentSession.ActionType, response: nil)
    }
}

public protocol ContentDelegate {
    
    func onPreExecute(action: ContentSession.ActionType)
    
    func onPostExecute(status: BaseUrlSession.Status, action: ContentSession.ActionType, response: Any!)
}

//  NotificationHandler.swift
//  balto
//
//  Created by Abanoub Osama on 5/19/18.
//  Copyright © 2018 Abanoub Osama. All rights reserved.
//

import Foundation
import UIKit
import FirebaseMessaging
import UserNotifications

public class NotificationHandler {
    
    public enum Kind: String {
        case bookingRequest, bookingRequestMessage, bookingRequestOnline, newReservation, video_call, video_room_is_created, bookingStateStart, doctorStart, bookingStateWorking, doctorArrive, bookingStateDone, doctorFinished, bookingStateCancel
    }
    
    @available(iOS 10.0, *)
    static func cancelNotificationFor(reservationId: Int) {
        
        let notificationCenter = UNUserNotificationCenter.current()
        
        notificationCenter.removePendingNotificationRequests(withIdentifiers: ["reservation1min\(reservationId)",  "reservation15mins\(reservationId)"])
    }
    
    @available(iOS 10.0, *)
    static func scheduleNotificationFor(reservation: Reservation) {
        
        let reservationDate = DateUtils.getDate(dateString: reservation.date, dateFormat: "\(DateUtils.SERVER_DATE_FORMAT) \(DateUtils.SERVER_TIME_SHORT_FORMAT)")
        
        //        let reservationDate = Date().addingTimeInterval(16 * 60)
        
        let notification1Min = reservationDate.addingTimeInterval(-1 * 60)
        
        let notification15Mins = reservationDate.addingTimeInterval(-15 * 60)
        
        if false && notification1Min > Date() {
            
            let content1Min = UNMutableNotificationContent()
            content1Min.title = LocalizationSystem.sharedInstance.localizedStringForKey(key: "1MinNotificationTitle", comment: "")
            content1Min.body = LocalizationSystem.sharedInstance.localizedStringForKey(key: "1MinNotificationBody", comment: "")
            content1Min.sound = UNNotificationSound(named: "skyline.mp3")
            
            content1Min.userInfo["time_in_secs"] = notification1Min.timeIntervalSince1970
            content1Min.userInfo["showNotification"] = false
            
            var notification = [String: Any]()
            notification["title"] = content1Min.title
            notification["body"] = content1Min.body
            notification["sound"] = "skyline.mp3"
            content1Min.userInfo["notification"] = notification
            
            var data = [String: Any]()
            
            var payload = [String: Any]()
            payload["kind"] = "bookingRequest"
            payload["data"] = "\(reservation.id)"
            
            data["payload"] = payload
            content1Min.userInfo["data"] = data
            
            let identifier1Min = "reservation1min\(reservation.id)"
            
            schedule(date: notification1Min, identifier: identifier1Min, content: content1Min)
        } else {
            
            return
        }
        
        if notification15Mins > Date() {
            
            let content15Mins = UNMutableNotificationContent()
            content15Mins.title = LocalizationSystem.sharedInstance.localizedStringForKey(key: "15MinsNotificationTitle", comment: "")
            content15Mins.body = LocalizationSystem.sharedInstance.localizedStringForKey(key: "15MinsNotificationBody", comment: "")
            content15Mins.sound = UNNotificationSound(named: "skyline.mp3")
            
            var notification = [String: Any]()
            notification["title"] = content15Mins.title
            notification["body"] = content15Mins.body
            notification["sound"] = "skyline.mp3"
            content15Mins.userInfo["notification"] = notification
            
            content15Mins.userInfo["time_in_secs"] = notification15Mins.timeIntervalSince1970
            content15Mins.userInfo["showNotification"] = false
            
            var data = [String: Any]()
            
            var payload = [String: Any]()
            payload["kind"] = "bookingRequest"
            payload["data"] = "\(reservation.id)"
            
            data["payload"] = payload
            content15Mins.userInfo["data"] = data
            
            let identifier15Mins = "reservation15mins\(reservation.id)"
            
            schedule(date: notification15Mins, identifier: identifier15Mins, content: content15Mins)
        }
    }
    
    @available(iOS 10.0, *)
    private static func schedule(date: Date, identifier: String, content: UNMutableNotificationContent) {
        
        let calendar = Calendar.current
        
        var dateComponents = DateComponents()
        dateComponents.calendar = calendar
        dateComponents.year = calendar.component(.year, from: date)
        dateComponents.day = calendar.component(.day, from: date)
        dateComponents.hour = calendar.component(.hour, from: date)
        dateComponents.minute = calendar.component(.minute, from: date)
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
        
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
        
        let notificationCenter = UNUserNotificationCenter.current()
        
        notificationCenter.getPendingNotificationRequests { (requests) in
            
            if let request = requests.first(where: { (request) -> Bool in
                
                return request.identifier == identifier
            }) {
                
                let requestId = request.identifier
                let requestTime = request.content.userInfo["time_in_secs"] as? TimeInterval
                let time = date.timeIntervalSince1970
                
                if let requestTime = requestTime, time == requestTime {
                    // reservation notification is added with the same time
                } else {
                    
                    notificationCenter.removePendingNotificationRequests(withIdentifiers: [identifier])
                    
                    notificationCenter.add(request) { (error) in
                        
                        if let e = error {
                            
                            print("\n\n\n\n\n\(e.localizedDescription)\n\n\n\n\n")
                        }
                    }
                }
            } else {
                
                notificationCenter.add(request) { (error) in
                    
                    if let e = error {
                        
                        print("\n\n\n\n\n\(e.localizedDescription)\n\n\n\n\n")
                    }
                }
            }
        }
    }
    
    @discardableResult
    public static func handle(notification: [AnyHashable: Any], showNotification: Bool = true) -> Bool {
        
        let userInfo = notification
        
        var data = [String: Any]()
        var payload = [String: Any]()
        if let dataString = userInfo["data"] as? String, let d = dataString.data(using: String.Encoding.utf8) {
            do {
                data = try JSONSerialization.jsonObject(with: d, options: []) as! [String: Any]
                if let p = data["payload"] as? [String: Any] {
                    
                    payload = p
                } else {
                    return false
                }
            } catch {
                print("\n\n\n\nuserInfo:\(error)\n\n\n\n")
                return false
            }
        } else {
            return false
        }
        let kindName = payload["kind"] as? String ?? ""
        
        var kind: Kind!
        if let k = Kind(rawValue: kindName) {
            
            kind = k
        } else {
            
            switch kindName {
            case "3":
                kind = .bookingStateStart
                break
            case "4":
                kind = .bookingStateWorking
                break
            case "5":
                kind = .bookingStateDone
                break
            case "6", "7", "8":
                kind = .bookingStateCancel
                break
            default:
                break
            }
        }
        
        var vc: UIViewController!
        let title = LocalizationSystem.sharedInstance.localizedStringForKey(key: "\(kind?.rawValue ?? "")Title", comment: "")
        let body = LocalizationSystem.sharedInstance.localizedStringForKey(key: "\(kind?.rawValue ?? "")Body", comment: "")
        
        if let kind = kind {
            
            switch kind {
            case .bookingRequest:
                
                if let reservationId = (payload["data"] as? NSString)?.integerValue {
                    
                    let storyboard = UIStoryboard(name: "Main", bundle: nil)
                    vc = storyboard.instantiateViewController(withIdentifier: "ReservationsViewController")
                } else {
                    
                    return false
                }
                break
            case .video_call:
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                vc = storyboard.instantiateViewController(withIdentifier: "ReservationsViewController")
                break
            case .bookingStateStart, .bookingStateWorking:
                
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                vc = storyboard.instantiateViewController(withIdentifier: "ReservationsViewController")
                break
            case .bookingStateDone:
                if let reservationId = (payload["data"] as? NSString)?.integerValue {
                    
                    vc = AddReviewViewController(bookingId: reservationId)
                } else {
                    
                    return false
                }
                break
            default:
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                vc = storyboard.instantiateViewController(withIdentifier: "ReservationsViewController")
                break
            }
        }
        
        if showNotification && userInfo["showNotification"] as? Bool ?? true {
            
            var userInfo = userInfo
            userInfo["showNotification"] = true
            NotificationHandler.showNotification(title: title, body: body, userInfo: userInfo)
        } else {
            
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            
            if let vc = vc, let window = appDelegate.window {
                
                if let root = window.rootViewController {
                    var currentViewController = root
                    
                    if let nav = currentViewController as? UINavigationController {
                        
                        if vc is AddReviewViewController, let topVC = nav.viewControllers.last {
                            
                            if type(of: topVC) != type(of: vc) {
                            
                                topVC.present(vc, animated: true, completion: nil)
                            }
                        } else {
                        
                            nav.show(vc, sender: nil)
                        }
                    } else {
                        
                        while let presentedViewController = currentViewController.presentedViewController {
                            currentViewController = presentedViewController
                        }
                        
                        currentViewController.present(vc, animated: true, completion: nil)
                    }
                } else {
                    
                    window.rootViewController = vc
                    window.makeKeyAndVisible()
                }
            } else {
                
                return false
            }
        }
        
        return true
    }
    
    private static func showNotification(title: String, body: String, userInfo: [AnyHashable: Any]) {
        
        if #available(iOS 10.0, *) {
            
            let content = UNMutableNotificationContent()
            let requestIdentifier = Bundle.main.bundleIdentifier!
            
            content.badge = 0
            content.title = title
            content.body = body
            
            content.sound = UNNotificationSound(named: "skyline.mp3")
            
            var notification = userInfo
            notification["showNotification"] = false
            
            content.userInfo = notification
            
            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
            
            let request = UNNotificationRequest(identifier: requestIdentifier, content: content, trigger: trigger)
            
            UNUserNotificationCenter.current().add(request) { (error:Error?) in
                
                if error != nil {
                    print(error?.localizedDescription)
                }
                print("Notification Register Success")
            }
        } else {
            // Fallback on earlier versions
        }
    }
}

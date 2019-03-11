//
//  Constants.swift
//  Syariti
//
//  Created by Mena on 9/17/17.
//  Copyright © 2017 Mena. All rights reserved.
//

import Foundation
import UIKit
import CoreLocation
import MapKit

public class Constants {

    public static let override = false
    
    public static let API_KEY = ""
    
    public static let DEVICE_TYPE = 2
    
    public static let DOMAIN_NAME = ""
    private static let version = ""
    
    public static let BASE_URL = "\(DOMAIN_NAME)/api/\(version)"
    
    public static let CONTACT_PHONE = "00201201146214"
    public static let CONTACT_EMAIL = "info@elbalto.com"
    public static let WEBSITE_URL = "http://www.elbalto.com/"
    
    public static var language: String {
        
        get {
            
            return Locale.current.identifier.contains("ar") ? "ar" : "en"
        }
    }
    
    static func getApplicationLink(coupon: Coupon) -> [String] {
        return [ "Download ElBalto now! and enjoy 50% off on your 1st medical service by using this code:\(coupon.name)\nhttps://itunes.apple.com/gb/app/revise-it/id1387785206?mt=8" ]
    }
    
    public static func getAppLanguage() -> String {
        
        let defaults = UserDefaults.standard
        
        if let langs = defaults.stringArray(forKey: "AppleLanguages") {
            
            switch langs[0] {
            case "en-AL":
                return "عربي"
            default:
                break
            }
        }
        
        return "English"
    }
    
    public static func setAppLanguage(language: String) {
        
        let defaults = UserDefaults.standard
        switch language {
        case "ar":
            defaults.set(["ar", "en"], forKey: "AppleLanguages")
            break
        default:
            defaults.set(["en", "ar"], forKey: "AppleLanguages")
            break
        }
        defaults.synchronize()
    }
    
    public static func openMapForPlace(location: CLLocationCoordinate2D) {
        
        let regionDistance:CLLocationDistance = 10000
        let coordinates = CLLocationCoordinate2DMake(location.latitude, location.longitude)
        let regionSpan = MKCoordinateRegionMakeWithDistance(coordinates, regionDistance, regionDistance)
        let options = [
            MKLaunchOptionsMapCenterKey: NSValue(mkCoordinate: regionSpan.center),
            MKLaunchOptionsMapSpanKey: NSValue(mkCoordinateSpan: regionSpan.span)
        ]
        let placemark = MKPlacemark(coordinate: coordinates, addressDictionary: nil)
        let mapItem = MKMapItem(placemark: placemark)
        mapItem.name = "Patient"
        mapItem.openInMaps(launchOptions: options)
    }
}

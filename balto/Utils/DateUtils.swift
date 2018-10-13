//
//  DateUtils.swift
//  kora
//
//  Created by Abanoub Osama on 3/3/18.
//  Copyright © 2018 Abanoub Osama. All rights reserved.
//

import Foundation

class DateUtils {
    
    public static let DAY_INTERVAL = TimeInterval(24 * 60 * 60)
    
    public static let SERVER_DATE_FORMAT = "yyyy-MM-dd"
    public static let SERVER_DATE_TIME_FORMAT = "yyyy-MM-dd HH:mm"
    public static let SERVER_TIME_SHORT_FORMAT = "HH:mm"
    
    public static let APP_DATE_FORMAT = "d MMM, yyyy"
    public static let APP_DATE_SHORT_FORMAT = "dd.MM"
    public static let APP_TIME_FORMAT = "hh:mm a"
    public static let APP_DATE_TIME_FORMAT = "hh:mm a E, MMM.d yyyy"
    
    public static func getDate(dateString: String, dateFormat: String) -> Date {
        
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en")
        formatter.dateFormat = dateFormat
        
        return formatter.date(from: dateString) ?? Date()
    }
    
    public static func convertDateFormat(dateString: String, sourceFormat: String, destinationFormat: String) -> String {
        let sourceFormatter = DateFormatter()
        sourceFormatter.locale = Locale(identifier: "en")
        sourceFormatter.dateFormat = sourceFormat
        
        let destinationFormatter = DateFormatter()
        destinationFormatter.locale = Locale(identifier: "en")
        destinationFormatter.dateFormat = destinationFormat
        
        if let date = sourceFormatter.date(from: dateString) {
            return destinationFormatter.string(from: date)
        } else {
            return dateString
        }
    }
    
    public static func getServerDateString(appDateString: String) -> String {
        
        return convertDateFormat(dateString: appDateString, sourceFormat: APP_DATE_FORMAT, destinationFormat: SERVER_DATE_FORMAT)
    }
    
    public static func getServerDate(dateString: String) -> Date {
        
        return getDate(dateString: dateString, dateFormat: SERVER_DATE_FORMAT)
    }
    
    public static func getServerDateTime(dateString: String) -> Date {
        
        return getDate(dateString: dateString, dateFormat: SERVER_DATE_TIME_FORMAT)
    }
    
    public static func getAppDate(dateString: String) -> Date {
        
        return getDate(dateString: dateString, dateFormat: APP_DATE_FORMAT)
    }
    
    public static func getServerDateString(timeInMillis: TimeInterval) -> String {
        
        let date = Date(timeIntervalSince1970: timeInMillis)
        
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en")
        formatter.dateFormat = SERVER_DATE_FORMAT
        
        return formatter.string(from: date)
    }
    
    public static func getServerDateTimeString(timeInMillis: TimeInterval) -> String {
        
        let date = Date(timeIntervalSince1970: timeInMillis)
        
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en")
        formatter.dateFormat = SERVER_DATE_TIME_FORMAT
        
        return formatter.string(from: date)
    }
    
    public static func getAppDateString(timeInMillis: TimeInterval) -> String {
        
        let date = Date(timeIntervalSince1970: timeInMillis)
        
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en")
        formatter.dateFormat = APP_DATE_FORMAT
        
        return formatter.string(from: date)
    }
    
    public static func getAppDateTimeString(timeInMillis: TimeInterval) -> String {
        
        let date = Date(timeIntervalSince1970: timeInMillis)
        
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en")
        formatter.dateFormat = APP_DATE_TIME_FORMAT
        
        return formatter.string(from: date)
    }
    
    public static func getAppDateStringFromServerDateTime(serverDateTime: String) -> String {
        
        return convertDateFormat(dateString: serverDateTime, sourceFormat: SERVER_DATE_TIME_FORMAT, destinationFormat: APP_DATE_FORMAT);
    }
    
    public static func getAppDateTimeString(serverDate: String) -> String {
        
        return convertDateFormat(dateString: serverDate, sourceFormat: SERVER_DATE_TIME_FORMAT, destinationFormat: APP_DATE_TIME_FORMAT);
    }
    
    public static func getAppDateString(serverDate: String) -> String {
        
        return convertDateFormat(dateString: serverDate, sourceFormat: SERVER_DATE_FORMAT, destinationFormat: APP_DATE_FORMAT);
    }
    
    public static func getTimeAgoString(date: Date) -> String {
        
        let interval = Calendar.current.dateComponents([Calendar.Component.day, Calendar.Component.hour, Calendar.Component.minute], from: date, to: Date())
        
        if let day = interval.day, day > 6 {
            return DateUtils.getAppDateTimeString(timeInMillis: date.timeIntervalSince1970)
        } else if let day = interval.day, day > 0 {
            return day == 1 ? "\(day) \(LocalizationSystem.sharedInstance.localizedStringForKey(key: "day_ago", comment: ""))" :
            "\(day) \(LocalizationSystem.sharedInstance.localizedStringForKey(key: "days_ago", comment: ""))"
        } else if let hour = interval.hour, hour > 0 {
            return hour == 1 ? "\(hour) \(LocalizationSystem.sharedInstance.localizedStringForKey(key: "hour_ago", comment: ""))" :
            "\(hour) \(LocalizationSystem.sharedInstance.localizedStringForKey(key: "hours_ago", comment: ""))"
        } else if let min = interval.minute, min > 0 {
            return min == 1 ? "\(min) \(LocalizationSystem.sharedInstance.localizedStringForKey(key: "minute_ago", comment: ""))" :
            "\(min) \(LocalizationSystem.sharedInstance.localizedStringForKey(key: "minutes_ago", comment: ""))"
        } else {
            return LocalizationSystem.sharedInstance.localizedStringForKey(key: "just_now", comment: "")
        }
    }
}

//
//  UrlBuilder.swift
//  kora
//
//  Created by Abanoub Osama on 3/9/18.
//  Copyright © 2018 Abanoub Osama. All rights reserved.
//

import Foundation

class UrlBuilder {
    
    private var url: String
    
    init(baseUrl: String) {
        
        if !baseUrl.hasSuffix("?") {
            self.url = "\(baseUrl)?"
        } else {
            self.url = baseUrl
        }
    }
    
    @discardableResult
    func put(_ key: String, _ value: Any) -> UrlBuilder {
//        guard !key.isEmpty, !"\(value)".isEmpty else {
//            return self
//        }
        if url.hasSuffix("?") {
            
            url.append("\(key)=\(value)")
        } else {
            
            url.append("&\(key)=\(value)")
        }
        
        return self
    }
    
    @discardableResult
    func safePut(_ key: String, _ value: Any!) -> UrlBuilder {
        //        guard !key.isEmpty, !"\(value)".isEmpty else {
        //            return self
        //        }
        if let value = value, url.hasSuffix("?") {
            
            url.append("\(key)=\(value)")
        } else if let value = value {
            
            url.append("&\(key)=\(value)")
        }
        
        return self
    }
    
    func build() -> URL! {
        
        return URL(string: url.replacingOccurrences(of: " ", with: "%20"))
    }
    
    func buildString() -> String {
        
        return build()?.absoluteString ?? ""
    }
}

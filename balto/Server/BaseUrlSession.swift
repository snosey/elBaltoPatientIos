//
//  BaseSession.swift
//  Barek
//
//  Created by Abanoub Osama on 12/11/16.
//  Copyright © 2016 Abanoub Osama. All rights reserved.
//

import UIKit
import Alamofire

public class BaseUrlSession: NSObject {
    
    public struct Status {
        
        var code: Int
        var success: Bool
        var message: String
        
        init(error: NSError) {
            code = error.code
            success = false
            message = error.domain
        }
        
        init(_ c: Int, _ s: Bool, _ m: String) {
            code = c
            success = s
            message = m
        }
    }
    
    public enum Actions {
    }
    
    func requestConnection(action: Any, url: URL, shouldCache: Bool) {
        
        requestConnection(action: action, method: "GET", url: url, body: nil, header: nil, shouldCache: shouldCache, shouldLoadFromCache: false)
    }
    
    func requestConnection(action: Any, url: URL, shouldCache: Bool, completion: @escaping (_ success: Bool?, _ failure: Error?) -> Void ) {
        requestConnection(action: action, url: url, shouldLoadFromCache: shouldCache) { (success, error) in
            if error != nil {
                completion(false, error)
            }else {
                completion(true, nil)
            }
            
        }
    }
    
    func requestConnection(action: Any, method: String, url: URL, body: [String: Any]!, shouldCache: Bool) {
        requestConnection(action: action, method: method, url: url, body: body, header: nil, shouldCache: shouldCache, shouldLoadFromCache: false)
    }
    
    func requestConnection(action: Any, method: String, url: URL, body: [String: Any]!, header: [String: String]!, shouldCache: Bool) {
        requestConnection(action: action, method: method, url: url, body: body, header: header, shouldCache: shouldCache, shouldLoadFromCache: false)
    }
    
    // start ........
    func requestConnection(action: Any, method: String, url: URL, body: [String: Any]!, header: [String: String]! , image : UIImage , imageKey: String ) {
        
        onPreExecute(action: action)
        
        let mHeader = header ?? [String: String]()
        
        
        let mBody = body ?? [String: Any]()
        
        let method = HTTPMethod(rawValue: method.uppercased())!
        
        let urlRequest = try! URLRequest(url: url, method: method, headers: mHeader)
        
        let imgData = UIImageJPEGRepresentation(image, 1)!
        
        Alamofire.upload(multipartFormData: { (data) in
          //  data.append(imgData, withName: "image")
            data.append(imgData, withName: imageKey, fileName: "im.jpg", mimeType: "image/jpg")

            for (key, value) in mBody {
                data.append(String(describing: value).data(using: .utf8)!, withName: key)
            }
        }, with: urlRequest) { (result) in
            
            switch result {
            case .success(let upload, _, _):
                
                upload.uploadProgress(closure: { (progress) in
                    print("Upload Progress: \(progress.fractionCompleted)")
                })
                
                upload.responseJSON { response in
                    self.onSuccess(action: action, response: response.response, data: response.data!)
                }
                
            case .failure(let encodingError):
                print(encodingError)
                if !NetworkReachabilityManager()!.isReachable {
                    
                    self.onFailure(action: action, error: NSError(domain: LocalizationSystem.sharedInstance.localizedStringForKey(key: "FailToConnected", comment: ""), code: -1, userInfo: nil))
                } else {
                    self.onFailure(action: action, error: encodingError as NSError)
                }
                
            }
        }
    }
    
    func requestConnection(action: Any, method: String = "get", url: URL, body: [String: Any]! = nil, header: [String: String]! = nil, shouldCache: Bool = true, shouldLoadFromCache: Bool) {
        
        
        onPreExecute(action: action)
        
        let mHeader = header ?? [String: String]()

        
        var cachePolicy: URLRequest.CachePolicy!
        if shouldLoadFromCache {
            
            cachePolicy = URLRequest.CachePolicy.returnCacheDataElseLoad
        } else if shouldCache {
            
            cachePolicy = URLRequest.CachePolicy.reloadIgnoringCacheData
        } else {
            
            cachePolicy = URLRequest.CachePolicy.reloadIgnoringCacheData
        }
        
        // encoding: URLEncoding.httpBody, headers: mHeader)
        
        var urlRequest = URLRequest(url: url, cachePolicy: cachePolicy, timeoutInterval: TimeInterval(50))
        urlRequest.httpMethod = method.uppercased()
            
        for (k, v) in mHeader {
            
            urlRequest.addValue(v, forHTTPHeaderField: k)
        }
        
        if let mBody = body {
        
            urlRequest.httpBody = NSKeyedArchiver.archivedData(withRootObject: mBody)
        }
        
        Alamofire.request(urlRequest).response { (response) in
            
            if let error = response.error {
                print(error)
                if !NetworkReachabilityManager()!.isReachable {
                    
                    self.onFailure(action: action, error: NSError(domain: LocalizationSystem.sharedInstance.localizedStringForKey(key: "FailToConnected", comment: ""), code: -1, userInfo: nil))
                } else {
                    self.onFailure(action: action, error: error as NSError)
                }
            } else {
                self.onSuccess(action: action, response: response.response, data: response.data!)
                do {
                    let jsonResult = try JSONSerialization.jsonObject(with: response.data!, options: JSONSerialization.ReadingOptions.mutableContainers)
                    
                    print(jsonResult)
                } catch {
                    print(NSString(data: response.data!, encoding: String.Encoding.utf8.rawValue) ?? "")
                }
            }
        }
    }
    
    func requestConnection(action: Any, method: String = "get", url: URL, body: [String: Any]! = nil, header: [String: String]! = nil, shouldCache: Bool = true, shouldLoadFromCache: Bool, completion: @escaping (_ success: Bool?, _ failure: Error?) -> Void ) {
        
        
        onPreExecute(action: action)
        
        let mHeader = header ?? [String: String]()
        
        
        var cachePolicy: URLRequest.CachePolicy!
        if shouldLoadFromCache {
            
            cachePolicy = URLRequest.CachePolicy.returnCacheDataElseLoad
        } else if shouldCache {
            
            cachePolicy = URLRequest.CachePolicy.reloadIgnoringCacheData
        } else {
            
            cachePolicy = URLRequest.CachePolicy.reloadIgnoringCacheData
        }
        
        // encoding: URLEncoding.httpBody, headers: mHeader)
        
        var urlRequest = URLRequest(url: url, cachePolicy: cachePolicy, timeoutInterval: TimeInterval(50))
        urlRequest.httpMethod = method.uppercased()
        
        for (k, v) in mHeader {
            
            urlRequest.addValue(v, forHTTPHeaderField: k)
        }
        
        if let mBody = body {
            
            urlRequest.httpBody = NSKeyedArchiver.archivedData(withRootObject: mBody)
        }
        
        Alamofire.request(urlRequest).response { (response) in
            
            if let error = response.error {
                print(error)
                if !NetworkReachabilityManager()!.isReachable {
                    
                    self.onFailure(action: action, error: NSError(domain: LocalizationSystem.sharedInstance.localizedStringForKey(key: "FailToConnected", comment: ""), code: -1, userInfo: nil))
                } else {
                    self.onFailure(action: action, error: error as NSError)
                }
                completion(false, response.error)
            } else {
                self.onSuccess(action: action, response: response.response, data: response.data!)
                do {
                    let jsonResult = try JSONSerialization.jsonObject(with: response.data!, options: JSONSerialization.ReadingOptions.mutableContainers)
                    print(jsonResult)
                    completion(true, nil)
                } catch {
                    completion(false, nil)
                    print(NSString(data: response.data!, encoding: String.Encoding.utf8.rawValue) ?? "")
                }
                
            }
        }
    }
    
    func requestConnection(action: Any, method: String, url: URL, body: [String: Any]!, header: [String: String]! , image : UIImage , imageKey: String, fileName: String) {
        
        onPreExecute(action: action)
        
        
        let mHeader = header ?? [String: String]()
        let mBody = body ?? [String: Any]()
        
        let method = HTTPMethod(rawValue: method.uppercased())!
        
        let urlRequest = try! URLRequest(url: url, method: method, headers: mHeader)
        
        let imgData = UIImageJPEGRepresentation(image, 1)!
        
        Alamofire.upload(multipartFormData: { (data) in
            //  data.append(imgData, withName: "image")
            data.append(imgData, withName: imageKey, fileName: fileName, mimeType: "image/jpg")
            
            for (key, value) in mBody {
                data.append(String(describing: value).data(using: .utf8)!, withName: key)
            }
        }, with: urlRequest) { (result) in
            
            switch result {
            case .success(let upload, _, _):
                
                upload.uploadProgress(closure: { (progress) in
                    print("Upload Progress: \(progress.fractionCompleted)")
                })
                
                upload.responseJSON { response in
                    self.onSuccess(action: action, response: response.response, data: response.data!)
                }
                
            case .failure(let encodingError):
                print(encodingError)
                if !NetworkReachabilityManager()!.isReachable {
                    
                    self.onFailure(action: action, error: NSError(domain: LocalizationSystem.sharedInstance.localizedStringForKey(key: "FailToConnected", comment: ""), code: -1, userInfo: nil))
                } else {
                    self.onFailure(action: action, error: encodingError as NSError)
                }
                
            }
        }
    }
    
    func requestConnectionLegacey(action: Any, method: String, url: URL, body: [String: Any], header: [String: String]! = nil, shouldCache: Bool = false, shouldLoadFromCache: Bool = false) {
        
        onPreExecute(action: action)
        
        let jsonData = try? JSONSerialization.data(withJSONObject: body)
        
        var request = URLRequest(url: url)
        request.httpMethod = method.uppercased()
        
        // insert json data to the request
        request.httpBody = jsonData
        
        //        let manager = SettingsManager()
        let mHeader = header ?? [String: String]()
        //        mHeader["Authorization"] = "Bearer \(manager.getUserToken())"
        //        mHeader["Accept"] = "application/json"
        for (k, v) in mHeader {
            
            request.addValue(v, forHTTPHeaderField: k)
        }
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            
            guard let data = data, error == nil else {
                
                print(error?.localizedDescription ?? "No data")
                if !NetworkReachabilityManager()!.isReachable {
                    
                    self.onFailure(action: action, error: NSError(domain: LocalizationSystem.sharedInstance.localizedStringForKey(key: "FailToConnected", comment: ""), code: -1, userInfo: nil))
                } else {
                    self.onFailure(action: action, error: error! as NSError)
                }
                return
            }
            
            self.onSuccess(action: action, response: response, data: data)
            do {
                let jsonResult = try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.mutableContainers)
                
                print(jsonResult)
            } catch {
                print(NSString(data: data, encoding: String.Encoding.utf8.rawValue) ?? "")
            }
            
        }
        
        task.resume()
    }
    
    func getCacheData(url: URL) -> Data! {
        
        if let cache = URLCache().cachedResponse(for: URLRequest(url: url)) {
            return cache.data
        }
        
        return nil
    }
    
    func getCache(url: URL) -> Any! {
        
        if let cache = URLCache().cachedResponse(for: URLRequest(url: url)) {
            do {
                let response = try JSONSerialization.jsonObject(with: cache.data, options: JSONSerialization.ReadingOptions.mutableContainers)
                return response
            } catch {
                print("Error:\(error)")
            }
        }
        
        return nil
    }
    
    private func resizeImage(image: UIImage, newWidth: CGFloat) -> UIImage {
        
        let scale = newWidth / image.size.width
        let newHeight = image.size.height * scale
        
        UIGraphicsBeginImageContext(CGSize(width: newWidth, height: newHeight))
        image.draw(in: CGRect(x: 0, y: 0, width: newWidth, height: newHeight))
        
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage!
    }
    
    func onPreExecute(action: Any) {
    }
    
    func onSuccess(action: Any, response: URLResponse!, data: Data!) -> Void {
        preconditionFailure("This method must be overriden")
    }
    
    func onFailure(action: Any, error: NSError) -> Void {
        preconditionFailure("This method must be overriden")
    }
}

extension NSMutableData {
    
    func appendString(string: String) {
        let data = string.data(using: String.Encoding.utf8, allowLossyConversion: true)
        append(data!)
    }
}

extension Dictionary {
    
    static func += <k, v> (left: inout [k: v], right: [k: v]) {
        
        for (k, v) in right {
            
            left[k] = v
        }
    }
}

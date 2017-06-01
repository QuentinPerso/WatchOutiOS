//
//  APIConnector.swift
//  WatchOut
//
//  Created by admin on 01/06/2017.
//  Copyright © 2017 quentin. All rights reserved.
//

import Foundation
import Alamofire
import CoreLocation


class APIConnector: NSObject{
    
    static var apiBaseURL = URL(string: "http://api.allocine.fr/rest/v3")
    
    static let partner = "YW5kcm9pZC12Mg"
    
    static var userAgent:String {
        
        let appName:String = Bundle.main.infoDictionary?[kCFBundleExecutableKey as String] as! String
        
        let appVersion:String = Bundle.main.infoDictionary?[kCFBundleVersionKey as String] as! String
        
        let osVersion:String = UIDevice.current.systemVersion
        
        let deviceType:String = (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiom.pad) ? "Tablet": "Mobile"
        
        let locale:String = Locale.current.languageCode!
        
        var systemInfo = utsname()
        uname(&systemInfo)
        let machineMirror = Mirror(reflecting: systemInfo.machine)
        let device = machineMirror.children.reduce("") { identifier, element in
            guard let value = element.value as? Int8 , value != 0 else { return identifier }
            return identifier + String(UnicodeScalar(UInt8(value)))
        }
        
        let ua = appName + "/" + appVersion + " (iOS;" + osVersion + ";" + deviceType + ";" + locale + ") " + device
        
        return ua
        
    }
    
    static var sessionManager:Alamofire.SessionManager {
        let manager = Alamofire.SessionManager.default
        manager.adapter = MashapeHeadersAdapter()
        return manager
    }
 
    
//    static func getClosestCinemas(position:CLLocationCoordinate2D, completion:@escaping () -> Void){
//        
//        let queryParams:[String:String] = [
//            "partner" : partner,
//            "lat" : "\(position.latitude)",
//            "long" : "\(position.longitude)",
//            "radius" : "10",
//            "format" : "json",
//            ]
//        
//        print("*****************")
//        UIApplication.shared.isNetworkActivityIndicatorVisible = true
//        let request = sessionManager.request("http://api.allocine.fr/rest/v3/theaterlist", parameters: queryParams).responseJSON { response in
//            UIApplication.shared.isNetworkActivityIndicatorVisible = false
//            
//            print(response)
//            
//            if let jsonDict = response.result.value as? [String: AnyObject]{
//                _ = jsonDict.reversed()
//                
//            }
//            else{
//                completion()
//            }
//        }
//        print(request)
//    }  
}

//************************************
// MARK: - TimeList
//************************************

extension APIConnector {
    
    static func getCinemasTimeList(position:CLLocationCoordinate2D,
                                          radius:CGFloat,
                                          cinemaChain:String? = nil,
                                          movie:String? = nil,
                                          date:String? = nil,
                                          completion:@escaping ([WOCinema]?) -> Void) -> DataRequest{
        
        var queryParams:[String:String] = [
            "partner" : partner,
            "lat" : "\(position.latitude)",
            "long" : "\(position.longitude)",
            "radius" : "10",
            "format" : "json",
            ]
        
        if cinemaChain != nil { queryParams["location"] = cinemaChain }
        if movie != nil { queryParams["movie"] = movie }
        if date != nil { queryParams["date"] = date }
        
        print("*****************")
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        let request = sessionManager.request("http://api.allocine.fr/rest/v3/showtimelist", parameters: queryParams).responseJSON { response in
            UIApplication.shared.isNetworkActivityIndicatorVisible = false
                        
            if let jsonDict = response.result.value as? [String: AnyObject]{
                
                if let rawSObj = jsonDict["feed"] as? [String : AnyObject],
                    let rawObjs = rawSObj["theaterShowtimes"] as? [[String : AnyObject]] {
                    
                    var woObjs = [WOCinema]()
                    
                    for rawObj in rawObjs {
                        if let placeDict = (rawObj["place"] as? [String : AnyObject]),
                            let cinemaDict = placeDict["theater"] as? [String : AnyObject] {
                            
                            let cinema = WOCinema(dictionary: cinemaDict)
                            print(cinema.name)
                            woObjs.append(cinema)
                        }
                        
                        
                     //   mksObjs.append(mksObj)
                    }
                    completion(woObjs)
                    
                }
            }
            else{
                completion(nil)
            }
        }
        print(request)
        return request
    }
    
}

//************************************
// MARK: - Private
//************************************

extension APIConnector {
    
    
    static func absoluteURLString(path:String) -> URL{
        let url = URL(string: path.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlPathAllowed)!, relativeTo: apiBaseURL)!
        //        print(APIConnector.userSession?.accessToken ?? "user not logged in")
        print(url)
        return url
        
    }
    
    static func logResponse(note:String, value:Any?, meta:Bool){
        
        if let jsonDict = value as? [String: AnyObject] {
            if jsonDict["__DEBUG__"] != nil {
                var jsonMut = jsonDict
                jsonMut.removeValue(forKey: "__DEBUG__")
                
                if meta == false, jsonDict["__meta"] != nil {
                    jsonMut.removeValue(forKey: "__meta")
                }
                
                debugPrint(note + " : " , jsonMut)
                
            }
            else {
                debugPrint(note + " : ", jsonDict)
            }
        }
        
    }
    
    
}

//************************************
// MARK: - URLRequest header formater
//************************************

class MashapeHeadersAdapter: RequestAdapter {
    func adapt(_ urlRequest: URLRequest) throws -> URLRequest {
        
        var urlRequest = urlRequest
        
        urlRequest.setValue(APIConnector.userAgent, forHTTPHeaderField: "User-Agent")
        
//        if let lat  = LocationManager.shared.lastKnownCoord?.latitude,
//            let lon  = LocationManager.shared.lastKnownCoord?.longitude {
//            urlRequest.setValue("\(lat),\(lon)", forHTTPHeaderField: "X-Mks-Location")
//        }
        
//        if let accessT = APIConnector.userSession?.accessToken {
//            urlRequest.setValue("\(accessT)", forHTTPHeaderField: "X-Mks-AccessToken")
//        }
        
        
        let timeOffset = TimeZone.current.secondsFromGMT()
        urlRequest.setValue("\(timeOffset)", forHTTPHeaderField: "X-Mks-GMTOffset")
        
        
        //        urlRequest.setValue("\(CityManager.shared.currentCity?.cityID ?? "NULL")", forHTTPHeaderField: "X-Mks-CurrentCity")
        
        
        return urlRequest
    }
}














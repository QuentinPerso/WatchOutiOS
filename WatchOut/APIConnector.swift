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
    
//    static var userAgent:String {
//        
//        let appName:String = Bundle.main.infoDictionary?[kCFBundleExecutableKey as String] as! String
//        
//        let appVersion:String = Bundle.main.infoDictionary?[kCFBundleVersionKey as String] as! String
//        
//        let osVersion:String = UIDevice.current.systemVersion
//        
//        let deviceType:String = (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiom.pad) ? "Tablet": "Mobile"
//        
//        let locale:String = Locale.current.languageCode!
//        
//        var systemInfo = utsname()
//        uname(&systemInfo)
//        let machineMirror = Mirror(reflecting: systemInfo.machine)
//        let device = machineMirror.children.reduce("") { identifier, element in
//            guard let value = element.value as? Int8 , value != 0 else { return identifier }
//            return identifier + String(UnicodeScalar(UInt8(value)))
//        }
//        
//        let ua = appName + "/" + appVersion + " (iOS;" + osVersion + ";" + deviceType + ";" + locale + ") " + device
//        
//        return ua
//        
//    }
    
    static var sessionManager:Alamofire.SessionManager {
        let manager = Alamofire.SessionManager.default
        manager.adapter = MashapeHeadersAdapter()
        return manager
    }
 
    
}

//************************************
// MARK: - Search
//************************************

extension APIConnector {
    
    static func search(q:String, completion:@escaping ([AnyObject]?) -> Void) -> DataRequest{
        
        let queryParams:[String:String] = [
            "q" : q,
            "partner" : partner,
            "filter" : "movie,person",
            "count" : "20",
            "format" : "json",
            ]
        
        
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        let request = sessionManager.request("http://api.allocine.fr/rest/v3/search", parameters: queryParams).responseJSON { response in
            UIApplication.shared.isNetworkActivityIndicatorVisible = false
            
            if let jsonDict = response.result.value as? [String: AnyObject]{
                
                var woObjs = [AnyObject]()
                
                if let rawSObj = jsonDict["feed"] as? [String : AnyObject]{
                    
                    if let rawObjs = rawSObj["movie"] as? [[String : AnyObject]] {
                        for rawObj in rawObjs {
                            woObjs.append(WOMovie(dictionary: rawObj))
                        }
                        
                    }
                    if let rawObjs = rawSObj["person"] as? [[String : AnyObject]] {
                        
                        for rawObj in rawObjs {
                            woObjs.append(WOPerson(dictionary: rawObj))
                        }
                    }
                    completion(woObjs)
                    
                }
            }
            else{
                completion(nil)
            }
        }
//        print(request)
        return request
    }
    
}

//************************************
// MARK: - TimeList
//************************************

extension APIConnector {
    
    static func getCinemasTimeList(position:CLLocationCoordinate2D,
                                          radius:CGFloat,
                                          movieCode:Int? = nil,
                                          person:String? = nil,
                                          date:String? = nil,
                                          timeInterval:Double? = nil,
                                          completion:@escaping ([WOTheaterShowtime]?, _ canceled:Bool) -> Void) -> DataRequest{
        
        let memberCards = SavedMemberCards.userMemberCard
        
        let radius = max(radius, 1000)
        var queryParams:[String:String] = [
            "partner" : partner,
            "lat" : "\(position.latitude)",
            "long" : "\(position.longitude)",
            "radius" : "\(Int(radius/1000))",
            "format" : "json",
            ]
    
        if movieCode != nil { queryParams["movie"] = "\(movieCode!)" }
        if date != nil { queryParams["date"] = date }
        
        // increase count for post search treatment
        if (person != nil) || (timeInterval != nil) || (memberCards.count>0) {
            queryParams["count"] = "20"
        }
        
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        let request = sessionManager.request("http://api.allocine.fr/rest/v3/showtimelist", parameters: queryParams).responseJSON { response in
            UIApplication.shared.isNetworkActivityIndicatorVisible = false
                        
            if let jsonDict = response.result.value as? [String: AnyObject]{
                
                if let rawSObj = jsonDict["feed"] as? [String : AnyObject] {
                    if let rawObjs = rawSObj["theaterShowtimes"] as? [[String : AnyObject]] {
                        
                        var woObjs = [WOTheaterShowtime]()
                    
                        var index = 0
                        for rawObj in rawObjs {
                            let theaterShowTime = WOTheaterShowtime(dictionary: rawObj, person: person, timeIntervalFromNow: timeInterval)
                            if theaterShowTime.moviesShowTime.count > 0 {
 
                                if memberCards.count > 0 {

                                    getCinemaDetails(theaterShowTime.cinema, completion: { (cinema) in
                                        if let cards = cinema.memberCards {
                                            for card in memberCards {
                                                if cards.contains(card) {
                                                    woObjs.append(theaterShowTime)
                                                    break
                                                }
                                            }
                                        }
                                        index += 1
                                        if index == rawObjs.count {
                                            completion(woObjs, false)
                                        }
                                    })
                                }
                                else if SavedMemberCards.savedBaseMemberCard.count < 15 {
                                    getCinemaDetails(theaterShowTime.cinema, completion: { (cinema) in })
                                    woObjs.append(theaterShowTime)
                                }
                                else {
                                    woObjs.append(theaterShowTime)
                                }
                                
                                
                            }
                            else {
                                index += 1
                                completion(woObjs, false)
                            }
                            
                        }
                        
                        if memberCards.count == 0 {
                            completion(woObjs, false)
                        }
                        
                        
                    }
                    else { // no result
                        completion([WOTheaterShowtime](), false)
                    }
                }
                
            }
            else if let error = response.error as NSError?, error.code == -999 {
                completion(nil, true)
            }
            else{
                completion(nil, false)
            }
        }
//        print(request)
        return request
    }
    
    
}


//************************************
// MARK: - Movie details (bug update android stuff)
//************************************

extension APIConnector {
    
    static func getMovieDetails(movie:WOMovie, completion:@escaping (WOMovie?) -> Void) -> DataRequest{
        
        let queryParams:[String:String] = [
            "partner" : partner,
            "code" : "\(movie.uniqID!)",
            "format" : "json",
            "striptags" : "synopsis,synopsisshort"
            ]
        
        
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        let request = sessionManager.request("http://api.allocine.fr/rest/v3/movie", parameters: queryParams).responseJSON { response in
            UIApplication.shared.isNetworkActivityIndicatorVisible = false
            
            if let jsonDict = response.result.value as? [String: AnyObject]{
                if let rawObj = jsonDict["movie"] as? [String : AnyObject] {
                    let newMovie = WOMovie(dictionary: rawObj)
                    newMovie.imageURL = movie.imageURL
                    newMovie.name = movie.name
                    completion(newMovie)
                }
                else {
                    completion(movie)
                }
                
                
            }
            else if let error = response.error as NSError?, error.code == -999 {
                completion(movie)
            }
            else{
                completion(movie)
            }
        }
        print(request)
        return request
    }
    
}

//************************************
// MARK: - Person
//************************************

extension APIConnector {
    
    static func getPersonDetails(personID:Int, completion:@escaping (WOPerson?) -> Void){
        
        let queryParams:[String:String] = [
            "partner" : partner,
            "code" : "\(personID)",
            "format" : "json",
            "profile" : "large"
        ]
        
        
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        let request = sessionManager.request("http://api.allocine.fr/rest/v3/person", parameters: queryParams).responseJSON { response in
            UIApplication.shared.isNetworkActivityIndicatorVisible = false
            
            if let jsonDict = response.result.value as? [String: AnyObject]{
                if let rawObj = jsonDict["person"] as? [String : AnyObject] {
                    let person = WOPerson(dictionary: rawObj)
                    completion(person)
                }
                else {
                    completion(nil)
                }
                
                
            }
            else{
                completion(nil)
            }
        }
        print(request)

    }
    
}

//************************************
// MARK: - Cinema details
//************************************

extension APIConnector {
    
    static func getCinemaDetails(_ cinema:WOCinema, completion:@escaping (WOCinema) -> Void){
        
        let queryParams:[String:String] = [
            "partner" : partner,
            "code" : "\(cinema.uniqID!)",
            "format" : "json",
        ]
        
        
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        sessionManager.request("http://api.allocine.fr/rest/v3/theater", parameters: queryParams).responseJSON { response in
            UIApplication.shared.isNetworkActivityIndicatorVisible = false
            
            if let jsonDict = response.result.value as? [String: AnyObject]{
                if let rawObj = jsonDict["theater"] as? [String : AnyObject] {
                    cinema.update(dictionary: rawObj)
                }
                completion(cinema)
                
            }
            else{
                completion(cinema)
            }
        }
    
    }
    
}

//************************************
// MARK: - Private
//************************************

extension APIConnector {
    
    
    static func absoluteURLString(path:String) -> URL{
        let url = URL(string: path.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlPathAllowed)!, relativeTo: apiBaseURL)!
        print(url)
        return url
        
    }
    
    
    
}

//************************************
// MARK: - URLRequest header formater
//************************************

class MashapeHeadersAdapter: RequestAdapter {
    func adapt(_ urlRequest: URLRequest) throws -> URLRequest {
        
//        var urlRequest = urlRequest
        
//        urlRequest.setValue(APIConnector.userAgent, forHTTPHeaderField: "User-Agent")
        
//        if let lat  = LocationManager.shared.lastKnownCoord?.latitude,
//            let lon  = LocationManager.shared.lastKnownCoord?.longitude {
//            urlRequest.setValue("\(lat),\(lon)", forHTTPHeaderField: "X-Mks-Location")
//        }
        
//        if let accessT = APIConnector.userSession?.accessToken {
//            urlRequest.setValue("\(accessT)", forHTTPHeaderField: "X-Mks-AccessToken")
//        }
        
        
//        let timeOffset = TimeZone.current.secondsFromGMT()
//        urlRequest.setValue("\(timeOffset)", forHTTPHeaderField: "X-Mks-GMTOffset")
        
        
//        urlRequest.setValue("\(CityManager.shared.currentCity?.cityID ?? "NULL")", forHTTPHeaderField: "X-Mks-CurrentCity")
        
        
        return urlRequest
    }
}














//
//  WOCinema.swift
//  WatchOut
//
//  Created by admin on 01/06/2017.
//  Copyright © 2017 quentin. All rights reserved.
//

import Foundation
import CoreLocation

class WOCinema : NSObject {
    
    var uniqID:String!
    var coordinate: CLLocationCoordinate2D!
    var name:String!
    var address:String!
    
    init(dictionary:[String : AnyObject]) {
        super.init()
        uniqID = dictionary["code"] as! String
        coordinate = extractGeoData(dictionary)
        name = dictionary["name"] as! String
        address = dictionary["address"] as! String
    }
    
    func extractGeoData(_ dictionary:[String : AnyObject]) -> CLLocationCoordinate2D {
        
        let location = dictionary["geoloc"] as! [String : AnyObject]

        if let lat = location["lat"] as? Double, let lng = location["long"] as? Double {
           
            return CLLocationCoordinate2D(latitude: lat, longitude: lng)
 
        }
        return CLLocationCoordinate2D(latitude: 0, longitude: 0)
        
    }

}



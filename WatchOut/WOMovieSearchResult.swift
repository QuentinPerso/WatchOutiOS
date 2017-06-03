//
//  WOMovieSearchResult.swift
//  WatchOut
//
//  Created by admin on 03/06/2017.
//  Copyright © 2017 quentin. All rights reserved.
//

import Foundation

class WOMovieSearchResult : NSObject {
    
    var uniqID:Int!
    var name: String!
    var productionYear = ""
    var directors:String?
    var imageURL:URL!

    init(dictionary:[String : AnyObject]) {
        super.init()
        
        uniqID = dictionary["code"] as! Int
        name = dictionary["originalTitle"] as! String
        if let dateInt = dictionary["productionYear"] as? Int {
            productionYear = "(\(dateInt))"
        }
        
        if let castDict = dictionary["castingShort"] as? [String : AnyObject] {
            directors = castDict["directors"] as? String
        }
        
        if let poster = dictionary["poster"] as? [String : AnyObject], let urlStr = poster["href"] as? String {
            imageURL = URL(string:urlStr)
        }
        else {
            imageURL = URL(string:"blavla")!
        }
        
    }
    
    
    
}

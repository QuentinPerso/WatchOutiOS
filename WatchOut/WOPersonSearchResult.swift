//
//  WOMovieSearchResult.swift
//  WatchOut
//
//  Created by admin on 03/06/2017.
//  Copyright © 2017 quentin. All rights reserved.
//

import Foundation

class WOPersonSearchResult : NSObject {
    
    var uniqID:Int!
    var name: String!
    var imageURL:URL!
    var activities:String?

    init(dictionary:[String : AnyObject]) {
        super.init()
        
        uniqID = dictionary["code"] as! Int
        name = dictionary["name"] as! String
        
        if let pictureDict = dictionary["picture"] as? [String : AnyObject], let urlStr = pictureDict["href"] as? String {
            imageURL = URL(string:urlStr)
        }
        else {
            imageURL = URL(string:"blavla")!
        }
        
        if let activDictsArray = dictionary["activity"] as? [[String : AnyObject]] {
            var activitiesArray = [String]()
            for activDict in activDictsArray {
                activitiesArray.append(activDict["$"] as! String)
            }
            activities = activitiesArray.joined(separator: ", ")
        }
        
    }
    
    
    
}

//
//  WOMovie.swift
//  WatchOut
//
//  Created by admin on 01/06/2017.
//  Copyright © 2017 quentin. All rights reserved.
//

import Foundation

class WOMovie : NSObject {
    
    var uniqID:Int!
    var name: String!
    var duration:String?
    var genre = ""
    var imageURL:URL!
    var userRating:Double?
    var pressRating:Double?
    
    init(dictionary:[String : AnyObject]) {
        super.init()

        uniqID = dictionary["code"] as! Int
        name = dictionary["title"] as! String
        if let secondTime = dictionary["runtime"] as? Int {
            duration = secondTime.timeFromSeconds()
        }
        
        let genreDictArray = (dictionary["genre"] as! [[String : AnyObject]])
        genre = genreDictArray.map({ (dict) -> String in return dict["$"] as! String }).joined(separator: ",")

        if let poster = dictionary["poster"] as? [String : AnyObject], let urlStr = poster["href"] as? String {
            imageURL = URL(string:urlStr)
        }
        else {
            imageURL = URL(string:"blavla")!
        }
        
        if let stats = dictionary["statistics"] as? [String : AnyObject] {
            userRating = stats["userRating"] as? Double
            pressRating = stats["pressRating"] as? Double
        }
    }
    

    
}




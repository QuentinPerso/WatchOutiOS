//
//  WOMovie.swift
//  WatchOut
//
//  Created by admin on 01/06/2017.
//  Copyright © 2017 quentin. All rights reserved.
//

import Foundation

class WOMovie : NSObject {
    
    var uniqID:String!
    var name: String!
    var duration:String!
    var genre:String?
    var imageURL:String?
    var userRating:Double?
    var pressRating:Double?
    
    init(dictionary:[String : AnyObject]) {
        super.init()
        
        uniqID = dictionary["code"] as! String
        name = dictionary["title"] as! String
        duration = (dictionary["runtime"] as! Int).timeFromSeconds()
        genre = (dictionary["genre"] as! [String : AnyObject])["$"] as? String
        
        if let poster = dictionary["poster"] as? [String : AnyObject] {
            imageURL = dictionary["href"] as? String
        }
        
        if let stats = dictionary["statistics"] as? [String : AnyObject] {
            userRating = dictionary["userRating"] as? Double
            pressRating = dictionary["pressRating"] as? Double
        }
    }
    

    
}




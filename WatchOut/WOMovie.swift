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
    var directors:[String]?
    var actors:[String]?
    var genre = ""
    var releaseDate:String?
    var imageURL:URL!
    var userRating:Double?
    var pressRating:Double?
    var synopsis:String?
    
    init(dictionary:[String : AnyObject]) {
        super.init()

        
        uniqID = dictionary["code"] as! Int
        name = dictionary["title"] as! String
        if let secondTime = dictionary["runtime"] as? Int {
            duration = secondTime.timeFromSeconds()
        }
        
        if let releaseDict = dictionary["release"] as? [String : AnyObject], let rawDate = releaseDict["releaseDate"] as? String {
            
            let formater = DateFormatter()
            formater.dateFormat = "yyyy-MM-dd"
            
            if let nsDate = formater.date(from: rawDate) {
                releaseDate = DateFormatter.localizedString(from: nsDate, dateStyle: .medium, timeStyle: .none)
            }
            
            
        }
        
        let genreDictArray = (dictionary["genre"] as! [[String : AnyObject]])
        genre = genreDictArray.map({ (dict) -> String in return dict["$"] as! String }).joined(separator: ", ")

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
        if let castDict = dictionary["castingShort"] as? [String : AnyObject] {
            if let directorsString = castDict["directors"] as? String {
                directors = directorsString.components(separatedBy: ", ")
            }
            if let actorsString = castDict["actors"] as? String {
                actors = actorsString.components(separatedBy: ", ")
            }
        }
    }
    

    
}




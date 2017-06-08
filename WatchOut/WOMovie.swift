//
//  WOMovie.swift
//  WatchOut
//
//  Created by admin on 01/06/2017.
//  Copyright © 2017 quentin. All rights reserved.
//

import Foundation

class WOMovie : NSObject, NSCoding {
    
    var uniqID:Int!
    var name: String!
    var duration:String?
    var directors:[String]?
    var actors:[String]?
    var genre = ""
    var releaseDate = ""
    var productionYear = ""
    var imageURL:URL!
    var userRating:Double?
    var pressRating:Double?
    var synopsis:String?
    
    override func isEqual(_ object: Any?) -> Bool {
        if let object = object as? WOMovie {
            return self.uniqID == object.uniqID
        } else {
            return false
        }
    }
    
    public func encode(with aCoder: NSCoder) {
        aCoder.encode(uniqID, forKey: "uniqID")
        aCoder.encode(name, forKey: "name")
        aCoder.encode(duration, forKey: "duration")
        aCoder.encode(actors, forKey: "actors")
        aCoder.encode(genre, forKey: "genre")
        aCoder.encode(releaseDate, forKey: "releaseDate")
        aCoder.encode(imageURL, forKey: "imageURL")
        aCoder.encode(userRating, forKey: "userRating")
        aCoder.encode(pressRating, forKey: "pressRating")
        aCoder.encode(synopsis, forKey: "synopsis")
    }
    
    required init?(coder aDecoder: NSCoder) {
        
        uniqID = aDecoder.decodeObject(forKey: "uniqID") as! Int
        name = aDecoder.decodeObject(forKey: "name") as! String
        duration = aDecoder.decodeObject(forKey: "duration") as? String
        directors = aDecoder.decodeObject(forKey: "directors") as? [String]
        actors = aDecoder.decodeObject(forKey: "actors") as? [String]
        genre = aDecoder.decodeObject(forKey: "genre") as! String
        releaseDate = aDecoder.decodeObject(forKey: "releaseDate") as! String
        imageURL = aDecoder.decodeObject(forKey: "imageURL") as! URL
        userRating = aDecoder.decodeObject(forKey: "userRating") as? Double
        pressRating = aDecoder.decodeObject(forKey: "pressRating") as? Double
        synopsis = aDecoder.decodeObject(forKey: "synopsis") as? String
        
        super.init()
    }
    
    init(dictionary:[String : AnyObject]) {
        super.init()

        uniqID = dictionary["code"] as! Int
        name = (dictionary["title"] as? String) ?? dictionary["originalTitle"] as? String
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
        
        if let dateInt = dictionary["productionYear"] as? Int {
            productionYear = "(\(dateInt))"
        }

        
        if let genreDictArray = (dictionary["genre"] as? [[String : AnyObject]]) {
            genre = genreDictArray.map({ (dict) -> String in return dict["$"] as! String }).joined(separator: ", ")
        }
        

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
        synopsis = dictionary["synopsis"] as? String
    }
  
}




//
//  WOMovieSearchResult.swift
//  WatchOut
//
//  Created by admin on 03/06/2017.
//  Copyright © 2017 quentin. All rights reserved.
//

import Foundation

class WOPerson : NSObject {
    
    var uniqID:Int!
    var name: String!
    var imageURL:URL!
    var activities:String?
    var birthDate:String?
    var nationality:String?
    var particiations:[WOPersonParticipation]?

    init(dictionary:[String : AnyObject]) {
        super.init()
        
        uniqID = dictionary["code"] as! Int
        if let nameDict = dictionary["name"] as? [String : AnyObject] {
            name = ""
            if let given = nameDict["given"] as? String {
                name = name + given + " "
            }
            if let family = nameDict["family"] as? String {
                name = name + family
            }
        }
        else {
            name = dictionary["name"] as! String
        }
        
        if let natioDict = dictionary["nationality"] as? [[String : AnyObject]] {
            nationality = natioDict[0]["$"] as? String
        }

        
        if let participationsArray = dictionary["participation"] as? [[String : AnyObject]] {
            particiations = [WOPersonParticipation]()
            for dict in participationsArray {
                particiations?.append(WOPersonParticipation(dictionary: dict))
            }
        }
        
        birthDate = dictionary["birthDate"] as? String
                
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

class WOPersonParticipation : NSObject {
    
    var movie:WOMovie!
    var activity:String!
    
    init(dictionary:[String : AnyObject]) {
        super.init()
        
        if let movieDict = dictionary["movie"] as? [String : AnyObject] {
            movie = WOMovie(dictionary: movieDict)
        }
        if let activDict = dictionary["activity"] as? [String : AnyObject] {
            activity = activDict["$"] as! String
        }
        
    }
    
    
}






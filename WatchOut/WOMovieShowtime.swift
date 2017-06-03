//
//  WOMovieShowtime.swift
//  WatchOut
//
//  Created by admin on 01/06/2017.
//  Copyright © 2017 quentin. All rights reserved.
//

import Foundation

class WOMovieShowtime : NSObject {
    
    var movie:WOMovie!
    var version:String!
    var screenFormat:String?
    var showTimes:[WOShowtime]!
    
    init(dictionary:[String : AnyObject]) {
        super.init()
        movie = WOMovie(dictionary: (dictionary["onShow"] as! [String : AnyObject])["movie"] as! [String : AnyObject])
        let versionDict = dictionary["version"] as! [String : AnyObject]
        let voStr = versionDict["original"] as! String
        let vo = (voStr == "true")
        let lang = (versionDict["§"] as? String) ?? ""
        version = (vo ? "VO ":"") + lang
        if let formatDict = dictionary["screenFormat"] as? [String : AnyObject]{
            screenFormat = formatDict["$"] as? String
        }
        
        if let dictArray = dictionary["scr"] as? [[String : AnyObject]] {
            showTimes = [WOShowtime]()
            for dict in dictArray {
                showTimes.append(WOShowtime(dictionary: dict))
            }
        }
    }
}

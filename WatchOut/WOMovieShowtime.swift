//
//  WOMovieShowtime.swift
//  WatchOut
//
//  Created by admin on 01/06/2017.
//  Copyright © 2017 quentin. All rights reserved.
//

import Foundation

class WOMovieShowtime : NSObject {
    
    var movie:WOMovie
    var version:String!
    var showTimes:[WOShowtime]!
    
    init(dictionary:[String : AnyObject]) {
        super.init()
        movie = WOMovie(dictionary: (dictionary["place"] as! [String : AnyObject])[""])
    
    }
    
    
    
}

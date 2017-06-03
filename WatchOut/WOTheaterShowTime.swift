//
//  WOTheaterShowTime.swift
//  WatchOut
//
//  Created by admin on 03/06/2017.
//  Copyright © 2017 quentin. All rights reserved.
//

import Foundation

class WOTheaterShowtime : NSObject {
    
    var moviesShowTime:[WOMovieShowtime]!
    var cinema:WOCinema!
    
    init(dictionary:[String : AnyObject]) {
        super.init()
        
        cinema = WOCinema(dictionary: (dictionary["place"] as! [String : AnyObject])["theater"] as! [String : AnyObject])
        
        let showsArray = dictionary["movieShowtimes"] as! [[String : AnyObject]]
        moviesShowTime = [WOMovieShowtime]()
        for dict in showsArray {
            moviesShowTime.append(WOMovieShowtime(dictionary: dict))
        }
        
    }
}


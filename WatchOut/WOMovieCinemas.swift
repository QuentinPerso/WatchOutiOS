//
//  WOMovieCinemas.swift
//  WatchOut
//
//  Created by admin on 09/06/2017.
//  Copyright © 2017 quentin. All rights reserved.
//

import Foundation

class WOMovieCinemas : NSObject {
    
    var movie:WOMovie!
    var cinemas:[WOCinema]!


    override func isEqual(_ object: Any?) -> Bool {
        if let object = object as? WOMovieCinemas {
            return self.movie.uniqID == object.movie.uniqID
        }
        else {
            return false
        }
    }
    
}

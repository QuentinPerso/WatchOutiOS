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
    
    init(dictionary:[String : AnyObject], person:String?) {
        super.init()
        
        cinema = WOCinema(dictionary: (dictionary["place"] as! [String : AnyObject])["theater"] as! [String : AnyObject])
        
        let showsArray = dictionary["movieShowtimes"] as! [[String : AnyObject]]
        moviesShowTime = [WOMovieShowtime]()
        for dict in showsArray {
            let movieST = WOMovieShowtime(dictionary: dict)
            print(person)
            if person != nil {
                
                print(movieST.movie.actors)
                if let actors = movieST.movie.actors, actors.contains(person!) {
                    moviesShowTime.append(movieST)
                }
                else if let directors = movieST.movie.directors, directors.contains(person!) {
                    moviesShowTime.append(movieST)
                }
                
            }
            else {
                moviesShowTime.append(movieST)
            }
            
            
        }
        
    }
}


//
//  ShowTime.swift
//  WatchOut
//
//  Created by admin on 01/06/2017.
//  Copyright © 2017 quentin. All rights reserved.
//

import Foundation

class WOShowtime : NSObject {
    
    var date:String!
    var hours:[String]!
    
    init(dictionary:[String : AnyObject]) {
        super.init()
        date = dictionary["d"] as! String
        if let hoursDicts = dictionary["t"] as? [[String : AnyObject]] {
            hours = [String]()
            for hourDict in hoursDicts {
                hours.append(hourDict["$"] as! String)
            }
            
        }
        
    }
    
    
    
}

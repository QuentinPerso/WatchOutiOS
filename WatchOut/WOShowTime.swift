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
        let formater = DateFormatter()
        formater.dateFormat = "yyyy-MM-dd"
        if formater.string(from: Date()) == date.components(separatedBy: " ")[0] {
            date = "today"
        }
        else {
            let nsDate = formater.date(from: date)
            date = DateFormatter.localizedString(from: nsDate!, dateStyle: .medium, timeStyle: .none)
        }
        
        if let hoursDicts = dictionary["t"] as? [[String : AnyObject]] {
            hours = [String]()
            for hourDict in hoursDicts {
                hours.append(hourDict["$"] as! String)
            }
            
        }
        
        
    }
    
    
    
}

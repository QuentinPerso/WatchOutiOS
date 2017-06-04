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
//    var timeIntervalsFromNow:[Double]!
    
    init(dictionary:[String : AnyObject], timeIntervalFromNow:Double?) {
        super.init()
        let rawDate = dictionary["d"] as! String
        let formater = DateFormatter()
        formater.dateFormat = "yyyy-MM-dd"
        if formater.string(from: Date()) == rawDate.components(separatedBy: " ")[0] {
            date = "today"
        }
        else {
            let nsDate = formater.date(from: rawDate)
            date = DateFormatter.localizedString(from: nsDate!, dateStyle: .medium, timeStyle: .none)
        }
        
        formater.dateFormat = "yyyy-MM-dd'T'HH:mm"
        formater.locale = Locale.current
        if let hoursDicts = dictionary["t"] as? [[String : AnyObject]] {
//            timeIntervalsFromNow = [Double]()
            hours = [String]()
            for hourDict in hoursDicts {
                let hourString = hourDict["$"] as! String
                let fullDateStr = rawDate + "T" + hourString
                let dateAndTime = formater.date(from: fullDateStr)
                let timeInter = dateAndTime!.timeIntervalSinceNow
                
                if timeInter >= 0 {
                    if let timeF = timeIntervalFromNow, timeF > timeInter {
//                        timeIntervalsFromNow.append(timeInter)
                        hours.append(hourString)
                    }
                    else if timeIntervalFromNow == nil {
//                        timeIntervalsFromNow.append(timeInter)
                        hours.append(hourString)
                    }
                    
                }
                
                

                
            }
            
        }
    }
    
    func getLocalDate(date:Date) -> Date {

        var nowComponents = DateComponents()
        let calendar = Calendar.current
        nowComponents.year = Calendar.current.component(.year, from: date)
        nowComponents.month = Calendar.current.component(.month, from: date)
        nowComponents.day = Calendar.current.component(.day, from: date)
        nowComponents.hour = Calendar.current.component(.hour, from: date)
        nowComponents.minute = Calendar.current.component(.minute, from: date)
        nowComponents.second = Calendar.current.component(.second, from: date)
        nowComponents.timeZone = TimeZone(abbreviation: "GMT")!
        
        return calendar.date(from: nowComponents)!

    }
    
    
    
}

//
//  WOMemberCard.swift
//  WatchOut
//
//  Created by admin on 07/06/2017.
//  Copyright © 2017 quentin. All rights reserved.
//

import Foundation

class WOMemberCard : NSObject, NSCoding {
    
    var uniqID:Int!
    var label: String!
    
    override func isEqual(_ object: Any?) -> Bool {
        if let object = object as? WOMemberCard {
            return self.uniqID == object.uniqID
        } else {
            return false
        }
    }
    
    public func encode(with aCoder: NSCoder) {
        aCoder.encode(uniqID, forKey: "uniqID")
        aCoder.encode(label, forKey: "label")
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        
        uniqID = aDecoder.decodeObject(forKey: "uniqID") as! Int
        label = aDecoder.decodeObject(forKey: "label") as! String
    
        super.init()
    }
    
    init(dictionary:[String : AnyObject]) {
        super.init()

        uniqID = dictionary["code"] as! Int
        label = dictionary["label"] as! String
        
    }
    
}

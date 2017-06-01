//
//  String+Functions.swift
//  Marks
//
//  Created by Quentin Beaudouin on 02/11/2016.
//  Copyright © 2016 Quentin Beaudouin. All rights reserved.
//

import UIKit

extension String {
    var localized: String {
        return NSLocalizedString(self, tableName: nil, bundle: Bundle.main, value: "", comment: "")
    }
}


extension Int {
    func format(f: String) -> String {
        return String(format: "%\(f)d", self)
    }
    
    func timeFromSeconds() -> String {
        
        return "\(self%3600)h\(self/60)"
    }
}

extension Double {
    func format(f: String) -> String {
        return String(format: "%\(f)f", self)
    }
    
    
}


extension UIFont {
    func sizeOfString (string: String, constrainedToWidth width: Double) -> CGSize {
        
        
        return NSString(string: string).boundingRect(with: CGSize(width: width, height: Double.greatestFiniteMagnitude),
                                                             options: NSStringDrawingOptions.usesLineFragmentOrigin,
                                                             attributes: [NSFontAttributeName: self],
                                                             context: nil).size
    }
}

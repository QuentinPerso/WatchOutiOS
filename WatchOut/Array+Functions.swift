//
//  ArrayFunctions.swift
//  Busity
//
//  Created by Quentin Beaudouin on 08/10/2016.
//  Copyright © 2016 Instama. All rights reserved.
//

import Foundation

extension Array where Element:Equatable {
    
    func removeDuplicates() -> [Element] {
        var result = [Element]()
        
        for value in self {
            if result.contains(value) == false {
                result.append(value)
            }
        }
        
        return result
    }
}

extension Array where Element: Equatable {
    
    // Remove first collection element that is equal to the given `object`:
    mutating func remove(_ object: Element) {
        if let index = firstIndex(of: object) {
            remove(at: index)
        }
    }
}

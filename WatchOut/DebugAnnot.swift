//
//  DebugAnnot.swift
//  WatchOut
//
//  Created by admin on 06/06/2017.
//  Copyright © 2017 quentin. All rights reserved.
//

import UIKit
import MapKit

class DebugAnnot:NSObject, MKAnnotation {
    
    let coordinate: CLLocationCoordinate2D
    
    var title: String?
    
    init(coord:CLLocationCoordinate2D) {

        self.coordinate = coord
        
        self.title = "debug"
        
        super.init()
    }
    
}

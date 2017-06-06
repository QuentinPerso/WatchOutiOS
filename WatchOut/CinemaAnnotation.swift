//
//  ArtWork.swift
//  Busity
//
//  Created by Quentin BEAUDOUIN on 04/06/2016.
//  Copyright © 2016 Instama. All rights reserved.
//

import UIKit
import MapKit

class CinemaAnnotation:NSObject, MKAnnotation {
    
    var theaterShowTime:WOTheaterShowtime!
//    let !
    let coordinate: CLLocationCoordinate2D
    
    var title: String?
    
    init(theaterShowTime:WOTheaterShowtime) {
        
        self.theaterShowTime = theaterShowTime
        self.coordinate = theaterShowTime.cinema.coordinate

        self.title = theaterShowTime.cinema.name
//        self.subtitle = cinema.address
        
        super.init()
    }
    
}

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
    
    let cinema:WOCinema!
    let coordinate: CLLocationCoordinate2D
    
    var title: String?
    
    init(cinema:WOCinema) {
        
        self.cinema = cinema
        self.coordinate = cinema.coordinate

        self.title = cinema.name
//        self.subtitle = cinema.address
        
        super.init()
    }
    
}

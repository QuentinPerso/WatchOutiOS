//
//  CinemaShowsAnnotationView.swift
//  AZCustomCallout
//
//  Created by Alexander Andronov on 23/06/16.
//  Copyright © 2016 Alexander Andronov. All rights reserved.
//

import Foundation
import MapKit

class CinemaShowsAnnotationView : MKPinAnnotationView {
    

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        let scale:CGFloat = selected ? 1.2:0.7
        let translationX:CGFloat = selected ? 0:-frame.size.width*(1-scale)/2
        let translationY:CGFloat = selected ? 0:frame.size.height*(1-scale)/2
        UIView.animate(withDuration: animated ? 0.15:0) {
            self.transform = CGAffineTransform(scaleX: scale, y: scale).translatedBy(x: translationX, y: translationY)
        }
        
    }

}

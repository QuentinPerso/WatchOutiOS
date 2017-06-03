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
    
    var calloutView: CinemaHoursCallout?
    
    var theaterShowTime:WOTheaterShowtime!
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        let calloutViewAdded = calloutView?.superview != nil
        
            super.setSelected(selected, animated: animated)
        
        self.superview?.bringSubview(toFront: self)
        
        if (calloutView == nil) {
            calloutView = UINib(nibName: "CinemaHoursCallout", bundle: nil).instantiate(withOwner: nil, options: nil)[0] as? CinemaHoursCallout
            calloutView?.theaterShowTime = theaterShowTime
        }
        
        if (self.isSelected && !calloutViewAdded) {
            let width = 230.0
            let rowNb = Double(min(theaterShowTime.moviesShowTime.count, 3))
            let height = 37.0 + 44.0 + rowNb*82.0
            let calloutHeightOffset = 5.0
            let halfSelfWidth = Double(frame.size.width/2.0)
            let halfWidth = -width/2.0
            let x = halfSelfWidth+halfWidth
            let calloutWidthOffset = 5.0 //depends on pin width
            calloutView!.frame = CGRect(origin: CGPoint(x: x - calloutWidthOffset, y: -height-calloutHeightOffset), size: CGSize(width: width, height: height))
            calloutView!.style()
            calloutView?.alpha = 0
            calloutView?.transform = CGAffineTransform(scaleX: 0.3, y: 0.3)
            addSubview(calloutView!)
            bringSubview(toFront: calloutView!)
            UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0, options: [], animations: {
                self.calloutView?.alpha = 1
                self.calloutView?.transform = .identity
            }, completion: nil)
        }
        
        if (!self.isSelected) {
//            UIView.animate(withDuration: 0.15, animations: {
//                self.calloutView?.transform = CGAffineTransform(scaleX: 0.3, y: 0.3)
//                self.calloutView?.alpha = 0
//            }, completion: { (_) in
//                self.calloutView?.removeFromSuperview()
//            })
            self.calloutView?.removeFromSuperview()
            
        }
    }
    
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        var hitView = super.hitTest(point, with: event)
        
        if hitView == nil && self.isSelected {
            let pointInCallout = convert(point, to: calloutView)
            hitView = calloutView!.hitTest(pointInCallout, with: event)
        }
        
        if let callout = calloutView {
            if (hitView == nil && self.isSelected) {
                hitView = callout.hitTest(point, with: event)
            }
        }
        
        return hitView;
    }
}

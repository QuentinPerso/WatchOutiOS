//
//  MapFunctions.swift
//  Busity
//
//  Created by Quentin BEAUDOUIN on 04/06/2016.
//  Copyright © 2016 Instama. All rights reserved.
//

import UIKit
import MapKit

extension MKMapView {
    
    //************************************
    // MARK: - CLLocation
    //************************************
    
    func centerOn(location: CLLocation, radius:CLLocationDistance?, animated:Bool) {
        
        if radius != nil {
            let coordinateRegion = MKCoordinateRegionMakeWithDistance(location.coordinate, radius!, radius!)
            self.setRegion(coordinateRegion, animated: animated)
        }
        else {
            self.setCenter(location.coordinate, animated: animated)
        }
    }
    
    //************************************
    // MARK: - Coordinate
    //************************************
    
    func centerOn(coord: CLLocationCoordinate2D, radius:CLLocationDistance?, animated:Bool) {
        
        if radius != nil {
            let coordinateRegion = MKCoordinateRegionMakeWithDistance(coord, radius!, radius!)
            self.setRegion(coordinateRegion, animated: animated)
        }
        else {
            self.setCenter(coord, animated: animated)
        }
        
        
    }
    
}

class MapFunctions: NSObject {
    
    static let defaultRegionRadius:CLLocationDistance = 1500
    
    
    //************************************
    // MARK: - CGPoint
    //************************************
    
    static func centerMapOnPoint(_ map:MKMapView, point: CGPoint, radius:CLLocationDistance?, animated:Bool) {
        let location = CLLocation(latitude: Double(point.x), longitude: Double(point.y))
        
        if radius != nil {
            let coordinateRegion = MKCoordinateRegionMakeWithDistance(location.coordinate, radius!, radius!)
            MKMapView.animate(withDuration: 0.15, delay: 0, options: UIViewAnimationOptions.curveEaseOut, animations: {
                map.setRegion(coordinateRegion, animated: false)
            }, completion: nil)
//            map.setRegion(coordinateRegion, animated: animated)
        }
        else {
            map.setCenter(location.coordinate, animated: animated)
        }
    }


    
    //************************************
    // MARK: - Lat long
    //************************************
    
    static func centerMapOnLatLng(_ map:MKMapView, lat:Double, long:Double, radius:CLLocationDistance?, animated:Bool) {
        
        let location = CLLocation(latitude:lat, longitude: long)
        
        if radius != nil {
            let coordinateRegion = MKCoordinateRegionMakeWithDistance(location.coordinate, radius!, radius!)
            map.setRegion(coordinateRegion, animated: animated)
        }
        else {
            map.setCenter(location.coordinate, animated: animated)
        }
        
    }
    
    //************************************
    // MARK: - Utils
    //************************************
    
    
    static func getLocation2DFromPoint(_ point:CGPoint)->CLLocationCoordinate2D {
        let location = CLLocationCoordinate2D(latitude: Double(point.x), longitude: Double(point.y))
        return location
        
       
    }
    
    static func getLocationFromPoint(_ point:CGPoint)->CLLocation {
        let location = CLLocation(latitude: Double(point.x), longitude: Double(point.y))
        return location
        
        
    }
    
    static func mapRegionRadius(_ map:MKMapView) -> CLLocationDistance {
        
        let centerCoor  = map.centerCoordinate
        let centerLocation  = CLLocation(latitude: centerCoor.latitude, longitude: centerCoor.longitude)
        
        let topCenterCoor = map.convert(CGPoint(x: (map.frame.size.width - map.layoutMargins.left) / 2.0,
                                                y: 0),
                                        toCoordinateFrom: map)
        let topCenterLocation = CLLocation(latitude: topCenterCoor.latitude, longitude: topCenterCoor.longitude)
        
        let radius:CLLocationDistance = centerLocation.distance(from: topCenterLocation)
        
        return radius;
    }
    
    static func mapRectThatFitsBounds(sw:CLLocationCoordinate2D, ne:CLLocationCoordinate2D) -> MKMapRect{
        
        let swPoint = MKMapPointForCoordinate(sw)
        let swRect = MKMapRect(origin: swPoint, size: MKMapSize(width: 0, height: 0))
        
        let nePoint = MKMapPointForCoordinate(ne)
        let neRect = MKMapRect(origin: nePoint, size: MKMapSize(width: 0, height: 0))
        
        return MKMapRectUnion(swRect, neRect)
    }
    
    static func isCoordInViewPort(coord:CLLocationCoordinate2D, sw:CLLocationCoordinate2D?,ne:CLLocationCoordinate2D?) -> Bool {
        
        if sw == nil || ne == nil { return false }
        
        let rect = mapRectThatFitsBounds(sw: sw!, ne: ne!)
        
        let point = MKMapPointForCoordinate(coord)
        
        return MKMapRectContainsPoint(rect, point)
        
    }
    
    static func isCoordInRect(coord:CLLocationCoordinate2D, rect:[CLLocationCoordinate2D]) -> Bool{
        
        if rect.count != 4 { return false }
        
        let point0 = MKMapPointForCoordinate(rect[0])
        let rect0 = MKMapRect(origin: point0, size: MKMapSize(width: 0, height: 0))
        
        let point1 = MKMapPointForCoordinate(rect[1])
        let rect1 = MKMapRect(origin: point1, size: MKMapSize(width: 0, height: 0))
        
        let rectU1 = MKMapRectUnion(rect0, rect1)
        
        
        let point2 = MKMapPointForCoordinate(rect[2])
        let rect2 = MKMapRect(origin: point2, size: MKMapSize(width: 0, height: 0))
        
        let point3 = MKMapPointForCoordinate(rect[3])
        let rect3 = MKMapRect(origin: point3, size: MKMapSize(width: 0, height: 0))
        
        let rectU2 = MKMapRectUnion(rect2, rect3)
        
        let rectU = MKMapRectUnion(rectU1, rectU2)
        
        let point = MKMapPointForCoordinate(coord)
        
        return MKMapRectContainsPoint(rectU, point)
        
    }
    

}

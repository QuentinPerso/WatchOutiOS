//
//  LocationManager.swift
//  MarksHot
//
//  Created by Quentin Beaudouin on 08/02/2017.
//  Copyright © 2017 Quentin Beaudouin. All rights reserved.
//

import UIKit
import CoreLocation
import MapKit


class LocationManager: NSObject{
    
    static var hasLocalisationAuth:Bool {
        
        switch CLLocationManager.authorizationStatus() {
            
        case .notDetermined, .denied, .restricted:
            return false
        case .authorizedAlways, .authorizedWhenInUse:
            return true
        @unknown default:
            return false
        }
    }
    
    fileprivate var locUpateClosure:((_ coordinate:CLLocationCoordinate2D, _ error:String?)->())?
    fileprivate var headingUpateClosure:((_ heading:CLLocationDirection)->())?
    var locationAlwaysGranted:(()->())?
    var locationInUseGranted:(()->())?
    
    var locationStatus : String = "Calibrating"// to pass in handler
    fileprivate var locationManager: CLLocationManager!
    
    var coordinates = CLLocationCoordinate2D(latitude: 0, longitude: 0)
    var heading = CLLocationDirection()
    
    var lastLocation:CLLocation?
    var lastKnownCoord:CLLocationCoordinate2D?{ return lastLocation?.coordinate }
    
    
    var autoUpdate = false
    
    static let shared = LocationManager()
    
    
    fileprivate override init(){
        
        super.init()
        
        if(!autoUpdate){
            autoUpdate = !CLLocationManager.significantLocationChangeMonitoringAvailable()
        }
        
    }
    
    fileprivate func resetLatLon(){
        
        coordinates = CLLocationCoordinate2D(latitude: 0, longitude: 0)
        
    }
    
    func startUpdatingLocation(_ completion:((_ coordinate:CLLocationCoordinate2D, _ error:String?)->())? = nil){
        
        locUpateClosure = completion
        
        if locationManager == nil { initLocationManager() }
        
        startCoordUpdate()
        
    }
    
    func stopUpdatingLocation(){
        
        stopCoordUpdate()

    }
    
    func startUpdatingDirection(_ completion:((_ heading:CLLocationDirection)->())? = nil){
        
        if locationManager == nil { initLocationManager() }
        
        headingUpateClosure = completion
        
        locationManager.startUpdatingHeading()
    }
    
    func stopUpdatingDirection(){
        
        if locationManager == nil { return }
        
        locationManager.stopUpdatingHeading()
        
    }
    
    
    
    fileprivate func initLocationManager() {
        
        if locationManager != nil { return }
        
        locationManager = CLLocationManager()
        
        locationManager.delegate = self

        locationManager.desiredAccuracy = kCLLocationAccuracyBest

        locationManager.requestWhenInUseAuthorization()
        
        
    }
    
    func requestLocAuth() {
        initLocationManager()
    }
    
    
    fileprivate func startCoordUpdate(){
        
        if(autoUpdate){ locationManager.startUpdatingLocation() }
        else{ locationManager.startMonitoringSignificantLocationChanges() }
        
    }
    
    
    fileprivate func stopCoordUpdate(){
        
        if(autoUpdate){ locationManager.stopUpdatingLocation() }
        else{ locationManager.stopMonitoringSignificantLocationChanges() }
        
    }
    
    

    
}

extension LocationManager:CLLocationManagerDelegate {

    internal func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        
        stopCoordUpdate()
        
        resetLatLon()
        
        locUpateClosure?(coordinates, error.localizedDescription)
        
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateHeading newHeading: CLHeading) {
        
        if newHeading.headingAccuracy < 0 { return }
        
        heading = newHeading.trueHeading > 0 ? newHeading.trueHeading : newHeading.magneticHeading

        headingUpateClosure?(heading)
        
    }
    
    internal func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        
        let location = locations.last
        
        if location == nil { return }
        
        let coord = location!.coordinate
        
        coordinates = coord
        lastLocation = location
        
        locUpateClosure?(coord, nil)
        
        
        
        
    }
    
    
    internal func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        
        
        switch status {
        case .restricted, .denied, .notDetermined:
            resetLatLon()
            if (!locationStatus.isEqual("Denied access")){
                locUpateClosure?(coordinates, nil)
                
            }
        case .authorizedAlways:
            locationAlwaysGranted?()
        case .authorizedWhenInUse:
            locationInUseGranted?()
        @unknown default:
            break
        }
        
        
    }

}




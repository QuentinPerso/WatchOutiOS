//
//  ViewController.swift
//  WatchOut
//
//  Created by admin on 01/06/2017.
//  Copyright © 2017 quentin. All rights reserved.
//

import UIKit
import MapKit
import Alamofire

class MapVC: UIViewController {

    @IBOutlet weak var mapView: MKMapView!
    
    var timeListRequest:DataRequest?
    

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        setupMap()
        setMapViewport()
        
    }
    
    func setMapViewport() {
        
        let locAuthStatus = CLLocationManager.authorizationStatus()
        if locAuthStatus == .notDetermined {
            
            LocationManager.shared.locationInUseGranted = {[weak self] in
                self?.mapView.setUserTrackingMode(.follow, animated: true)
            }
            
            LocationManager.shared.requestLocAuth()
        }
        else if LocationManager.hasLocalisationAuth {
            mapView.setUserTrackingMode(.follow, animated: true)
        }
        else {
            
        }
        
    }
    
    func setupMap() {
        mapView.delegate = self
    }

}

//************************************
// MARK: - API Calls
//************************************
extension MapVC {
    
    func callAPITimeLists() {
        
//        if searchOverlay != nil, !isInWorldView {
//            if searchOverlay.alpha == 0 {
//                searchOverlay.show()
//            }
//            searchOverlay.startLoading()
//        }
        
        
        let mapSearchSidePadding = SearchZoneView.mapSearchSidePadding
        let mapSearchBotAdditionalPadding = SearchZoneView.mapSearchBotAdditionalPadding
        let mapSearchTopAdditionalPadding = SearchZoneView.mapSearchTopAdditionalPadding
        
        //CENTER DISTANCE SHIT
        let camPos = mapView.camera.centerCoordinate
        
        let centerY = mapView.bounds.origin.y + mapView.layoutMargins.top + mapSearchTopAdditionalPadding + ((mapView.bounds.origin.y + mapView.bounds.size.height - mapView.layoutMargins.bottom - mapSearchBotAdditionalPadding) - mapView.bounds.origin.y + mapView.layoutMargins.top + mapSearchTopAdditionalPadding)/2
        
        let eastPoint =
            CGPoint(x:mapView.bounds.origin.x + mapView.bounds.size.width - mapSearchSidePadding,
                    y:centerY)
        
        let east = mapView.convert(eastPoint, toCoordinateFrom: mapView)
        
        let distance = CLLocation(latitude: camPos.latitude, longitude: camPos.longitude).distance(from: CLLocation(latitude: east.latitude, longitude: east.longitude))
        
        
        timeListRequest?.cancel()
        
        timeListRequest = APIConnector.getCinemasTimeList(position: camPos,
                                                          radius: CGFloat(distance),
                                                          completion: { [weak self] cinemas in
                                            
                                                            
                                                            if cinemas == nil { return }
                                                            self?.reloadMap(cinemas: cinemas!)
                                                            
            
            //
        })
        
    }
    
    func reloadMap(cinemas:[WOCinema]){
        for annot in mapView.annotations {
            if annot is CinemaAnnotation {
                mapView.removeAnnotation(annot)
            }
        }
        
        for cine in cinemas {
            let annotation = CinemaAnnotation(cinema: cine)
            print(annotation.coordinate)
            mapView.addAnnotation(annotation)
        }
    }
    
}

//************************************
// MARK: - Map View Delegate
//************************************
extension MapVC : MKMapViewDelegate{
    
    
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        callAPITimeLists()
        
    }
}


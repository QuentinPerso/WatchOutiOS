//
//  InteractivMap.swift
//  WatchOut
//
//  Created by admin on 09/06/2017.
//  Copyright © 2017 quentin. All rights reserved.
//

import UIKit
import MapKit

enum MapSearchState:String {
    case start = "start"
    case ended = "ended"
}

class InteractivMap: MKMapView {

    var shouldShowAnnotations = false
    var shouldStartSearch = false
    var shouldDeselect = true
    
    
    var dragSearchAction:((MapSearchState)->())?
    var mapReloadedAnnotationAction:((MKAnnotation)->())?
    var didSelectAnnotaionAction:((_ annotation:MKAnnotation, _ selected:Bool)->())?
    var didDeselectAllAnnotaionAction:(()->())?
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.delegate = self
        
        let panRec = UIPanGestureRecognizer(target: self, action: #selector(self.didDragMap(_:)))
        panRec.delegate = self
        
        self.addGestureRecognizer(panRec)
        
        //****** ViewPort
        let locAuthStatus = CLLocationManager.authorizationStatus()
        if locAuthStatus == .notDetermined {
            LocationManager.shared.locationInUseGranted = {[weak self] in
                self?.setUserTrackingMode(.follow, animated: false)
            }
            LocationManager.shared.requestLocAuth()
        }
        else if LocationManager.hasLocalisationAuth {
            
            self.showsUserLocation = true
            LocationManager.shared.autoUpdate = true
            LocationManager.shared.startUpdatingLocation({ (coord, error) in
                self.shouldStartSearch = true
                self.centerOn(coord: coord, radius: 10000, animated: false)
                self.shouldStartSearch = false
                self.shouldShowAnnotations = true
                LocationManager.shared.stopUpdatingLocation()
                LocationManager.shared.autoUpdate = false
            })
            
        }
    }

}

//************************************
// MARK: - Map Functions
//************************************
extension InteractivMap : UIGestureRecognizerDelegate {

    func didDragMap(_ gestureRecognizer:UIGestureRecognizer){
        
        if gestureRecognizer.state == .began {
            if gestureRecognizer.numberOfTouches == 1{
                shouldStartSearch = true
                dragSearchAction?(.start)
            }
        }
        
    }
    
    func centerMapOnAnnotation(_ cineAnnot:CinemaAnnotation) {
        let nePoint =
            CGPoint(x:bounds.origin.x + bounds.size.width,
                    y:bounds.origin.y)
        let swPoint =
            CGPoint(x:(bounds.origin.x),
                    y:(bounds.origin.y + bounds.size.height - layoutMargins.bottom))
        
        
        
        //Then transform those point into lat,lng values
        let ne = convert(nePoint, toCoordinateFrom: self)
        let sw = convert(swPoint, toCoordinateFrom: self)
        
        
        if !MapFunctions.isCoordInViewPort(coord: cineAnnot.coordinate, sw: sw, ne: ne) {
            centerOn(coord: cineAnnot.coordinate, radius: nil, animated: true)
        }
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    func reloadMap(theaterShowTimes:[WOTheaterShowtime]){
        
        var selectedAnnot:CinemaAnnotation?
        
        for annot in selectedAnnotations {
            if let cAnnot = annot as? CinemaAnnotation {
                if !theaterShowTimes.contains(cAnnot.theaterShowTime) {
                    removeAnnotation(cAnnot)
                }
                else {
                    selectedAnnot = cAnnot
                }
            }
        }
        for annot in annotations {
            if let cAnnot = annot as? CinemaAnnotation, let selAnnot = selectedAnnot, cAnnot != selAnnot {
                removeAnnotation(annot)
            }
            else if selectedAnnot == nil {
                removeAnnotation(annot)
            }
        }
        
        for tst in theaterShowTimes {
            if let selAnnot = selectedAnnot {
                
                if selAnnot.theaterShowTime != tst {
                    let annotation = CinemaAnnotation(theaterShowTime: tst)
                    addAnnotation(annotation)
                }
                else {
                    selAnnot.theaterShowTime = tst
                    mapReloadedAnnotationAction?(selAnnot)
                }
                
            }
            else if selectedAnnot == nil {
                let annotation = CinemaAnnotation(theaterShowTime: tst)
                addAnnotation(annotation)
            }
        }
        
        if shouldShowAnnotations, annotations.count > 1 {
            shouldShowAnnotations = false
            print(self.layoutMargins)
            self.showAnnotations(annotations, animated: true)
        }
    }
  
    
    
}


//************************************
// MARK: - Map View Delegate
//************************************
extension InteractivMap : MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        if let annotation = annotation as? CinemaAnnotation {
            
            let identifier = "cinemaAnotView"
            var annotationView: CinemaAnnotationView
            if let dequeuedView = dequeueReusableAnnotationView(withIdentifier: identifier) as? CinemaAnnotationView{
                dequeuedView.annotation = annotation
                annotationView = dequeuedView 
            }
            else {
                annotationView = CinemaAnnotationView(annotation: annotation, reuseIdentifier: identifier)
                annotationView.initLayout()
            }
            
            annotationView.tapAction = { [weak self] in
                
                if self == nil { return }
                if self!.selectedAnnotations.count > 0 {
                    self?.shouldDeselect = false
                }
                
            }
            
            return annotationView
            
        }
        
        return nil
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {

        if let cineAnnot = view.annotation as? CinemaAnnotation {
            
            didSelectAnnotaionAction?(cineAnnot, true)

            centerMapOnAnnotation(cineAnnot)
 
        }
        
    }
    
    
    func mapView(_ mapView: MKMapView, didDeselect view: MKAnnotationView) {

        if let annot = view.annotation {
            didSelectAnnotaionAction?(annot, false)
        }
        
        if !shouldDeselect {
            shouldDeselect = true
            return
        }
        
        if (view.annotation as? CinemaAnnotation) != nil {
            if selectedAnnotations.count == 0{
                didDeselectAllAnnotaionAction?()
            }
        }
    }
    
    func mapView(_ mapView: MKMapView, didUpdate userLocation: MKUserLocation) {
        let userLocationView = view(for: userLocation)
        userLocationView?.canShowCallout = false
    }
    
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        
        if shouldStartSearch {
            shouldStartSearch = false
            dragSearchAction?(.ended)
        }
        
    }
    
    
    func mapView(_ mapView: MKMapView, didAdd views: [MKAnnotationView]) {
        
        
        var delay = 0.0
        for annotView in views {
            if let placeAnnotView = annotView as? CinemaAnnotationView {
                
                annotView.transform = CGAffineTransform(translationX: 0, y: placeAnnotView.frame.size.height).scaledBy(x: 0, y: 0)
                UIView.animate(withDuration: 0.2, delay: delay, options: .curveEaseInOut, animations: {
                    annotView.transform = annotView.isSelected ? .identity : placeAnnotView.unselectedTransform
                }, completion: nil)
                delay += 0.05
            }
            else if annotView.annotation is MKUserLocation {
                //addHeadingView(toAnnotationView: annotView)
            }
            
        }
    }
}

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
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var autocompleteView: AutocompleteView!
    
    var searchOverlay:SearchZoneView!
    
    var autoCompleteRequest:DataRequest?
    
    var timeListRequest:DataRequest?
    
    var searchedObject:AnyObject?
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: .UIKeyboardWillChangeFrame, object: nil)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        setupMap()
        setupSearchView()
        setupKeyboard()
        setMapViewport()
        searchBar.delegate = self
        
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        view.bringSubview(toFront: autocompleteView)
        mapView.layoutMargins = UIEdgeInsetsMake(10, 10, 10, 10)
        
        if searchOverlay == nil {
            searchOverlay = SearchZoneView(mapView: mapView)
            self.view.addSubview(searchOverlay)
        }
        

    }

}


//************************************
// MARK: - Map Conf
//************************************
extension MapVC:UIGestureRecognizerDelegate {
    
    func setupMap() {
        mapView.delegate = self
        
        let panRec = UIPanGestureRecognizer(target: self, action: #selector(self.didDragMap(_:)))
        panRec.delegate = self
        
        self.mapView.addGestureRecognizer(panRec)
        
    }
    
    func setMapViewport() {
        
        let locAuthStatus = CLLocationManager.authorizationStatus()
        if locAuthStatus == .notDetermined {
            
            LocationManager.shared.locationInUseGranted = {[weak self] in
                self?.mapView.setUserTrackingMode(.follow, animated: false)
            }
            
            LocationManager.shared.requestLocAuth()
        }
        else if LocationManager.hasLocalisationAuth {
            mapView.setUserTrackingMode(.follow, animated: false)
        }
        else {
            
        }
        
    }
    
    func didDragMap(_ gestureRecognizer:UIGestureRecognizer){
        
        if gestureRecognizer.state == .began {
            timeListRequest?.cancel()
            searchBar.resignFirstResponder()

            if mapView.selectedAnnotations.count == 0 {
                searchOverlay.show()
            }
        }

        if mapView.selectedAnnotations.count == 0, gestureRecognizer.state == .ended {
            callAPITimeLists()
        }
        
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
}

//************************************
// MARK: - API Calls
//************************************
extension MapVC {
    
    func callAPITimeLists() {
        
        if searchOverlay != nil{
            if searchOverlay.alpha == 0 {
                searchOverlay.show()
            }
            searchOverlay.startLoading()
        }
        
        
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
        
        let searchedMovieCode = (searchedObject as? WOMovieSearchResult)?.uniqID
        let seachedPersonName = (searchedObject as? WOPersonSearchResult)?.name
        
        timeListRequest = APIConnector.getCinemasTimeList(position: camPos, radius: CGFloat(distance), movieCode:searchedMovieCode, person:seachedPersonName, completion: { [weak self] theaterShowTimes, canceled in
            
            if !canceled { self?.searchOverlay.hide() }
            print(theaterShowTimes?.count ?? "no show times")
            if theaterShowTimes == nil { return }
            print("theaterShowTimes")
            self?.reloadMap(theaterShowTimes: theaterShowTimes!)
            
            
            
        })
        
    }
    
    func reloadMap(theaterShowTimes:[WOTheaterShowtime]){
        
        
        for annot in mapView.annotations {
            if annot is CinemaAnnotation {
                mapView.removeAnnotation(annot)
            }
        }
        
        for tst in theaterShowTimes {
            let annotation = CinemaAnnotation(theaterShowTime: tst)
            mapView.addAnnotation(annotation)
        }
    }
    
}

//************************************
// MARK: - Search Bar delegate
//************************************

extension MapVC : UISearchBarDelegate{
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        autoCompleteRequest?.cancel()
        
        if !searchBar.isFirstResponder {
            resetSearch()
        }
        else {
            if searchText == "" {
                resetSearch()
            }
            else {
                autoComplete(string: searchText)
            }
        }
    }
    
    func searchBarShouldBeginEditing(_ searchBar: UISearchBar) -> Bool {
        
        enterSearch()
        
        return true
    }
    
    func searchBarShouldEndEditing(_ searchBar: UISearchBar) -> Bool {
        
        exitSearch()
        
        return true
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
    
    
    func enterSearch() {
        searchBar.setShowsCancelButton(true, animated: true)
        
    }
    
    func exitSearch() {
         searchBar.setShowsCancelButton(false, animated: true)
    }
    
    func resetSearch() {
        autocompleteView.autocompletes = []
        searchedObject = nil
    }
    
    func autoComplete(string:String) {
        
        autoCompleteRequest?.cancel()
        
        
        autoCompleteRequest = APIConnector.search(q: string, completion: { (results) in
            if results == nil { return }
            
            self.autocompleteView.autocompletes = results!
            
        })

        
    }
    
}

//************************************
// MARK: - Search Setup
//************************************

extension MapVC {
    
    func setupKeyboard() {
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillChange(notification:)), name: .UIKeyboardWillChangeFrame, object: nil)
    }
    
    func setupSearchView() {
        
        autocompleteView.autocompletes = []
        autocompleteView.didSelectSuggestion = { suggestion in
            self.searchBar.text = suggestion.name
            self.searchedObject = suggestion
            self.callAPITimeLists()
            self.autocompleteView.autocompletes = []
            self.searchBar.resignFirstResponder()
        }
        
        
    }
    
    func keyboardWillChange(notification:NSNotification) {
        
        let frameEnd = (notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue
        
        let convRect = self.view.convert(frameEnd!, from: nil)
        let yOffset = self.view.bounds.size.height - convRect.origin.y
        
        autocompleteView.tableView.contentInset.bottom = max(yOffset, 0) // -50 cause of tabBar
        
    }
    
}

//************************************
// MARK: - Map View Delegate
//************************************
extension MapVC : MKMapViewDelegate{
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        if let cineAnnot = annotation as? CinemaAnnotation {
            let cineView = CinemaShowsAnnotationView(annotation: annotation, reuseIdentifier: nil)
            cineView.theaterShowTime = cineAnnot.theaterShowTime
            return cineView
        }
        
        return nil
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        
        if let cineView = view as? CinemaShowsAnnotationView, let calloutView = cineView.calloutView {
            timeListRequest?.cancel()
            searchOverlay.hide()
            
            let frameOfAnnotView = CGRect(x: view.frame.origin.x - calloutView.frame.origin.x,
                                          y: view.frame.origin.y ,
                                          width: view.frame.size.width - calloutView.frame.size.width,
                                          height: view.frame.size.height - calloutView.frame.size.height)
            
            let center = CGPoint(x: frameOfAnnotView.midX, y: frameOfAnnotView.midY)
            let centerCoord = mapView.convert(center, toCoordinateFrom: mapView)
            
            print(view.frame)
            print(frameOfAnnotView)
            mapView.centerOn(centerCoord, zoomLevel: mapView.getZoomLevel(), animated: true)

        }
       
    }
    
    func mapView(_ mapView: MKMapView, didUpdate userLocation: MKUserLocation) {
        let userLocationView = mapView.view(for: userLocation)
        userLocationView?.canShowCallout = false
    }
    
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        //callAPITimeLists()
        
    }
}


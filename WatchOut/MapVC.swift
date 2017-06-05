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

    @IBOutlet weak var topBarView: UIView!
    @IBOutlet weak var mapView: MKMapView!
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var autocompleteView: AutocompleteView!
    
    @IBOutlet weak var dateFilterView: DateFilterView!
 
    var searchOverlay:SearchZoneView!
    
    var autoCompleteRequest:DataRequest?
    
    var timeListRequest:DataRequest?
    
    var searchedObject:AnyObject?
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: .UIKeyboardWillChangeFrame, object: nil)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.interactivePopGestureRecognizer?.delegate = nil
        
        setupMap()
        setupDateFilterView()
        setupSearchView()
        setupKeyboard()
        setMapViewport()
        setupSearchBar()
        
    }
    
    func setupTopShadow() {
        
        let shadowPath = UIBezierPath(roundedRect: topBarView.bounds, cornerRadius: 0)
        
        topBarView.layer.shadowRadius = 3
        topBarView.layer.shadowColor = UIColor.black.cgColor
        topBarView.layer.shadowOpacity = 0.4
        topBarView.layer.shadowOffset = CGSize(width: 0, height: 1)
        topBarView.layer.shadowPath = shadowPath.cgPath
        topBarView.clipsToBounds = false
        
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        view.bringSubview(toFront: autocompleteView)
        mapView.layoutMargins = UIEdgeInsetsMake(0, 0, 0, 0)
        setupTopShadow()
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
        
        var dateString:String? = nil
        var hoursTimeInterval:Double? = nil
        let formater = DateFormatter()
        formater.dateFormat = "yyyy-MM-dd"
        
        if dateFilterView.oneHourButton.isSelected {
            dateString = formater.string(from: Date())
            hoursTimeInterval = 3600.0
        }
        else if dateFilterView.todayButton.isSelected {
            dateString = formater.string(from: Date())
        }
        else if dateFilterView.otherDayButton.isSelected, let date = dateFilterView.filterDate {
            dateString = formater.string(from: date)
        }
        
        timeListRequest = APIConnector.getCinemasTimeList(position: camPos, radius: CGFloat(distance), movieCode:searchedMovieCode, person:seachedPersonName,date:dateString, timeInterval:hoursTimeInterval, completion: { [weak self] theaterShowTimes, canceled in
            
            if !canceled { self?.searchOverlay.hide() }
            if theaterShowTimes == nil { return }
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
    
    func setupSearchBar(){
        
        searchBar.backgroundColor = #colorLiteral(red: 0.0862745098, green: 0.09019607843, blue: 0.09803921569, alpha: 1)
        
        self.searchBar.delegate = self
        
        searchBar.backgroundImage = UIImage()

        if let textField = self.searchBar.value(forKey: "searchField") as? UITextField {
            //Magnifying glass
            if let glassIconView = textField.leftView as? UIImageView {
                glassIconView.image = #imageLiteral(resourceName: "search")
                glassIconView.tintColor = UIColor.white
            }
            
            let buttonAttribute = [NSForegroundColorAttributeName : #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1),
                                   NSFontAttributeName : UIFont.woFont(size: 13, weight: .demibold)] as [String : Any]
            
            UIBarButtonItem.appearance(whenContainedInInstancesOf: [UISearchBar.self]).setTitleTextAttributes(buttonAttribute, for: .normal)
            
            textField.textColor = UIColor.white
            textField.tintColor = UIColor.white
            
            textField.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 0.1508989726)
            textField.layer.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 0.1508989726).cgColor
            textField.layer.cornerRadius = 2
            textField.clipsToBounds = true
            
            
            searchBar.setImage(#imageLiteral(resourceName: "crossSearch"), for: UISearchBarIcon.clear, state: .normal)
            searchBar.setImage(#imageLiteral(resourceName: "crossSearch"), for: UISearchBarIcon.clear, state: .highlighted)
            
        }
        searchBar.keyboardAppearance = .dark
    }
    
    func setupDateFilterView() {
        
        dateFilterView.otherDayAction = {
            let alert = Bundle.main.loadNibNamed("DatePickerPopup", owner: self, options: nil)?[0] as! DatePickerPopup
            alert.okAction = {
                let row = alert.datePicker.selectedRow(inComponent: 0)
                self.dateFilterView.filterDate = Date().addingTimeInterval(Double(row+1) * 24 * 3600)
                if row == 0 {
                    self.dateFilterView.otherDayButton.setTitle("tomorow", for: .normal)
                    self.dateFilterView.otherDayButton.setTitle("tomorow", for: .selected)
                }
                else {
                    let formater = DateFormatter()
                    formater.dateFormat = "MM-dd"
                    let dateString = DateFormatter.localizedString(from: self.dateFilterView.filterDate!, dateStyle: .short, timeStyle: .none)
                    
                    self.dateFilterView.otherDayButton.setTitle(dateString, for: .normal)
                    self.dateFilterView.otherDayButton.setTitle(dateString, for: .selected)
                }
                self.callAPITimeLists()
            }
            alert.showInWindow(self.view.window!)
        }
        
        dateFilterView.valueDidChangeAction = {
            self.callAPITimeLists()
        }
        
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
// MARK: - Navigation
//************************************
extension MapVC {
    
    func showMovieVC(_ movie:WOMovie) {
        
        let viewController = UIStoryboard(name: "MovieDetails", bundle: nil).instantiateInitialViewController() as! MovieVC
        
        viewController.movie = movie
        
        self.navigationController?.pushViewController(viewController, animated: true)
        
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
            cineView.pinTintColor = #colorLiteral(red: 0.0862745098, green: 0.09019607843, blue: 0.09803921569, alpha: 1)
            cineView.didSelectMovieAction = { [weak self] movie in self?.showMovieVC(movie) }
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


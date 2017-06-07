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
    
    @IBOutlet weak var topbarHConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var botViewBotConstraint: NSLayoutConstraint!
    @IBOutlet weak var botViewHConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var searchBarView: SearchBarView!

    @IBOutlet weak var mapView: MKMapView!
    
    @IBOutlet weak var theaterShowsView: TheaterShowTimesView!

    @IBOutlet weak var autocompleteView: AutocompleteView!
    
    @IBOutlet weak var mapReloaderView: MapReloaderView!
    @IBOutlet weak var dateFilterView: DateFilterView!
    
    var autoCompleteRequest:DataRequest?
    
    var timeListRequest:DataRequest?
    
    var searchedObject:AnyObject?
    
    var shouldStartSearch:Bool = false
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: .UIKeyboardWillChangeFrame, object: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.automaticallyAdjustsScrollViewInsets = false
        self.navigationController?.interactivePopGestureRecognizer?.delegate = nil
        
        setBottomViewHidden(true, animated: false)
        setupMap()
        setupBottomView()
        setupDateFilterView()
        setupAutocompleteView()
        setupKeyboard()
        setupSearchBarView()
        
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        autocompleteView.tableView.contentInset = UIEdgeInsetsMake(topbarHConstraint.constant, 0, 0, autocompleteView.tableView.contentInset.bottom)
        mapView.layoutMargins = UIEdgeInsetsMake(topbarHConstraint.constant, 0, mapView.layoutMargins.bottom, 0)
        
        
        view.bringSubview(toFront: autocompleteView)
        view.bringSubview(toFront: topBarView)

        //style()
        
    }
    
    func style() {
        
        let shadowPath = UIBezierPath(roundedRect: topBarView.bounds, cornerRadius: 0)
        
        topBarView.layer.shadowRadius = 1
        topBarView.layer.shadowColor = UIColor.black.cgColor
        topBarView.layer.shadowOpacity = 0.4
        topBarView.layer.shadowOffset = CGSize(width: 0, height: 1)
        topBarView.layer.shadowPath = shadowPath.cgPath
        topBarView.clipsToBounds = false
        
    }
    
}

//************************************
// MARK: - Initial setup
//************************************
extension MapVC {
    
    func setupMap() {
        mapView.delegate = self
        
        let panRec = UIPanGestureRecognizer(target: self, action: #selector(self.didDragMap(_:)))
        panRec.delegate = self
        
        self.mapView.addGestureRecognizer(panRec)
        
        //****** ViewPort
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
    
    func setupSearchBarView() {
        
        searchBarView.searchStateChanged = { [weak self] enter in
            if enter {
                self?.autocompleteView.dimeBG(true, animated: true)
            }
            else {
                self?.autocompleteView.dimeBG(false, animated: true)
            }
        }
        searchBarView.textChangedAction = { [weak self] searchString in
            
            self?.autoCompleteRequest?.cancel()
            
            if let searchText = searchString {
                self?.autoComplete(string: searchText)
            }
            else {
                self?.resetSearch()
            }
        }
        
    }
    
    func setupBottomView() {
        
        theaterShowsView.didSelectMovieAction = { [weak self] movie in self?.showMovieVC(movie) }
        
    }
    
    func setupKeyboard() {
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillChange(notification:)), name: .UIKeyboardWillChangeFrame, object: nil)
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
        dateFilterView.showSliderAction = { [weak self] sliderShown in
            self?.setFilterSliderHidden(!sliderShown)
        }
        
    }
    
    
    
    func setupAutocompleteView() {
        
        autocompleteView.autocompletes = []
        autocompleteView.didSelectSuggestion = { suggestion in
            self.searchBarView.searchBar.text = suggestion.name
            self.searchedObject = suggestion
            self.callAPITimeLists()
            self.autocompleteView.autocompletes = []
            self.searchBarView.searchBar.resignFirstResponder()
        }
        autocompleteView.didTapBG = {
            
            self.searchBarView.searchBar.resignFirstResponder()
            
        }
        
        
    }

    
}

//************************************
// MARK: - API Calls
//************************************
extension MapVC {
    
    func callAPITimeLists() {
        
        
        if mapReloaderView.alpha == 0 {
            mapReloaderView.show()
        }
        mapReloaderView.startLoading()
        
        
        
        let mapSearchSidePadding = MapReloaderView.mapSearchSidePadding
        let mapSearchBotAdditionalPadding = MapReloaderView.mapSearchBotAdditionalPadding
        let mapSearchTopAdditionalPadding = MapReloaderView.mapSearchTopAdditionalPadding
        
        //CENTER DISTANCE
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
        
        if dateFilterView.soonButton.isSelected {
            dateString = formater.string(from: Date())
            hoursTimeInterval = Double(dateFilterView.slider.value)
        }
        else if dateFilterView.todayButton.isSelected {
            dateString = formater.string(from: Date())
        }
        else if dateFilterView.otherDayButton.isSelected, let date = dateFilterView.filterDate {
            dateString = formater.string(from: date)
        }
                
        timeListRequest = APIConnector.getCinemasTimeList(position: camPos, radius: CGFloat(distance), movieCode:searchedMovieCode, person:seachedPersonName,date:dateString, timeInterval:hoursTimeInterval, completion: { [weak self] theaterShowTimes, canceled in
            
            if !canceled { self?.mapReloaderView.hide() }
            if theaterShowTimes == nil { return }
            self?.reloadMap(theaterShowTimes: theaterShowTimes!)
            
            
            
        })
        
    }
    
}

//************************************
// MARK: - Actions
//************************************

extension MapVC {
    
    
    @IBAction func localButtonClick(_ sender: UIButton) {
        
        if LocationManager.hasLocalisationAuth {
            let coord = mapView.userLocation.coordinate
            mapView?.centerOn(coord: coord, radius: MapFunctions.defaultRegionRadius, animated: true)
        }
        
    }
    
    @IBAction func profileButtonClicked(_ sender: UIButton) {
        
        if let viewCtrl = UIStoryboard(name: "UserPage", bundle: nil).instantiateInitialViewController(){
            
            self.present(viewCtrl, animated: true, completion: nil)
            
        }
        
    }
}

//************************************
// MARK: - Map Functions
//************************************
extension MapVC:UIGestureRecognizerDelegate {
    
    
    
    func didDragMap(_ gestureRecognizer:UIGestureRecognizer){
        
        if gestureRecognizer.state == .began {
            if gestureRecognizer.numberOfTouches == 1{
                shouldStartSearch = true
                mapReloaderView.show()
            }
        }
        
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    func reloadMap(theaterShowTimes:[WOTheaterShowtime]){
        
        var selectedAnnot:CinemaAnnotation?
        
        //        if keepSelected {
        
        for annot in mapView.selectedAnnotations {
            if let cAnnot = annot as? CinemaAnnotation {
                if !theaterShowTimes.contains(cAnnot.theaterShowTime) {
                    mapView.removeAnnotation(cAnnot)
                }
                else {
                    selectedAnnot = cAnnot
                }
            }
        }
        
        for annot in mapView.annotations {
            if let cAnnot = annot as? CinemaAnnotation, let selAnnot = selectedAnnot, cAnnot != selAnnot {
                mapView.removeAnnotation(annot)
            }
            else if selectedAnnot == nil {
                mapView.removeAnnotation(annot)
            }
        }
        
        for tst in theaterShowTimes {
            if let selAnnot = selectedAnnot {
                
                if selAnnot.theaterShowTime != tst {
                    let annotation = CinemaAnnotation(theaterShowTime: tst)
                    mapView.addAnnotation(annotation)
                }
                else {
                    selAnnot.theaterShowTime = tst
                    theaterShowsView.theaterShowTime = tst
                }
                
            }
            else if selectedAnnot == nil {
                let annotation = CinemaAnnotation(theaterShowTime: tst)
                mapView.addAnnotation(annotation)
            }
        }
    }
    
}

//************************************
// MARK: - Search Functions
//************************************

extension MapVC{
    
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
// MARK: - TimeFilters Functions
//************************************

extension MapVC{
    
    func setFilterSliderHidden(_ hidden:Bool) {
        
        dateFilterView.nowSliderHidden = hidden

        UIView.animate(withDuration: 0.4, delay: 0.0, usingSpringWithDamping: hidden ? 1:0.75, initialSpringVelocity: 0, options: [.allowUserInteraction], animations: { [weak self] in
            self?.dateFilterView.sliderView.alpha = hidden ? 0 :1
            self?.view.layoutIfNeeded()
            }, completion: nil)
    }
    
}

//************************************
// MARK: - Keyboard Functions
//************************************

extension MapVC {
    
    func keyboardWillChange(notification:NSNotification) {
        
        let frameEnd = (notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue
        
        let convRect = self.view.convert(frameEnd!, from: nil)
        let yOffset = self.view.bounds.size.height - convRect.origin.y
        
        autocompleteView.tableView.contentInset.bottom = max(yOffset, 0) // -50 cause of tabBar
        
    }
    
}

//************************************
// MARK: - ShowTimesView Functions
//************************************

extension MapVC {

    func setBottomViewHidden(_ hidden:Bool, animated:Bool) {
        
        botViewBotConstraint.constant = hidden ? -botViewHConstraint.constant : -theaterShowsView.padInsetBot
        mapView.layoutMargins.bottom = hidden ? 0 : botViewHConstraint.constant - theaterShowsView.padInsetBot
        
        UIView.animate(withDuration: 0.5, delay: 0.0, usingSpringWithDamping: hidden ? 1:0.75, initialSpringVelocity: 0, options: [.allowUserInteraction], animations: { [weak self] in
            
            self?.view.layoutIfNeeded()
            
            }, completion: nil)
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
        
        if annotation is CinemaAnnotation {
            let cineView = CinemaShowsAnnotationView(annotation: annotation, reuseIdentifier: nil)
            cineView.pinTintColor = #colorLiteral(red: 0.0862745098, green: 0.09019607843, blue: 0.09803921569, alpha: 1)
            cineView.setSelected(false, animated: false)
            return cineView
        }
        
        return nil
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        
        if let cineAnnot = view.annotation as? CinemaAnnotation {
            
            timeListRequest?.cancel()
            mapReloaderView.hide()
            
            theaterShowsView.theaterShowTime = cineAnnot.theaterShowTime
            
            setBottomViewHidden(false, animated: true)
            centerMapOnAnnotation(cineAnnot)
            
            
        }
        
    }
    
    func centerMapOnAnnotation(_ cineAnnot:CinemaAnnotation) {
        let nePoint =
            CGPoint(x:mapView.bounds.origin.x + mapView.bounds.size.width,
                    y:mapView.bounds.origin.y)
        let swPoint =
            CGPoint(x:(mapView.bounds.origin.x),
                    y:(mapView.bounds.origin.y + mapView.bounds.size.height - mapView.layoutMargins.bottom))
        
        
        
        //Then transform those point into lat,lng values
        let ne = mapView.convert(nePoint, toCoordinateFrom: mapView)
        let sw = mapView.convert(swPoint, toCoordinateFrom: mapView)
        
        
        if !MapFunctions.isCoordInViewPort(coord: cineAnnot.coordinate, sw: sw, ne: ne) {
            mapView.centerOn(coord: cineAnnot.coordinate, radius: nil, animated: true)
        }
    }
    
    
    func mapView(_ mapView: MKMapView, didDeselect view: MKAnnotationView) {
        
        if (view.annotation as? CinemaAnnotation) != nil {
            if mapView.selectedAnnotations.count == 0 {
                setBottomViewHidden(true, animated: true)
            }
        }
    }
    
    func mapView(_ mapView: MKMapView, didUpdate userLocation: MKUserLocation) {
        let userLocationView = mapView.view(for: userLocation)
        userLocationView?.canShowCallout = false
    }
    
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        
        if shouldStartSearch {
            shouldStartSearch = false
            callAPITimeLists()
        }
        //callAPITimeLists()
        
    }
}


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
    
    @IBOutlet weak var botViewBotConstraint: NSLayoutConstraint!
    @IBOutlet weak var botViewHConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var searchBarView: SearchBarView!

    @IBOutlet weak var mapView: InteractivMap!
    
    @IBOutlet weak var theaterShowsView: TheaterShowTimesView!

    @IBOutlet weak var autocompleteView: AutocompleteView!
    
    @IBOutlet weak var mapReloaderView: MapReloaderView!
    
    @IBOutlet weak var dateFilterView: DateFilterView!
    
    @IBOutlet weak var actionsBtnView: ActionButtonsView!

    var autoCompleteRequest:DataRequest?
    
    var timeListRequest:DataRequest?
    
    var searchedObject:AnyObject?
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: .UIKeyboardWillChangeFrame, object: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.automaticallyAdjustsScrollViewInsets = false
        self.navigationController?.interactivePopGestureRecognizer?.delegate = nil
        
        setBottomViewHidden(true, animated: false)
        
        setActionsViewHidden(true, animated: false)
        
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
        
        
        autocompleteView.updateLayout(topBarHeight: topBarView.frame.size.height)

        mapView.layoutMargins.bottom = botViewHConstraint.constant - theaterShowsView.padInsetBot + actionsBtnView.frame.size.height

        mapView.layoutMargins = UIEdgeInsetsMake(topBarView.frame.size.height, 0, mapView.layoutMargins.bottom, 0)
        
        
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
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        unhighlightAnnotations()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        theaterShowsView.moviesCollectionView.carouselDidEndScrollingAnimation(theaterShowsView.moviesCollectionView.carousel)
    }
    
}

//************************************
// MARK: - Initial setup
//************************************
extension MapVC {
    
    func setupMap() {
        
        mapView.dragSearchAction = { state in
            switch state {
            case .start:
                self.mapReloaderView.show()
            case .ended:
                self.callAPITimeLists()
            }
        }
        
        mapView.mapReloadedAnnotationAction = { annotation in
            guard let cineAnnot = annotation as? CinemaAnnotation else { return }
            self.theaterShowsView.theaterShowTime = cineAnnot.theaterShowTime
            
            
        }
        
        mapView.didSelectAnnotaionAction = { annotation, selected in
            
            if selected {
                guard let cineAnnot = annotation as? CinemaAnnotation else { return }
                
                self.timeListRequest?.cancel()
                self.mapReloaderView.hide()
                
                self.theaterShowsView.theaterShowTime = cineAnnot.theaterShowTime
                
                self.setBottomViewHidden(false, animated: true)
                
                self.setActionsViewHidden(false, animated: true)
                
                self.theaterShowsView.showSelectedMovie()
            }
            
        }
        
        mapView.didDeselectAllAnnotaionAction = {
            self.setActionsViewHidden(true, animated: true)
            self.setBottomViewHidden(true, animated: true)
        }
        
    }
    
    func setupSearchBarView() {
        
        searchBarView.searchStateChanged = { [weak self] state in
            if state == .start {
                self?.autocompleteView.dimeBG(true, animated: true)
            }
            else if state == .ended {
                self?.autocompleteView.dimeBG(false, animated: true)
            }
            else if state == .canceled {
                self?.resetSearch()
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
        theaterShowsView.didSelectMovieInviteAction = { [weak self] message in
            if self == nil { return }
            self?.inviteButtonClicked(self!.actionsBtnView.inviteButton)
            ShareManager.shareOnController(controller: self!, sourceView: self!.theaterShowsView, message: message)
            
        }
        
        theaterShowsView.moviesCollectionView.didBeginScrollAction = {
            self.unhighlightAnnotations()
        }
        
        theaterShowsView.moviesCollectionView.didScrollToMovieAction = { movieCines in
            self.highlightAnnotations(cinemas: movieCines.cinemas)
        }
        
    }
    
    func unhighlightAnnotations() {
        for annot in mapView.annotations {
            if annot is CinemaAnnotation {
                if let view = mapView.view(for: annot) as? CinemaAnnotationView {
                    view.layer.removeAllAnimations()
                    UIView.animate(withDuration: 0.1, animations: {
                        view.alpha = 1
                        view.transform = view.isSelected ? .identity : view.unselectedTransform
                    })
                }
                
            }
        }
    }
    
    func highlightAnnotations(cinemas:[WOCinema]) {
        
        for annot in mapView.annotations {
            
            guard let cAnnot = annot as? CinemaAnnotation else { continue }
            
            if cinemas.contains(cAnnot.theaterShowTime.cinema) {
                
                guard let view = mapView.view(for: annot) as? CinemaAnnotationView else { continue }
                
                let transform = view.isSelected ? .identity : view.unselectedTransform
                
                UIView.animate(withDuration: 0.3, delay: 0, options: [.repeat, .allowUserInteraction, .autoreverse], animations: {
                    view.alpha = 0.75
                    view.transform = transform.scaledBy(x: 1.3, y: 1.2)
                }, completion: nil)
                
            }
            
        }
   
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
        autocompleteView.didClickDetailsSuggestion = { suggestion in
            if let movie = suggestion as? WOMovie {
                self.showMovieVC(movie)
            }
            else if let person = suggestion as? WOPerson {
                self.showPersonVC(person)
            }
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
        
        let searchedMovieCode = (searchedObject as? WOMovie)?.uniqID
        let seachedPersonName = (searchedObject as? WOPerson)?.name
        
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
            self?.mapView.reloadMap(theaterShowTimes: theaterShowTimes!)
            self?.theaterShowsView.moviesCollectionView.reload(theaterShowTimes: theaterShowTimes!)
            
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
        else {
            UIApplication.shared.openURL(URL(string: UIApplicationOpenSettingsURLString)!)
        }
        
    }
    
    @IBAction func profileButtonClicked(_ sender: UIButton) {
        
        if let viewCtrl = UIStoryboard(name: "UserPage", bundle: nil).instantiateInitialViewController(){
            
            self.present(viewCtrl, animated: true, completion: nil)
            
        }
        
    }
    
    @IBAction func directionButtonClicked(_ sender: UIButton) {
        
        showTransitOptions()
        
    }
    
    @IBAction func inviteButtonClicked(_ sender: UIButton) {
        UIView.transition(with: sender,
                          duration: 0.25,
                          options: sender.isSelected ? .transitionFlipFromLeft : .transitionFlipFromRight,
                          animations: {
                            sender.isSelected = !sender.isSelected
        }, completion: nil)
        theaterShowsView.inviteMode = sender.isSelected
        
    }
    
    func showTransitOptions() {
        
        if self.view.window == nil { return }
        
        var cinema:WOCinema?
        
        for annot in mapView.selectedAnnotations {
            if let cAnnot = annot as? CinemaAnnotation {
                
                cinema = cAnnot.theaterShowTime.cinema
                
            }
        }
        
        guard let cinemaName = cinema?.name else { return }
        guard let cineCoord = cinema?.coordinate else { return }
        
        let collectionPP = Bundle.main.loadNibNamed("CollectionPopup", owner: self, options: nil)?[0] as! CollectionPopup
        
        collectionPP.titleLbl.text = "Go to" + " " + cinemaName
        
        let optionsArray:[MapApp] = [.appleMap, .citymapper, .googleMap, .uber, .navigon, .waze, .theTransitApp, .yandex]
        let namesArray = ["Maps", "City mapper", "Google Maps", "Uber", "Navigon", "Waze", "The transit app", "Yandex"]
        let imagesArray = [#imageLiteral(resourceName: "transitMap"), #imageLiteral(resourceName: "transitCitymapper"), #imageLiteral(resourceName: "transitGMaps"), #imageLiteral(resourceName: "transitUber"), #imageLiteral(resourceName: "transitNavigon.png"), #imageLiteral(resourceName: "transitWaze.png"), #imageLiteral(resourceName: "transitTransit.png"), #imageLiteral(resourceName: "transitYandex.png")]
        let mapPoint = MapPoint.mapPoint(name: cinemaName, address: nil, coordinate: cineCoord)
        
        var i = 0
        var mapsAction = [PopupAction]()
        for option in optionsArray {
            if MapLauncher.isMapAppInstalled(option) {
                
                let mapAction = PopupAction(title: namesArray[i], image: imagesArray[i], handler: {
                    
                    _ = MapLauncher.launch(mapApp: option, forDirectionTo: mapPoint)
                   
                })
                
                mapsAction.append(mapAction)
                
                
            }
            i += 1
        }
        
        collectionPP.actions = mapsAction
        
        collectionPP.showInWindow(self.view.window!)
        
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
    
    func setActionsViewHidden(_ hidden:Bool, animated:Bool) {
        
        if theaterShowsView.inviteMode {
            
            actionsBtnView.inviteButton.isSelected = false
            
            theaterShowsView.inviteMode = false
        }
        
        
        actionsBtnView.setHidden(hidden, animated: animated)

        
    }

    func setBottomViewHidden(_ hidden:Bool, animated:Bool) {
        
//        let actionBtnH = actionsBtnView.frame.size.height
//        if hidden {
//            botViewBotConstraint.constant = -botViewHConstraint.constant
//            mapView.layoutMargins.bottom = actionBtnH
//        }
//        else {
//            botViewBotConstraint.constant = -theaterShowsView.padInsetBot
//            mapView.layoutMargins.bottom = botViewHConstraint.constant - theaterShowsView.padInsetBot + actionBtnH
//        }
        
        let tstView = theaterShowsView
        
        if hidden {
            tstView?.titleLabel.text = "ON SHOW"
        }
        
        
        UIView.animate(withDuration: 0.3) { 
            tstView?.tableView.alpha = hidden ? 0 : 1
            tstView?.moviesCollectionView.alpha = hidden ? 1 : 0
        }
        
//        UIView.animate(withDuration: 0.5, delay: 0.0, usingSpringWithDamping: hidden ? 1:0.75, initialSpringVelocity: 0, options: [.allowUserInteraction], animations: { [weak self] in
//            
//            self?.view.layoutIfNeeded()
//            
//            }, completion: nil)
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
    
    func showPersonVC(_ person:WOPerson) {
        
        let viewController = UIStoryboard(name: "PersonDetails", bundle: nil).instantiateInitialViewController() as! PersonVC
        
        viewController.personID = person.uniqID
        
        self.navigationController?.pushViewController(viewController, animated: true)
        
    }
    
}



//
//  MapLaucher.swift
//  MarksHot
//
//  Created by Quentin Beaudouin on 09/03/2017.
//  Copyright © 2017 Quentin Beaudouin. All rights reserved.
//

import UIKit
import MapKit

enum MapApp {
    case appleMap       // Preinstalled Apple Maps
    case citymapper     // Citymapper
    case googleMap      // Standalone Google Maps App
    case uber           /**Uber NEED API KEY*///
    case navigon        // Navigon
    case theTransitApp  // The Transit App
    case waze           // Waze
    case yandex         // Yandex Navigator
    
    static let allValues = [appleMap, citymapper, googleMap, uber, navigon, theTransitApp, waze, yandex]
    
}

//------------------- MAP LAUNCHER ----------------

class MapPoint: NSObject {
    
    var isCurrentLocation = false
    
    /**
     The geographical coordinate of the map point.
     */
    var coordinate = CLLocationCoordinate2D()
    
    /**
     The user-visible name of the given map point (optional, may be nil).
     */
    private var _name:String?
    var name:String? {
        get {
            if isCurrentLocation { return "Current Location" }
            return _name
            
        }
        set { _name = newValue }
    }
    
    /**
     The address of the given map point (optional, may be nil).
     */
    var address:String?
    
    /**
     Gives an MKMapItem corresponding to this map point object.
     */
    var mkMapItem:MKMapItem! {
        get {
            if isCurrentLocation { return MKMapItem.forCurrentLocation() }
            let placemark = MKPlacemark(coordinate: coordinate, addressDictionary: nil)
            let item = MKMapItem(placemark: placemark)
            item.name = self.name
            return item
        }
    }
    
    static func currentLocation() -> MapPoint {
        let mapPoint = MapPoint()
        mapPoint.isCurrentLocation = true
        return mapPoint
    }
    
    static func mapPoint(name:String? = nil, address:String? = nil, coordinate:CLLocationCoordinate2D) -> MapPoint {
        let mapPoint = MapPoint()
        mapPoint.name = name
        mapPoint.address = address
        mapPoint.coordinate = coordinate
        return mapPoint
    }
    
    
    
}

//------------------- MAP LAUNCHER ----------------

class MapLauncher: NSObject {

    static func isMapAppInstalled(_ mapApp:MapApp) -> Bool {
        
        if (mapApp == .appleMap) {
            return true
        }
        
        
        let urlPrefix = MapLauncher.urlPrefixFor(mapApp)
        
        if let urlString = urlPrefix, let url = URL(string: urlString) {
            return UIApplication.shared.canOpenURL(url)
        }
        return false
        
    }
    
    static func launch(mapApp:MapApp,
                       forDirectionFrom start:MapPoint = MapPoint.currentLocation(),
                       forDirectionTo end:MapPoint) -> Bool {
        
        if !isMapAppInstalled(mapApp) {
            return false
        }
        
        if mapApp == .appleMap {
            return MKMapItem.openMaps(with: [start.mkMapItem, end.mkMapItem], launchOptions: [MKLaunchOptionsDirectionsModeKey:MKLaunchOptionsDirectionsModeDriving])
            
        }
        else if mapApp == .googleMap {
            
            let url = "comgooglemaps://?saddr=\(googleMapsString(start))&daddr=\(googleMapsString(end))"
            
            if let url = URL(string:url) {
                return UIApplication.shared.openURL(url)
            }

        }
        else if mapApp == .citymapper {
            
            var params = [String]()

            if !start.isCurrentLocation {
                params.append("startcoord=\(start.coordinate.latitude),\(start.coordinate.longitude)")
                if start.name != nil {
                    params.append("startname=\(urlEncode(start.name!))")
                }
                if start.address != nil {
                    params.append("startaddress=\(urlEncode(start.address!))")
                }
            }
            if !end.isCurrentLocation {
                params.append("endcoord=\(end.coordinate.latitude),\(end.coordinate.longitude)")
                if end.name != nil {
                    params.append("endname=\(urlEncode(end.name!))")
                }
                if end.address != nil {
                    params.append("endaddress=\(urlEncode(end.address!))")
                }
            }
            if let url = URL(string: "citymapper://directions?" + params.joined(separator: "&")) {
                return UIApplication.shared.openURL(url)
            }

            
        }
        else if mapApp == .uber {
            let uberClientId = "LDrKu23E_7Sayln9Vrc4b9YMYioG1-bq"
            
            var startCoord = ""
            var startName = ""
            
            let endCoord = "dropoff[latitude]=\(end.coordinate.latitude)&dropoff[longitude]=\(end.coordinate.longitude)"
            var endName = ""
            
            if let name = end.name {
                endName = "dropoff[nickname]=\(urlEncode(name))"
            }
            
            var url = ""
            
            if !start.isCurrentLocation {
                startCoord = "pickup[latitude]=\(start.coordinate.latitude)&pickup[longitude]=\(start.coordinate.longitude)"
                if start.name != nil {
                    startName = "pickup[nickname]=\(urlEncode(start.name!))"
                }
                
                url = "uber://?client_id=\(uberClientId)&action=setPickup&\(startCoord)&\(startName)&\(endCoord)&\(endName)"
            }
            else {
                startCoord = "pickup=my_location"
                url = "uber://?client_id=\(uberClientId)&action=setPickup&\(startCoord)&\(endCoord)&\(endName)"
            }
            
            if let url = URL(string:url) {
                return UIApplication.shared.openURL(url)
            }
            
        }
        else if mapApp == .theTransitApp {
            // http://thetransitapp.com/developers
            var params = [String]()
            if !start.isCurrentLocation {
                params.append("from=\(start.coordinate.latitude),\(start.coordinate.longitude)")
            }
            if !end.isCurrentLocation {
                params.append("to=\(end.coordinate.latitude),\(end.coordinate.longitude)")
            }

            if let url = URL(string: "transit://directions?" + params.joined(separator: "&")) {
                return UIApplication.shared.openURL(url)
            }
            
        }
        else if mapApp == .navigon {
            // http://www.navigon.com/portal/common/faq/files/NAVIGON_AppInteract.pdf
            
            var name = "Destination";  // Doc doesn't say whether name can be omitted
            if end.name != nil {
                name = end.name!
            }
            let url = "navigon://coordinate/\(urlEncode(name))/\(end.coordinate.longitude)/\(end.coordinate.latitude)"
            
            if let url = URL(string:url) {
                return UIApplication.shared.openURL(url)
            }

            
            
        }
        else if mapApp == .waze {
            let url = "waze://?ll=\(end.coordinate.latitude),\(end.coordinate.longitude)&navigate=yes"
            if let url = URL(string:url) {
                return UIApplication.shared.openURL(url)
            }
            
        }
        else if mapApp == .yandex {
            
            var url = ""
            if start.isCurrentLocation {
                url = "yandexnavi://build_route_on_map?lat_to=\(end.coordinate.latitude)&lon_to=\(end.coordinate.longitude)"
            }
            else {
                url = "yandexnavi://build_route_on_map?lat_to=\(end.coordinate.latitude)&lon_to=\(end.coordinate.longitude)&lat_from=\(start.coordinate.latitude)&lon_from=\(start.coordinate.longitude)"
            }
            if let url = URL(string:url) {
                return UIApplication.shared.openURL(url)
            }
            
        }
        
        return false
        
    }

}

//************************************
// MARK: - MAP LAUNCHER Private
//************************************

extension MapLauncher {
    
    fileprivate static func urlPrefixFor(_ mapApp:MapApp) -> String? {
        
        switch mapApp {
        case .citymapper:
            return "citymapper://"
        case .googleMap:
            return "comgooglemaps://"
        case .waze:
            return "waze://"
        case .uber:
            return "uber://"
        case .navigon:
            return "navigon://"
        case .theTransitApp:
            return "transit://"
        case .yandex:
            return "yandexnavi://"
        default:
            return nil
        }
    }
    
    fileprivate static func urlEncode(_ queryParam:String) -> String {
        
        // Encode all the reserved characters, per RFC 3986
        // (<http://www.ietf.org/rfc/rfc3986.txt>)
        
        let allowedChars = CharacterSet(charactersIn: "!*'();:@&=+$,/?%#[]")
        if let newString = queryParam.addingPercentEncoding(withAllowedCharacters: allowedChars) {
            return newString
        }
        
        return ""
        
    }
    
    fileprivate static func googleMapsString(_ mPoint:MapPoint?) -> String {
        
        
        guard let mapPoint = mPoint else { return "" }

        if mapPoint.isCurrentLocation, mapPoint.coordinate.latitude == 0.0, mapPoint.coordinate.longitude == 0.0 {
            return ""
        }
        
        //if mapPoint.name != nil {
        //    return "\(mapPoint.coordinate.latitude),\(mapPoint.coordinate.longitude)"
        //}
        
        
        return "\(mapPoint.coordinate.latitude),\(mapPoint.coordinate.longitude)"
        
    }
    
    
    
}








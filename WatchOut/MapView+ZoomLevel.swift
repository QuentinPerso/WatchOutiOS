//
//  MapView+ZommLevel.swift
//  MarksHot
//
//  Created by Quentin Beaudouin on 20/12/2016.
//  Copyright © 2016 Quentin Beaudouin. All rights reserved.
//

import MapKit

let MERCATOR_RADIUS = 85445659.44705395
let MERCATOR_OFFSET = 268435456.0
let MAX_GOOGLE_LEVELS:Double = 20

extension MKMapView {
    
    func getZoomLevel() -> Double {
        let longitudeDelta = self.region.span.longitudeDelta
        let mapWidthInPixels = self.bounds.size.width
        let zoomScale:Double = longitudeDelta * MERCATOR_RADIUS * .pi / Double((180.0 * mapWidthInPixels))
        var zoomer = MAX_GOOGLE_LEVELS - log2( zoomScale )
        if ( zoomer < 0 ) { zoomer = 0 }
        //  zoomer = round(zoomer)
        return zoomer
    }
    
    
    //MARK: - Map conversion methods
    
    private func longitudeToPixelSpaceX(longitude:Double) -> Double {
        
        return round(MERCATOR_OFFSET + MERCATOR_RADIUS * longitude * .pi / 180.0)
    }
    
    private func latitudeToPixelSpaceY(latitude:Double) -> Double
    {
        return round(MERCATOR_OFFSET - MERCATOR_RADIUS * log((1 + sin(latitude * .pi / 180.0)) / (1 - sin(latitude * .pi / 180.0))) / 2.0)
    }
    
    private func pixelSpaceXToLongitude(pixelX:Double) -> Double
    {
        return ((round(pixelX) - MERCATOR_OFFSET) / MERCATOR_RADIUS) * 180.0 / .pi
    }
    
    private func  pixelSpaceYToLatitude(pixelY:Double) -> Double
    {
        return (.pi / 2.0 - 2.0 * atan(exp((round(pixelY) - MERCATOR_OFFSET) / MERCATOR_RADIUS))) * 180.0 / .pi
    }
    
    //MARK: - Map Helper methods
    
    private func coordinateSpan(_ mapView:MKMapView, centerCoordinate:CLLocationCoordinate2D, zoomLevel:Double) -> MKCoordinateSpan
        
    {
        // convert center coordiate to pixel space
        let centerPixelX = longitudeToPixelSpaceX(longitude: centerCoordinate.longitude)
        let centerPixelY = latitudeToPixelSpaceY(latitude: centerCoordinate.latitude)
        
        // determine the scale value from the zoom level
        let zoomExponent = 20.0 - zoomLevel
        let zoomScale:Double = pow(2.0, zoomExponent)
        
        // scale the map’s size in pixel space
        let mapSizeInPixels = mapView.bounds.size
        let scaledMapWidth = Double(mapSizeInPixels.width) * zoomScale
        let scaledMapHeight = Double(mapSizeInPixels.height) * zoomScale
        
        // figure out the position of the top-left pixel
        let topLeftPixelX = centerPixelX - Double(scaledMapWidth / 2)
        let topLeftPixelY = centerPixelY - Double(scaledMapHeight / 2)
        
        // find delta between left and right longitudes
        let minLng = pixelSpaceXToLongitude(pixelX: topLeftPixelX)
        let maxLng = pixelSpaceXToLongitude(pixelX: topLeftPixelX + scaledMapWidth)
        let longitudeDelta = maxLng - minLng
        
        // find delta between top and bottom latitudes
        let minLat = pixelSpaceYToLatitude(pixelY: topLeftPixelY)
        let maxLat = pixelSpaceYToLatitude(pixelY: topLeftPixelY + scaledMapHeight)
        let latitudeDelta = -1 * (maxLat - minLat)
        
        // create and return the lat/lng span
        let span = MKCoordinateSpan(latitudeDelta: latitudeDelta, longitudeDelta: longitudeDelta)
        return span
    }
    
    //MARK: - Public methods
    
    func centerOn(_ centerCoordinate:CLLocationCoordinate2D, zoomLevel:Double, animated:Bool)
    {
        // clamp large numbers to 28
        let zoomLevel = min(zoomLevel, 28)
        
        // use the zoom level to compute the region
        let span = coordinateSpan(self, centerCoordinate: centerCoordinate, zoomLevel: zoomLevel)
        let region = MKCoordinateRegion(center: centerCoordinate, span: span)
        
        // set the region like normal
        self.setRegion(region, animated: animated)
    }
    
}

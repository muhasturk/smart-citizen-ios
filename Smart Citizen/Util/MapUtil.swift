//
//  MapUtil.swift
//  Smart Citizen
//
//  Created by Mustafa Hastürk on 04/12/15.
//  Copyright © 2015 Mustafa Hastürk. All rights reserved.
//

import UIKit
import MapKit

class MapUtil {
    
    // MARK: Region
    func getMapRegion(latitude latitude: CLLocationDegrees,
        longitude: CLLocationDegrees,
        latDelta: CLLocationDegrees,
        lonDelta: CLLocationDegrees) -> MKCoordinateRegion {
        
        let coordinate:CLLocationCoordinate2D = CLLocationCoordinate2DMake(latitude, longitude)
        let span:MKCoordinateSpan = MKCoordinateSpanMake(latDelta, lonDelta)
        let region:MKCoordinateRegion = MKCoordinateRegionMake(coordinate, span)
            
        return region
    }
    
    // MARK: Annotation
    func getMapAnnotation(coordinate coordinate: CLLocationCoordinate2D, title: String, subtitle: String) -> MKPointAnnotation {
        
        let annotation = MKPointAnnotation()
        annotation.coordinate = coordinate
        annotation.title = title
        annotation.subtitle = subtitle
        return annotation
    }
    
}

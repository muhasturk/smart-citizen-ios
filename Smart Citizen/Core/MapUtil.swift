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
    
    func getMapRegion(latitude latitude: CLLocationDegrees,
        longitude: CLLocationDegrees,
        latDelta: CLLocationDegrees,
        lonDelta: CLLocationDegrees) -> MKCoordinateRegion {
        
        let location:CLLocationCoordinate2D = CLLocationCoordinate2DMake(latitude, longitude)
        let span:MKCoordinateSpan = MKCoordinateSpanMake(latDelta, lonDelta)
        let region:MKCoordinateRegion = MKCoordinateRegionMake(location, span)
            
        return region
    }
    
}

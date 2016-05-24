//
//  Annotation.swift
//  Smart Citizen
//
//  Created by Mustafa Hastürk on 11/05/16.
//  Copyright © 2016 Mustafa Hastürk. All rights reserved.
//

import Foundation
import MapKit

class SmartAnnotation: NSObject, MKAnnotation {
  
  var title: String?
  var subtitle: String?
  var coordinate: CLLocationCoordinate2D
  var knowledge: Report
  
  init(report r: Report) {
    let latitude = r.latitude
    let longitude = r.longitude
    self.coordinate = CLLocationCoordinate2DMake(latitude, longitude)
    self.title = r.title
    self.subtitle = r.description
    self.knowledge = r
    super.init()
  }
}
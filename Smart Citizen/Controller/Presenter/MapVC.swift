//
//  MapVC.swift
//  Smart Citizen
//
//  Created by Mustafa Hastürk on 03/12/15.
//  Copyright © 2015 Mustafa Hastürk. All rights reserved.
//

import UIKit
import MapKit
import Alamofire
import SwiftyJSON

class MapVC: AppVC, CLLocationManagerDelegate {
  
  // MARK: - Outlets
  @IBOutlet weak var mapView: MKMapView!
  
  // MARK: Properties
  var locationManaer = CLLocationManager()
  var mapReports = [Report]()
  
  lazy var requestBaseURL = AppAPI.serviceDomain + AppAPI.mapServiceURL
  
  // MARK: - LC
  override func viewDidLoad() {
    super.viewDidLoad()
    self.configureMap()
  }
  
  override func viewDidDisappear(animated: Bool) {
    super.viewDidDisappear(true)
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
  }
  
  // MARK: Configure Map
  private func configureMap() {
    self.locationManaer.requestWhenInUseAuthorization()
    self.locationManaer.delegate = self
    self.locationManaer.desiredAccuracy = kCLLocationAccuracyBest
    self.locationManaer.startUpdatingLocation()
    self.mapView.showsUserLocation = true
  }
  
  // MARK: - Location Manager
  func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
    if let location = locations.last {
      let latitude: CLLocationDegrees = location.coordinate.latitude
      let longitude: CLLocationDegrees = location.coordinate.longitude
      let latitudeDelta: CLLocationDegrees = 0.009
      let longitudeDelta: CLLocationDegrees = 0.009
      let coordinate: CLLocationCoordinate2D = CLLocationCoordinate2DMake(latitude, longitude)
      let span: MKCoordinateSpan = MKCoordinateSpanMake(latitudeDelta, longitudeDelta)
      let region: MKCoordinateRegion = MKCoordinateRegionMake(coordinate, span)
      self.mapView.setRegion(region, animated: true)
    }
    else {
      print("Konum alınamadı")
    }
    self.locationManaer.stopUpdatingLocation()
  }
  
  // MARK: - Networking
  private func mapNetworking(networkingParameters params: [String: AnyObject]) {
    self.startIndicator()
    Alamofire.request(.GET, self.requestBaseURL, parameters: params, encoding: .JSON)
      .responseJSON { response in
        self.stopIndicator()
        
        switch response.result {
        case .Success(let value):
          print(AppDebugMessages.serviceConnectionMapIsOk, self.requestBaseURL, separator: "\n")
          let json = JSON(value)
          let serviceCode = json["serviceCode"].intValue
          let data = json["data"]
          
          if serviceCode == 0 {
            if data.isExists() && data.isNotEmpty{
              self.writeReportsDataToModel(dataJsonFromNetworking: data)
              self.addReportsAnnotationToMap()
            }
            else {
              print(AppDebugMessages.keyDataIsNotExistOrIsEmpty)
              debugPrint(data)
            }
          }
            
          else {
            let exception = json["exception"]
            let c = exception["exceptionCode"].intValue
            let m = exception["exceptionMessage"].stringValue
            let (title, message) = self.getHandledExceptionDebug(exceptionCode: c, elseMessage: m)
            self.createAlertController(title: title, message: message, controllerStyle: .Alert, actionStyle: .Default)
          }
          
        case .Failure(let error):
          self.createAlertController(title: AppAlertMessages.networkingFailuredTitle, message: AppAlertMessages.networkingFailuredMessage, controllerStyle: .Alert, actionStyle: .Destructive)
          debugPrint(error)
        }
    }
  }

  // MARK: - Annotation
  private func addReportsAnnotationToMap() {
    for r: Report in self.mapReports {
      let latitude: CLLocationDegrees = r.latitude
      let longitude: CLLocationDegrees = r.longitude
      let coordinate: CLLocationCoordinate2D = CLLocationCoordinate2DMake(latitude, longitude)      
      let annotation = MKPointAnnotation()
      annotation.coordinate = coordinate
      annotation.title = r.title
      annotation.subtitle = r.description //refactor
      self.mapView.addAnnotation(annotation)
    }
  }
  
  // MARK: - Model
  private func writeReportsDataToModel(dataJsonFromNetworking data: JSON) {
    for (_, reportJSON): (String, JSON) in data {
      let r = Report()
      r.id = reportJSON["id"].intValue
      r.title = reportJSON["title"].stringValue
      r.description = reportJSON["description"].stringValue
      r.latitude = reportJSON["latitude"].doubleValue
      r.longitude = reportJSON["longitude"].doubleValue
      r.status = reportJSON["status"].stringValue
      r.statusId = reportJSON["statusId"].intValue
      r.count = reportJSON["count"].intValue
      self.mapReports.append(r)
      super.reflectAttributes(reflectingObject: r)
    }
  }

  
  
}

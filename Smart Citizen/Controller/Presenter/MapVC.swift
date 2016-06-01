/**
 * Copyright (c) 2016 Mustafa Hastürk
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */

import UIKit
import MapKit
import Alamofire
import SwiftyJSON
import Dodo

class MapVC: AppVC, MKMapViewDelegate {
  
  // MARK: - Outlets
  @IBOutlet weak var mapView: MKMapView!
  @IBOutlet weak var refreshButton: UIButton!
  
  // MARK: Properties
  var mapReports = [Report]()
  
  var refreshRequest = false
  private var requestBaseURL: String {
    return  AppAPI.serviceDomain + AppAPI.mapServiceURL + String(AppReadOnlyUser.roleId)
  }
  
  // MARK: - LC
  override func viewDidLoad() {
    super.viewDidLoad()
    //self.navigationItem.titleView = UIImageView(image: UIImage(named: "Camera")) as UIView
    self.configureMap()
    self.configureUI()
    self.mapNetworking()
    view.dodo.topLayoutGuide = topLayoutGuide
    view.dodo.style.bar.hideOnTap = true
    view.dodo.style.bar.hideAfterDelaySeconds = 2.5
    view.dodo.success("Hoşgeldin \(AppReadOnlyUser.fullName)")
  }
  
  @IBAction func refreshButtonAction(sender: AnyObject) {
    view.dodo.style.bar.hideAfterDelaySeconds = 0
    self.view.dodo.info("Raporlar alınıyor...")
    self.refreshRequest = true
    self.mapNetworking()
  }
  
  private func configureUI() {
    self.refreshButton.contentMode = .ScaleAspectFit
  }
  
  override func viewDidDisappear(animated: Bool) {
    super.locationManager.stopUpdatingLocation()
  }
  
  // MARK: Configure Map
  private func configureMap() {
    super.locationManager.startUpdatingLocation()
    self.mapView.showsUserLocation = true
    self.updateMapRegion()
  }
  
  private func updateMapRegion() {
    if let location = super.locationManager.location {
      let latitude: CLLocationDegrees = location.coordinate.latitude
      let longitude: CLLocationDegrees = location.coordinate.longitude
      let latitudeDelta: CLLocationDegrees = 0.009
      let longitudeDelta: CLLocationDegrees = 0.009
      let coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
      let span = MKCoordinateSpan(latitudeDelta: latitudeDelta, longitudeDelta: longitudeDelta)
      let region = MKCoordinateRegion(center: coordinate, span: span)
      self.mapView.setRegion(region, animated: true)
    }
  }
  
  var selectedReportId: Int?
  var selectedReport: Report?
  
  // MARK: Map
  func mapView(mapView: MKMapView, didSelectAnnotationView view: MKAnnotationView) {
    if let annotation = view.annotation as? SmartAnnotation {
      self.selectedReportId = annotation.knowledge.id
      self.selectedReport = annotation.knowledge
      let tap = UITapGestureRecognizer(target: self, action: #selector(goReportDetailView))
      view.addGestureRecognizer(tap)
    }
  }
  
  func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
    if annotation.isKindOfClass(SmartAnnotation) {
      let smartAnnotation = annotation as! SmartAnnotation
      var view: MKPinAnnotationView
      
      if let dequeuedView = self.mapView.dequeueReusableAnnotationViewWithIdentifier(AppReuseIdentifier.mapCustomAnnotationView) as? MKPinAnnotationView {
        dequeuedView.annotation = smartAnnotation
        view = dequeuedView
      }
      
      else {
        view = MKPinAnnotationView(annotation: smartAnnotation, reuseIdentifier: AppReuseIdentifier.mapCustomAnnotationView)
        view.canShowCallout = true
        view.calloutOffset = CGPoint(x: -5, y: 5)
        view.rightCalloutAccessoryView = UIButton(type: .DetailDisclosure) as UIView
      }

      switch smartAnnotation.knowledge.statusId {
      case 0:
        view.pinTintColor = UIColor.redColor()
      case 1:
        view.pinTintColor = UIColor.blueColor()
      default:
        view.pinTintColor = UIColor.greenColor()
      }
      
      return view
    }
      
    else if annotation.isKindOfClass(MKUserLocation) {
      return nil
    }
      
    else {
      return nil
    }
  }
  
  func mapView(mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
    self.goReportDetailView()
  }
  
  func goReportDetailView() {
    self.performSegueWithIdentifier(AppSegues.mapReportDetail, sender: nil)
    print("annotation selected id: \(self.selectedReportId)")
  }
  
  
  // MARK: - Annotation
  private func addReportsAnnotationToMap() {
    for r: Report in self.mapReports {
      let annotation = SmartAnnotation(report: r)
      self.mapView.addAnnotation(annotation)
    }
  }
  
  // MARK: - Model
  private func writeReportsDataToModel(dataJsonFromNetworking data: JSON) {
    self.mapReports = []
    for (_, reportJSON): (String, JSON) in data {
      let r = super.parseReportJSON(reportJSON)
      self.mapReports.append(r)
      //super.reflectAttributes(reflectingObject: r)
    }
  }
  
  // MARK: - Segue
  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    if segue.identifier == AppSegues.mapReportDetail {
      if let detailVC = segue.destinationViewController as? ReportDetailVC {
        detailVC.reportId = self.selectedReportId
        detailVC.report = self.selectedReport
      }
    }
  }
  
  
}

// MARK: - Networking
extension MapVC {
  private func mapNetworking() {
    Alamofire.request(.GET, self.requestBaseURL, encoding: .JSON)
      .responseJSON { response in
        
        switch response.result {
        case .Success(let value):
          print(AppDebugMessages.serviceConnectionMapIsOk, self.requestBaseURL, separator: "\n")
          let json = JSON(value)
          let serviceCode = json["serviceCode"].intValue
          
          if serviceCode == 0 {
            let data = json["data"]
            self.mapNetworkingSuccessful(data)
          }
            
          else {
            let exception = json["exception"]
            self.mapNetworkingUnsuccessful(exception)
          }
          
        case .Failure(let error):
          self.createAlertController(title: AppAlertMessages.networkingFailuredTitle, message: AppAlertMessages.networkingFailuredMessage, controllerStyle: .Alert, actionStyle: .Destructive)
          debugPrint(error)
        }
    }
  }
  
  private func mapNetworkingSuccessful(data: JSON) {
    self.writeReportsDataToModel(dataJsonFromNetworking: data)
    self.mapView.removeAnnotations(self.mapView.annotations)
    self.addReportsAnnotationToMap()
    if self.refreshRequest {
      view.dodo.style.bar.hideAfterDelaySeconds = 2
      self.view.dodo.success("Raporlar alındı.")
    }
  }
  
  private func mapNetworkingUnsuccessful(exception: JSON) {
    let c = exception["exceptionCode"].intValue
    let m = exception["exceptionMessage"].stringValue
    let (title, message) = self.getHandledExceptionDebug(exceptionCode: c, elseMessage: m)
    self.createAlertController(title: title, message: message, controllerStyle: .Alert, actionStyle: .Default)
  }
}
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
import Haneke
import MapKit
import Alamofire
import SwiftyJSON

class ReportDetailVC: AppVC {
  
  typealias JSON = SwiftyJSON.JSON

  @IBOutlet weak var reportedImageView: UIImageView!
  @IBOutlet weak var reportDescriptionView: UITextView!
  @IBOutlet weak var reportCategoryLabel: UILabel!
  @IBOutlet weak var mapView: MKMapView!
  
  // MARK: Properties
  var reportId: Int?
  var report: Report?
  private var requestBaseURL: String {
    return AppAPI.serviceDomain + AppAPI.getReportById + String(self.reportId!)
  }
  
  // MARK: - LC
  override func viewDidLoad() {
    super.viewDidLoad()
    self.reportDetailNetworking()
  }
  
  private func configureUI() {
    guard let r = self.report else {
      print(AppDebugMessages.reportNotPassed)
      return
    }
    self.navigationItem.title = r.title
    self.reportCategoryLabel.text = r.category
    self.reportDescriptionView.text = r.description
    
    if r.imageUrl.isNotEmpty {
      if let url = NSURL(string: r.imageUrl) {
        self.reportedImageView.hnk_setImageFromURL(url)
      }
      else {
        print("Report id: \(r.id) has invalid image URL as you see: \(r.imageUrl)")
      }
    }
      
    else {
      print("Report id: \(r.id) has empty image URL")
    }
    self.configureMapView(report: r)
  }
  
  private func configureMapView(report r: Report) {
    let latitude: CLLocationDegrees = r.latitude
    let longitude: CLLocationDegrees = r.longitude
    let latitudeDelta: CLLocationDegrees = 0.009
    let longitudeDelta: CLLocationDegrees = 0.009
    let coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    let span = MKCoordinateSpan(latitudeDelta: latitudeDelta, longitudeDelta: longitudeDelta)
    let region = MKCoordinateRegion(center: coordinate, span: span)
    self.mapView.setRegion(region, animated: true)
    self.mapView.removeAnnotations(self.mapView.annotations)
    let annotation = SmartAnnotation(report: r)
    self.mapView.addAnnotation(annotation)
  }
  
}

// MARK: Networking
extension ReportDetailVC {
  private func reportDetailNetworking() {
    Alamofire.request(.GET, self.requestBaseURL, encoding: .JSON)
      .responseJSON { response in
        
        switch response.result {
        case .Success(let value):
          print("başarılı detay", self.requestBaseURL, separator: "\n")
          let json = JSON(value)
          let serviceCode = json["serviceCode"].intValue
          
          if serviceCode == 0 {
            let data = json["data"]
            self.reportDetailNetworkingSuccessful(data)
          }
            
          else {
            let exception = json["exception"]
            self.reportDetailNetworkingUnsuccessful(exception)
          }
          
        case .Failure(let error):
          self.createAlertController(title: AppAlertMessages.networkingFailuredTitle, message: AppAlertMessages.networkingFailuredMessage, controllerStyle: .Alert, actionStyle: .Destructive)
          debugPrint(error)
        }
    }
  }
  
  private func reportDetailNetworkingSuccessful(data: JSON) {
    self.writeReportDetailToModel(dataJsonFromNetworking: data)
    self.configureUI()
  }
  
  private func reportDetailNetworkingUnsuccessful(exception: JSON) {
    let c = exception["exceptionCode"].intValue
    let m = exception["exceptionMessage"].stringValue
    let (title, message) = self.getHandledExceptionDebug(exceptionCode: c, elseMessage: m)
    self.createAlertController(title: title, message: message, controllerStyle: .Alert, actionStyle: .Default)
  }

}

extension ReportDetailVC {
  private func writeReportDetailToModel(dataJsonFromNetworking data: JSON) {
    self.report = super.parseReportJSON(data)
    super.reflectAttributes(reflectingObject: super.parseReportJSON(data))
  }
  
}

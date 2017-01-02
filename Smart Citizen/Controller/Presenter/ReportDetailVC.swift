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
  @IBOutlet weak var createdBy: UILabel!
  @IBOutlet weak var createdDate: UILabel!
  @IBOutlet weak var authorized: UILabel!
  @IBOutlet weak var updatedDate: UILabel!
  @IBOutlet weak var status: UILabel!
  @IBOutlet weak var positiveButton: UIButton!
  @IBOutlet weak var negativeButton: UIButton!
  
  // MARK: Properties
  var reportId: Int?
  var report: Report?
  fileprivate var requestBaseURL: String {
    return AppAPI.serviceDomain + AppAPI.getReportById + String(self.reportId!)
  }
  
  fileprivate let userVoteRequestURL = AppAPI.serviceDomain + AppAPI.voteReport
  fileprivate let authorizedReactionRequestURL = AppAPI.serviceDomain + AppAPI.authorizedReaction
  
  // MARK: - LC
  override func viewDidLoad() {
    super.viewDidLoad()
    self.configureUIForRoleId()
    self.reportDetailNetworking()
  }
  
  // MARK: UI
  fileprivate func configureUIForRoleId() {
    if AppReadOnlyUser.roleId != 0 {
      let positiveAuthorizedImage = UIImage(named: "workingAuthorized")
      self.positiveButton.setImage(positiveAuthorizedImage, for: UIControlState())
      
      let completedAuthorizedImage = UIImage(named: "completedAuthorized")
      self.negativeButton.setImage(completedAuthorizedImage, for: UIControlState())
    }
  }
  
  fileprivate func configureUIAfterNetworking() {
    guard let r = self.report else {
      print(AppDebugMessages.reportNotPassed)
      return
    }
    self.navigationItem.title = r.title
    self.reportCategoryLabel.text = r.category
    self.reportDescriptionView.text = r.description
    self.status.text = "Status: \(r.status) Count: \(r.count)"
    self.createdBy.text = "Created By: \(r.createdBy)"
    self.createdDate.text = "Created Date: \(r.createdDate)"
    if let authorizedUser = r.authorizedUser {
        self.authorized.text = "Authorized: \(authorizedUser)"
    }
    else {
      self.authorized.text = "Authorized: Henüz bir yetkili atanmamış!"
    }
    
    self.updatedDate.text = "Updated Date: \(r.updatedDate)"
    
    
    if r.imageUrl.isNotEmpty {
      if let url = URL(string: r.imageUrl) {
        self.reportedImageView.hnk_setImageFromURL(url)
      }
    }
    
    self.configureMapView(report: r)
  }
  
  fileprivate func configureMapView(report r: Report) {
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
  
  // MARK: Action
  @IBAction func confirmAction(_ sender: AnyObject) {
    if AppReadOnlyUser.roleId != 0 { // Authorized
      self.voteNetworking(networkingUrl: self.authorizedReactionRequestURL, actionType: 2)
    }
    else {
      self.voteNetworking(networkingUrl: self.userVoteRequestURL,actionType: 1)
    }
  }
  
  @IBAction func denyAction(_ sender: AnyObject) {
    if AppReadOnlyUser.roleId != 0 { // Authorized
      self.voteNetworking(networkingUrl: self.authorizedReactionRequestURL, actionType: 3)
    }
    else {
      self.voteNetworking(networkingUrl: self.userVoteRequestURL, actionType: 0)
    }
  }
  
}

// MARK: Networking
extension ReportDetailVC {
  
  fileprivate func voteNetworking(networkingUrl url: String, actionType type: Int) {
    let params: [String: AnyObject] = [
      "email": AppReadOnlyUser.email as AnyObject,
      "password": AppReadOnlyUser.password as AnyObject,
      "reportId": self.reportId! as AnyObject,
      "type": type as AnyObject
    ]
    
    Alamofire.request(url, method: .post, parameters: params, encoding: JSONEncoding.default)
      .responseJSON { response in
        
        switch response.result {
        case .success(let value):
          print("vote başarılı", url, separator: "\n")
          let json = JSON(value)
          let serviceCode = json["serviceCode"].intValue
          
          if serviceCode == 0 {
            self.view.dodo.success("Rapor değerlendirme başarılı.")
            print("Rapor değerlendirme başarılı.")
          }
            
          else {
            self.view.dodo.error("Raporu değerlendirme başarısız.")
            print("Raporu değerlendirme başarısız.")
          }
          
        case .failure(let error):
          self.createAlertController(title: AppAlertMessages.networkingFailuredTitle, message: AppAlertMessages.networkingFailuredMessage, controllerStyle: .alert, actionStyle: .destructive)
          debugPrint(error)
        }
    }
  }
  
  fileprivate func reportDetailNetworking() {
    Alamofire.request(self.requestBaseURL, method: .get, encoding: JSONEncoding.default)
      .responseJSON { response in
        
        switch response.result {
        case .success(let value):
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
          
        case .failure(let error):
          self.createAlertController(title: AppAlertMessages.networkingFailuredTitle, message: AppAlertMessages.networkingFailuredMessage, controllerStyle: .alert, actionStyle: .destructive)
          debugPrint(error)
        }
    }
  }
  
  fileprivate func reportDetailNetworkingSuccessful(_ data: JSON) {
    self.writeReportDetailToModel(dataJsonFromNetworking: data)
    self.configureUIAfterNetworking()
  }
  
  fileprivate func reportDetailNetworkingUnsuccessful(_ exception: JSON) {
    let c = exception["exceptionCode"].intValue
    let m = exception["exceptionMessage"].stringValue
    let (title, message) = self.getHandledExceptionDebug(exceptionCode: c, elseMessage: m)
    self.createAlertController(title: title, message: message, controllerStyle: .alert, actionStyle: .default)
  }

}

extension ReportDetailVC {
  fileprivate func writeReportDetailToModel(dataJsonFromNetworking data: JSON) {
    self.report = super.parseReportJSON(data)
    super.reflectAttributes(reflectingObject: super.parseReportJSON(data))
  }
  
}

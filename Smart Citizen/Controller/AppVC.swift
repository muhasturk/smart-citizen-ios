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
import CoreLocation
import SwiftyJSON

class AppVC: UIViewController, CLLocationManagerDelegate {
  
  // MARK: App Object
  var appIndicator = UIActivityIndicatorView()
  var appBlurEffectView = UIVisualEffectView()
  lazy var locationManager: CLLocationManager = self.makeLocationManager()
  
  private func makeLocationManager() -> CLLocationManager {
    let manager = CLLocationManager()
    manager.delegate = self
    manager.desiredAccuracy = kCLLocationAccuracyBest
    manager.requestWhenInUseAuthorization()
    return manager
  }
  
  // MARK: - LC
  override func viewDidLoad() {
    super.viewDidLoad()
  }
  
  // MARK: Add Blur Effect View
  func addBlurEffectView() -> Void {
    let blurEffect = UIBlurEffect(style: .Light)
    appBlurEffectView = UIVisualEffectView(effect: blurEffect)
    appBlurEffectView.frame = self.view.bounds
    appBlurEffectView.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
    self.view.addSubview(appBlurEffectView)
  }
  
  // MARK: - Start Indicator
  func startIndicator() -> Void {
    self.addBlurEffectView()
    appIndicator = UIActivityIndicatorView(frame: CGRectMake(0, 0, 100, 100))
    appIndicator.center = self.view.center
    appIndicator.hidesWhenStopped = true
    appIndicator.activityIndicatorViewStyle = .Gray
    self.view.addSubview(appIndicator)
    appIndicator.startAnimating()
    //UIApplication.sharedApplication().beginIgnoringInteractionEvents()
  }
  
  // MARK: Stop Indicator
  func stopIndicator() -> Void {
    //UIApplication.sharedApplication().endIgnoringInteractionEvents()
    appIndicator.stopAnimating()
    appBlurEffectView.removeFromSuperview()
  }
  
  // MARK: - Create Alert Controller
  func createAlertController(title title: String, message: String, controllerStyle: UIAlertControllerStyle, actionStyle: UIAlertActionStyle) -> Void {
    let alertController = UIAlertController(title: title, message: message, preferredStyle: controllerStyle)
    
    let okAction = UIAlertAction(title: "Tamam", style: actionStyle, handler: nil)
    alertController.addAction(okAction)
    self.presentViewController(alertController, animated: true, completion: nil)
  }
  
  // MARK: - Get Exception Title
  func getHandledExceptionDebug(exceptionCode code: Int, elseMessage: String) -> (String, String) {
    
    var title: String!
    var message: String!
    
    switch code {
    case ExceptionCode.EmailOrPasswordWrong.rawValue: // 1
      title = AppAlertMessages.exceptionLoginWrongCredentialsTitle
      message = AppAlertMessages.exceptionLoginWrongCredentialsMessage
      
    case ExceptionCode.ThereIsNoUserWithEmail.rawValue: // 2
      title = AppAlertMessages.exceptionLoginThereIsNoUserWithEmailTitle
      message = AppAlertMessages.exceptionLoginThereIsNoUserWithEmailMessage
      
    case ExceptionCode.ThereIsaMemberWithEmail.rawValue: // 3
      title = AppAlertMessages.exceptionAlreadyRegisteredEmailTitle
      message = AppAlertMessages.exceptionAlreadyRegisteredEmailMessage
      
    case ExceptionCode.BadRequest.rawValue:
      title = AppAlertMessages.parameterMissingTitle
      message = AppAlertMessages.parameterMissingMessage
      
    default:
      title = AppAlertMessages.defaultHandleExceptionCodeTitle
      message = AppAlertMessages.defaultHandleExceptionCodeMessage
      print("ExceptionCode: \(code)\nExceptionMessage: \(elseMessage)")
    }
    
    return (title, message)
  }
  
  // MARK: - Mirror
  func reflectAttributes(reflectingObject o: Any) {
    let m = Mirror(reflecting: o)
    for (index, attribute) in m.children.enumerate() {
      if let property = attribute.label as String! {
        print("\(index) - \(property) - \(attribute.value)")
      }
    }
  }
  
  // MARK: - Keyboard Observer
  func addKeyboardObserver() {
    NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(keyboardWillShow), name: UIKeyboardWillShowNotification, object: nil)
    NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(keyboardWillHide), name: UIKeyboardWillHideNotification, object: nil)
  }
  
  func removeKeyboardObserver() {
    NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillShowNotification, object: self.view.window)
    NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillHideNotification, object: self.view.window)
  }
  
  func keyboardWillShow(sender: NSNotification) {
    let userInfo: [NSObject : AnyObject] = sender.userInfo!
    let keyboardSize: CGSize = userInfo[UIKeyboardFrameBeginUserInfoKey]!.CGRectValue.size
    let offset: CGSize = userInfo[UIKeyboardFrameEndUserInfoKey]!.CGRectValue.size
    
    if keyboardSize.height == offset.height {
      if self.view.frame.origin.y == 0 {
        UIView.animateWithDuration(0.1, animations: { () -> Void in
          self.view.frame.origin.y -= keyboardSize.height
        })
      }
    } else {
      UIView.animateWithDuration(0.1, animations: { () -> Void in
        self.view.frame.origin.y += keyboardSize.height - offset.height
      })
    }
  }
  
  func keyboardWillHide(sender: NSNotification) {
    let userInfo: [NSObject : AnyObject] = sender.userInfo!
    let keyboardSize: CGSize = userInfo[UIKeyboardFrameBeginUserInfoKey]!.CGRectValue().size
    self.view.frame.origin.y += keyboardSize.height
  }
  
}

// MARK: Parse
extension AppVC {
  func parseReportJSON(reportJSON: JSON) -> Report {
    let r = Report()
    r.authorizedUser = reportJSON["authorizedUser"].stringValue
    r.category = reportJSON["category"].stringValue
    r.categoryId = reportJSON["categoryId"].intValue
    r.city = reportJSON["city"].stringValue
    r.count = reportJSON["count"].intValue
    r.createdBy = reportJSON["createdBy"].stringValue
    r.createdById = reportJSON["createdById"].intValue
    r.createdDate = reportJSON["createdDate"].stringValue
    r.description = reportJSON["description"].stringValue
    r.district = reportJSON["district"].stringValue
    r.id = reportJSON["id"].intValue
    r.imageUrl = reportJSON["imageUrl"].stringValue
    r.latitude = reportJSON["latitude"].doubleValue
    r.longitude = reportJSON["longitude"].doubleValue
    r.neighborhood = reportJSON["neighborhood"].stringValue
    r.status = reportJSON["status"].stringValue
    r.statusId = reportJSON["statusId"].intValue
    r.title = reportJSON["title"].stringValue
    r.updatedDate = reportJSON["updatedDate"].stringValue
    return r
  }
}

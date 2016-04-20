//
//  AppVC.swift
//  Smart Citizen
//
//  Created by Mustafa Hastürk on 12/04/16.
//  Copyright © 2016 Mustafa Hastürk. All rights reserved.
//

import UIKit

class AppVC: UIViewController {
  
  // MARK: App Object
  var appIndicator: UIActivityIndicatorView = UIActivityIndicatorView()
  var appBlurEffectView: UIVisualEffectView = UIVisualEffectView()
  
  // MARK: - LC
  override func viewDidLoad() {
    super.viewDidLoad()
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
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
      
    default:
      title = AppAlertMessages.defaultHandleExceptionCodeTitle
      message = AppAlertMessages.defaultHandleExceptionCodeMessage
      debugPrint(elseMessage)
    }
    
    return (title, message)
  }
}

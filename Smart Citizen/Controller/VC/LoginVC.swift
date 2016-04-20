//
//  LoginVC.swift
//  Smart Citizen
//
//  Created by Mustafa Hastürk on 03/12/15.
//  Copyright © 2015 Mustafa Hastürk. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class LoginVC: AppVC {
  
  @IBOutlet weak var emailField: UITextField!
  @IBOutlet weak var passwordField: UITextField!
  @IBOutlet weak var resultLabel: UILabel!
  
  private let requestBaseURL = AppAPI.loginServiceURL
  
  override func viewDidLoad() {
    super.viewDidLoad()
    self.navigationItem.title = "Login"
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
  }
  
  @IBAction func loginButtonAction(sender: AnyObject) {
    let email = self.emailField.text!
    let password = self.passwordField.text!
    
    if email.isEmpty || password.isEmpty {
      self.createAlertController(title: AppAlertMessages.missingFieldTitle,
                                 message: AppAlertMessages.loginMissingFieldMessage, controllerStyle: .Alert, actionStyle: .Default)
    }
      
    else if email.isNotEmail {
      self.createAlertController(title: AppAlertMessages.loginEmailFieldNotValidatedTitle, message: AppAlertMessages.loginEmailFieldNotValidatedMessage, controllerStyle: .Alert, actionStyle: .Default)
    }
      
    else {
      let parameters = [
        "email": emailField,
        "password": password
      ]
      self.loginNetworking(networkingParameters: parameters)
    }
  }
  
  private func loginNetworking(networkingParameters params: [String: AnyObject]) {
    Alamofire.request(.POST, self.requestBaseURL, parameters: params, encoding: .JSON)
      .responseJSON { response in
        self.stopIndicator()
        
        switch response.result {
        case .Success(let value):
          print(AppDebugMessages.serviceConnectionLoginIsOk, self.requestBaseURL, separator: "\n")
          let json = JSON(value)
          let serviceCode = json["serviceCode"].intValue
          let data = json["data"]
          
          if serviceCode == 0 {
            if data.isExists() && data.isNotEmpty{
              self.writeUserDataToModel(dataJsonFromNetworking: data)
              self.performSegueWithIdentifier(AppSegues.doLoginSegue, sender: nil)
            }
            else {
              print(AppDebugMessages.keyDataIsNotExistOrIsEmpty)
              debugPrint(data)
            }
          }
            
          else {
            let exception = json["exception"]
            let c = json["exceptionCode"].stringValue
            let m = exception["Message"].stringValue
            let (title, message) = self.handleExceptionCodes(exceptionCodeString: c, elseMessage: m)
            self.createAlertController(title: title, message: message, controllerStyle: .Alert, actionStyle: .Default)
          }
          
        case .Failure(let error):
          self.createAlertController(title: AppAlertMessages.networkingFailuredTitle, message: AppAlertMessages.networkingFailuredMessage, controllerStyle: .Alert, actionStyle: .Destructive)
          debugPrint(error)
        }
    }
  }
  
  private func writeUserDataToModel(dataJsonFromNetworking data: JSON) {
    
  }
  
  func textFieldShouldReturn(textField: UITextField) -> Bool {
    if textField == self.emailField {
      self.passwordField.becomeFirstResponder()
    }
    else {
      self.loginButtonAction(textField)
    }
    return true
  }
  
  override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
    self.view.endEditing(true)
  }
}

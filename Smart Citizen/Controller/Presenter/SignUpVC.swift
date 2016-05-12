//
//  SignUpVC.swift
//  Smart Citizen
//
//  Created by Mustafa Hastürk on 03/12/15.
//  Copyright © 2015 Mustafa Hastürk. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class SignUpVC: AppVC {
  
  @IBOutlet weak var fullNameField: UITextField!
  @IBOutlet weak var emailField: UITextField!
  @IBOutlet weak var passwordField: UITextField!
  
  private let requestBaseURL = AppAPI.serviceDomain + AppAPI.signUpServiceURL

  
  // MARK: - LC
  override func viewDidLoad() {
    super.viewDidLoad()
    self.navigationItem.title = "Sign Up"
  }
  
  @IBAction func signUpAction(sender: AnyObject) {
    self.view.endEditing(true)
    let fullName = self.fullNameField.text!
    let email = self.emailField.text!
    let password = self.passwordField.text!
    
    if fullName.isEmpty || email.isEmpty || password.isEmpty {
      self.createAlertController(title: AppAlertMessages.missingFieldTitle,
                                 message: AppAlertMessages.loginMissingFieldMessage, controllerStyle: .Alert, actionStyle: .Default)
    }
      
    else if email.isNotEmail {
      self.createAlertController(title: AppAlertMessages.emailFieldNotValidatedTitle, message: AppAlertMessages.emailFieldNotValidatedMessage, controllerStyle: .Alert, actionStyle: .Default)
    }
      
    else {
      let parameters = [
        "fullName": fullName,
        "email": email,
        "password": password,
        "deviceToken": NSUserDefaults.standardUserDefaults().stringForKey(AppConstants.DefaultKeys.DEVICE_TOKEN) ?? "5005"
      ]
      self.signUpNetworking(networkingParameters: parameters)
    }
    
  }
  
  private func signUpNetworking(networkingParameters params: [String: AnyObject]) {
    self.startIndicator()

    Alamofire.request(.POST, self.requestBaseURL, parameters: params, encoding: .JSON)
      .responseJSON { response in
        self.stopIndicator()
        
        switch response.result {
        case .Success(let value):
          print(AppDebugMessages.serviceConnectionSignUpIsOk, self.requestBaseURL, separator: "\n")
          let json = JSON(value)
          let serviceCode = json["serviceCode"].intValue
          let data = json["data"]
          
          if serviceCode == 0 {
            if data.isExists() && data.isNotEmpty{
              self.writeUserDataToModel(dataJsonFromNetworking: data)
              self.performSegueWithIdentifier(AppSegues.doSignUpSegue, sender: nil)
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
  
  private func writeUserDataToModel(dataJsonFromNetworking data: JSON) {
    AppConstants.AppUser.id = data["id"].intValue
    AppConstants.AppUser.email = data["email"].stringValue
    AppConstants.AppUser.fullName = data["fullName"].stringValue
    AppConstants.AppUser.password = data["password"].stringValue
    AppConstants.AppUser.roleId = data["roleId"].intValue
    AppConstants.AppUser.roleName = data["roleName"].stringValue
    
    super.reflectAttributes(reflectingObject: AppConstants.AppUser)
    
    self.saveLocalSession()
  }

  private func saveLocalSession() {
    NSUserDefaults.standardUserDefaults().setBool(true, forKey: AppConstants.DefaultKeys.APP_ALIVE)
    let encodedUser = NSKeyedArchiver.archivedDataWithRootObject(AppConstants.AppUser)
    NSUserDefaults.standardUserDefaults().setObject(encodedUser, forKey: AppConstants.DefaultKeys.APP_USER)
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
  }
  
  func textFieldShouldReturn(textField: UITextField) -> Bool {
    if textField == self.fullNameField {
      self.emailField.becomeFirstResponder()
    }
    else if textField == self.emailField{
      self.passwordField.becomeFirstResponder()
    }
    else {
      self.signUpAction(textField)
    }
    return true
  }
  
  override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
    self.view.endEditing(true)
  }
}

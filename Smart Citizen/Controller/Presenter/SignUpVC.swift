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
import Alamofire
import SwiftyJSON

class SignUpVC: AppVC {
  
  @IBOutlet weak var fullNameField: UITextField!
  @IBOutlet weak var emailField: UITextField!
  @IBOutlet weak var passwordField: UITextField!
  
  fileprivate let requestBaseURL = AppAPI.serviceDomain + AppAPI.signUpServiceURL

  
  // MARK: - LC
  override func viewDidLoad() {
    super.viewDidLoad()
    self.navigationItem.title = "Sign Up"
  }
  
  @IBAction func signUpAction(_ sender: AnyObject) {
    self.view.endEditing(true)
    let fullName = self.fullNameField.text!
    let email = self.emailField.text!
    let password = self.passwordField.text!
    
    if fullName.isEmpty || email.isEmpty || password.isEmpty {
      self.createAlertController(title: AppAlertMessages.missingFieldTitle,
                                 message: AppAlertMessages.loginMissingFieldMessage, controllerStyle: .alert, actionStyle: .default)
    }
      
    else if email.isNotEmail {
      self.createAlertController(title: AppAlertMessages.emailFieldNotValidatedTitle, message: AppAlertMessages.emailFieldNotValidatedMessage, controllerStyle: .alert, actionStyle: .default)
    }
      
    else {
      let parameters = [
        "fullName": fullName,
        "email": email,
        "password": password,
        "deviceToken": UserDefaults.standard.string(forKey: AppConstants.DefaultKeys.DEVICE_TOKEN) ?? "5005"
      ]
      self.signUpNetworking(networkingParameters: parameters as [String : AnyObject])
    }
    
  }
  
  
  
  fileprivate func writeUserDataToModel(dataJsonFromNetworking data: JSON) {
    let user = User()
    user.id = data["id"].intValue
    user.email = data["email"].stringValue
    user.fullName = data["fullName"].stringValue
    user.password = data["password"].stringValue
    user.roleId = data["roleId"].intValue
    user.roleName = data["roleName"].stringValue
    
    super.reflectAttributes(reflectingObject: user)
    
    self.saveLocalSession(user)
  }

  fileprivate func saveLocalSession(_ user: User) {
    UserDefaults.standard.set(true, forKey: AppConstants.DefaultKeys.APP_ALIVE)
    let encodedUser = NSKeyedArchiver.archivedData(withRootObject: user)
    UserDefaults.standard.set(encodedUser, forKey: AppConstants.DefaultKeys.APP_USER)
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
  }
  
  func textFieldShouldReturn(_ textField: UITextField) -> Bool {
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
  
  override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
    self.view.endEditing(true)
  }
}

// MARK: - Networking
extension SignUpVC {
  fileprivate func signUpNetworking(networkingParameters params: [String: AnyObject]) {
    self.startIndicator()
    
    Alamofire.request(.POST, self.requestBaseURL, parameters: params, encoding: .json)
      .responseJSON { response in
        self.stopIndicator()
        
        switch response.result {
        case .success(let value):
          print(AppDebugMessages.serviceConnectionSignUpIsOk, self.requestBaseURL, separator: "\n")
          let json = JSON(value)
          let serviceCode = json["serviceCode"].intValue
          
          if serviceCode == 0 {
            let data = json["data"]
            self.signUpNetworkingSuccessful(data)
          }
            
          else {
            let exception = json["exception"]
            self.signUpNetworkingUnuccessful(exception)
          }
          
        case .failure(let error):
          self.createAlertController(title: AppAlertMessages.networkingFailuredTitle, message: AppAlertMessages.networkingFailuredMessage, controllerStyle: .alert, actionStyle: .destructive)
          debugPrint(error)
        }
    }
  }
  
  fileprivate func signUpNetworkingSuccessful(_ data: JSON) {
    self.writeUserDataToModel(dataJsonFromNetworking: data)
    self.performSegue(withIdentifier: AppSegues.doSignUpSegue, sender: nil)
  }
  
  fileprivate func signUpNetworkingUnuccessful(_ exception: JSON) {
    let c = exception["exceptionCode"].intValue
    let m = exception["exceptionMessage"].stringValue
    let (title, message) = self.getHandledExceptionDebug(exceptionCode: c, elseMessage: m)
    self.createAlertController(title: title, message: message, controllerStyle: .alert, actionStyle: .default)
  }
}

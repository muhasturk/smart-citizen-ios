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

class LoginVC: AppVC {
  
  @IBOutlet weak var emailField: UITextField!
  @IBOutlet weak var passwordField: UITextField!
  @IBOutlet weak var resultLabel: UILabel!
  
  private let requestBaseURL = AppAPI.serviceDomain + AppAPI.loginServiceURL
  
  override func viewDidLoad() {
    super.viewDidLoad()
    self.navigationItem.title = "Login"
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
  }
  
  @IBAction func loginButtonAction(sender: AnyObject) {
    self.view.endEditing(true)
    let email = self.emailField.text!
    let password = self.passwordField.text!
    
    if email.isEmpty || password.isEmpty {
      self.createAlertController(title: AppAlertMessages.missingFieldTitle,
                                 message: AppAlertMessages.loginMissingFieldMessage, controllerStyle: .Alert, actionStyle: .Default)
    }
      
    else if email.isNotEmail {
      self.createAlertController(title: AppAlertMessages.emailFieldNotValidatedTitle, message: AppAlertMessages.emailFieldNotValidatedMessage, controllerStyle: .Alert, actionStyle: .Default)
    }
      
    else {
      let parameters = [
        "email": email,
        "password": password,
        "deviceToken": NSUserDefaults.standardUserDefaults().stringForKey(AppConstants.DefaultKeys.DEVICE_TOKEN) ?? "5005"
      ]
      self.loginNetworking(networkingParameters: parameters)
    }
  }
  
  // MARK: - Networking
  private func loginNetworking(networkingParameters params: [String: AnyObject]) {
    self.startIndicator()
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
  
  // MARK: - Model
  private func writeUserDataToModel(dataJsonFromNetworking data: JSON) {
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
  
  private func saveLocalSession(user: User) {
    NSUserDefaults.standardUserDefaults().setBool(true, forKey: AppConstants.DefaultKeys.APP_ALIVE)
    let encodedUser = NSKeyedArchiver.archivedDataWithRootObject(user)
    NSUserDefaults.standardUserDefaults().setObject(encodedUser, forKey: AppConstants.DefaultKeys.APP_USER)
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

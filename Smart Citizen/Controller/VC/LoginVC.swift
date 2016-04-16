//
//  LoginVC.swift
//  Smart Citizen
//
//  Created by Mustafa Hastürk on 03/12/15.
//  Copyright © 2015 Mustafa Hastürk. All rights reserved.
//

import UIKit

class LoginVC: AppVC {
  
  @IBOutlet weak var emailField: UITextField!
  @IBOutlet weak var passwordField: UITextField!
  @IBOutlet weak var resultLabel: UILabel!
  
  private let baseRequestURL = AppAPI.loginServiceURL
  
  override func viewDidLoad() {
    super.viewDidLoad()
    self.navigationItem.title = "Login"
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
  }
  
  @IBAction func loginAction(sender: AnyObject) {

  }
  
  private func loginNetworking(networkingParameters params: [String: AnyObject]) {
    
  }
  
  func textFieldShouldReturn(textField: UITextField) -> Bool {
    if textField == self.emailField {
      self.passwordField.becomeFirstResponder()
    }
    else {
      self.loginAction(textField)
    }
    return true
  }
  
  override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
    self.view.endEditing(true)
  }
}

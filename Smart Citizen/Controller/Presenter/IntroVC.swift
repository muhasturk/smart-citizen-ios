//
//  IntroVC.swift
//  Smart Citizen
//
//  Created by Mustafa Hastürk on 03/05/16.
//  Copyright © 2016 Mustafa Hastürk. All rights reserved.
//

import UIKit

class IntroVC: AppVC {
  
  // MARK: - LC
  override func viewDidLoad() {
    super.viewDidLoad()
  }
  
  @IBAction func imageUpload(sender: AnyObject) {
  }
  
  override func viewWillAppear(animated: Bool) {
    self.navigationController?.navigationBarHidden = true
  }
  
  override func viewWillDisappear(animated: Bool) {
    super.viewWillDisappear(animated)
    if (self.navigationController?.topViewController != self) {
      self.navigationController?.navigationBarHidden = false
    }
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
  }

}

//
//  ReportDetailVC.swift
//  Smart Citizen
//
//  Created by Mustafa Hastürk on 11/05/16.
//  Copyright © 2016 Mustafa Hastürk. All rights reserved.
//

import UIKit

class ReportDetailVC: AppVC {

  var reportId: Int?
  
  @IBOutlet weak var label: UILabel!
  // MARK: - LC
  override func viewDidLoad() {
    super.viewDidLoad()
    if let a = reportId {
      self.label.text = String(a)
    }
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
  }
  
  
}

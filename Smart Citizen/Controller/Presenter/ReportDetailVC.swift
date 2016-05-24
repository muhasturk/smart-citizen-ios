//
//  ReportDetailVC.swift
//  Smart Citizen
//
//  Created by Mustafa Hastürk on 11/05/16.
//  Copyright © 2016 Mustafa Hastürk. All rights reserved.
//

import UIKit

class ReportDetailVC: AppVC {

  @IBOutlet weak var reportedImageView: UIImageView!
  @IBOutlet weak var reportDescriptionView: UITextView!
  // MARK: Properties
  var reportId: Int?
  var report: Report?
  
  // MARK: - LC
  override func viewDidLoad() {
    super.viewDidLoad()
    self.configureUI()
  }
  
  private func configureUI() {
    
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
  }
  
  
  
}

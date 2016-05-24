//
//  ReportDetailVC.swift
//  Smart Citizen
//
//  Created by Mustafa Hastürk on 11/05/16.
//  Copyright © 2016 Mustafa Hastürk. All rights reserved.
//

import UIKit
import Haneke

class ReportDetailVC: AppVC {

  @IBOutlet weak var reportedImageView: UIImageView!
  @IBOutlet weak var reportDescriptionView: UITextView!
  
  @IBOutlet weak var reportCategoryLabel: UILabel!
  
  // MARK: Properties
  var reportId: Int?
  var report: Report?
  
  // MARK: - LC
  override func viewDidLoad() {
    super.viewDidLoad()
    self.configureUI()
  }
  
  private func configureUI() {
    guard let r = self.report else {
      print(AppDebugMessages.reportNotPassed)
      return
    }
    self.navigationItem.title = r.title
    self.reportCategoryLabel.text = r.type
    self.reportDescriptionView.text = r.description
    
    if r.imageUrl.isNotEmpty {
      if let url = NSURL(string: r.imageUrl) {
        self.reportedImageView.hnk_setImageFromURL(url)
      }
      else {
        print("Report id: \(r.id) has invalid image URL as you see: \(r.imageUrl)")
      }
    }
      
    else {
      print("Report id: \(r.id) has empty image URL")
    }
    
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
  }
  
  
  
}

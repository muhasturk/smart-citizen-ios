//
//  DashboardVC.swift
//  Smart Citizen
//
//  Created by Mustafa Hastürk on 03/12/15.
//  Copyright © 2015 Mustafa Hastürk. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class DashboardVC: AppVC {
  
  @IBOutlet weak var dashboardTableView: UITableView!
  
  private var requestBaseURL = AppAPI.dashboardServiceURL + String(AppConstants.AppUser.roleId)
  
  private var reporstDict: [String: [String: Any]] = [String: [String: Any]]()
  
  // MARK: - LC
  override func viewDidLoad() {
    super.viewDidLoad()
    print(self.requestBaseURL)
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
  }
  
  // MARK: - Table Delegate
  func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return 1
  }
  
  // MARK: - Networkng
  private func dashboardNetworking(networkingParameters params: [String: AnyObject]) {
    self.startIndicator()
    Alamofire.request(.GET, self.requestBaseURL, parameters: params, encoding: .JSON)
      .responseJSON { response in
        self.stopIndicator()
        
        switch response.result {
        case .Success(let value):
          print(AppDebugMessages.serviceConnectionDashboardIsOk, self.requestBaseURL, separator: "\n")
          let json = JSON(value)
          let serviceCode = json["serviceCode"].intValue
          let data = json["data"]
          
          if serviceCode == 0 {
            if data.isExists() && data.isNotEmpty{
              self.writeDashboardDataToModel(dataJsonFromNetworking: data)
              self.dashboardTableView.reloadData()
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
  
  // MARK: Write Model
  private func writeDashboardDataToModel(dataJsonFromNetworking data: JSON) {
    for (reportTypeName, reportTypeJSON): (String, JSON) in data {
      print(reportTypeName)
    }
  }
  
  
}

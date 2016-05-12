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
  
  private var requestBaseURL: String {
    let userData = NSUserDefaults.standardUserDefaults().objectForKey(AppConstants.DefaultKeys.APP_USER) as! NSData
    let user = NSKeyedUnarchiver.unarchiveObjectWithData(userData) as! User
    return AppAPI.serviceDomain + AppAPI.dashboardServiceURL + String(user.roleId)
  }
  
  private var reportsDict: [String: [Report]] = [String: [Report]]()
  
  // MARK: - LC
  override func viewDidLoad() {
    super.viewDidLoad()
    self.dashboardNetworking()
    //print(self.requestBaseURL)
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
  }
  
  // MARK: - Table Delegate
  func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return 1
  }
  
  // MARK: - Networkng
  private func dashboardNetworking() {
    self.startIndicator()
    Alamofire.request(.GET, self.requestBaseURL, encoding: .JSON)
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
              //self.debugReportsDict()
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
    self.reportsDict = [:]
    for (reportTypeName, reportTypeJSON): (String, JSON) in data {
      self.reportsDict[reportTypeName] = []
      for (_, reportData): (String, JSON) in reportTypeJSON {
        let r = Report()
        r.id = reportData["id"].intValue
        r.title = reportData["title"].stringValue
        r.description = reportData["description"].stringValue
        r.count = reportData["count"].intValue
        r.type = reportData["reportType"].stringValue // change key name
        r.status = reportData["status"].stringValue
        r.statusId = reportData["statusId"].intValue
        self.reportsDict[reportTypeName]?.append(r)
      }
    }
  }
  
  func debugReportsDict() {
    for (h, rd) in self.reportsDict {
      print("Header: \(h)")
      for r in rd {
        super.reflectAttributes(reflectingObject: r)
        print("---------------------------")
      }
    }
  }
  
}

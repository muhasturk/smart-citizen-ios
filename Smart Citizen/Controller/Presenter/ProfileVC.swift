//
//  ProfileVC.swift
//  Smart Citizen
//
//  Created by Mustafa Hastürk on 21/11/15.
//  Copyright © 2015 Mustafa Hastürk. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class ProfileVC: AppVC {
  
  @IBOutlet weak var profileImageView: CircleImageView!
  @IBOutlet weak var userName: UILabel!
  @IBOutlet weak var role: UILabel!
  @IBOutlet weak var profileSegment: UISegmentedControl!
  @IBOutlet weak var profileTable: UITableView!
  
  private var requestBaseURL: String {
    return AppAPI.serviceDomain + AppAPI.profileServiceURL + String(23)
  }
  
  var reportsDict = [String: [Report]]()
  
  // MARK: - LC
  override func viewDidLoad() {
    super.viewDidLoad()
    self.configureProfileUI()
    print("default selected segment: \(self.profileSegment.selectedSegmentIndex)")
  }
  
  override func viewDidAppear(animated: Bool) {
    super.viewDidAppear(true)
    self.profileNetworking()
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
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
  
  // MARK: - Networking
  private func profileNetworking() {
    self.startIndicator()
    Alamofire.request(.GET, self.requestBaseURL, encoding: .JSON)
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
              self.profileTable.reloadData()
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
    self.reportsDict = [:]
    for (statusName, statusArrayJSON): (String, JSON) in data {
      self.reportsDict[statusName] = []
      for (_, statusArrayJSON): (String, JSON) in statusArrayJSON {
      let r = Report()
      r.id = statusArrayJSON["id"].intValue
      r.title = statusArrayJSON["title"].stringValue
      r.description = statusArrayJSON["description"].stringValue
      r.count = statusArrayJSON["count"].intValue
      r.type = statusArrayJSON["type"].stringValue
      r.typeId = statusArrayJSON["typeId"].intValue
      r.status = statusArrayJSON["status"].stringValue
      r.statusId = statusArrayJSON["statusId"].intValue
      r.imageUrl = statusArrayJSON["imageUrl"].stringValue
      self.reportsDict[statusName]?.append(r)
      }
    }
  }

  
  // MARK: - Table
  
  func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return 1
  }
  
  func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCellWithIdentifier("profileCell", forIndexPath: indexPath)
    
    var tabReports = [Report]()
    switch self.profileSegment.selectedSegmentIndex {
    case 0:
      if let reports = self.reportsDict["1"] {
        tabReports = reports
      }
    case 1:
      if let reports = self.reportsDict["2"] {
        tabReports = reports
      }
    case 2:
      if let reports = self.reportsDict["3"] {
        tabReports = reports
      }
    case 3:
      if let reports = self.reportsDict["4"] {
        tabReports = reports
      }
    default:
      break
    }
    if tabReports.isEmpty {
      return UITableViewCell()
    }
    else {
      cell.textLabel?.text = tabReports[indexPath.row].title
      return cell
    }
  }
  
  private func configureProfileUI() {
    print("is it callde?")
    self.profileImageView.layer.cornerRadius = (self.profileImageView.frame.height) / 2
    self.profileImageView.clipsToBounds = true
  }
  
}



































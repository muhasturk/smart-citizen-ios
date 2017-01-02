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

class DashboardVC: AppVC, UITableViewDataSource, UITableViewDelegate {
  
  @IBOutlet weak var dashboardTableView: UITableView!
  var refreshControl: UIRefreshControl!
  
  fileprivate var requestBaseURL: String {
    return AppAPI.serviceDomain + AppAPI.dashboardServiceURL + String(AppReadOnlyUser.roleId)
  }
  
  fileprivate var reportsDict: [String: [Report]] = [:]
  fileprivate var firstNetworking = true
  
  // MARK: - LC
  override func viewDidLoad() {
    super.viewDidLoad()
    self.configureTableView()
    self.dashboardNetworking()
  }
  
  fileprivate func configureTableView() {
    refreshControl = UIRefreshControl()
    refreshControl.tintColor = UIColor.red
    refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
    refreshControl.addTarget(self, action: #selector(self.dashboardNetworking), for: UIControlEvents.valueChanged)
    self.dashboardTableView.addSubview(refreshControl)
  }
  
  // MARK: - Table Delegate
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    let index = self.reportsDict.index(self.reportsDict.startIndex, offsetBy: section)
    let key: String = self.reportsDict.keys[index]
    guard let reports = self.reportsDict[key] else {
      print("warning there is no '\(key)' key inside dict \(#function)")
      return 1
    }
    return reports.count
  }
  
  func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
    let index = self.reportsDict.index(self.reportsDict.startIndex, offsetBy: section)
    let key = self.reportsDict.keys[index]
    return key
  }
  
  func numberOfSections(in tableView: UITableView) -> Int {
    return self.reportsDict.keys.count
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "dashboardCell", for: indexPath)
    let sectionIndex = self.reportsDict.index(self.reportsDict.startIndex, offsetBy: (indexPath as NSIndexPath).section)
    let key = self.reportsDict.keys[sectionIndex]
    guard let reportsArray = self.reportsDict[key] else {
      print("warning there is no '\(key)' key inside dict \(#function)")
      return UITableViewCell()
    }
    cell.textLabel?.text = reportsArray[(indexPath as NSIndexPath).row].title
    return cell
  }
  
  func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
    let index = self.reportsDict.index(self.reportsDict.startIndex, offsetBy: section)
    let key = self.reportsDict.keys[index]
    guard let reports = self.reportsDict[key] else {
      return nil
    }
    let count = reports.count
    return "\(key) kategorisinde \(count) rapor var."
  }
  
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    performSegue(withIdentifier: AppSegues.dashboardReportDetail, sender: indexPath)
  }
  
  var selectedReportId: Int?

  
  
  // MARK: Write Model
  fileprivate func writeDashboardDataToModel(dataJsonFromNetworking data: JSON) {
    self.reportsDict = [:]
    for (reportTypeName, reportTypeJSON): (String, JSON) in data {
      self.reportsDict[reportTypeName] = []
      for (_, reportData): (String, JSON) in reportTypeJSON {
        let r = Report()
        r.id = reportData["id"].intValue
        r.title = reportData["title"].stringValue
        r.description = reportData["description"].stringValue
        r.count = reportData["count"].intValue
        r.category = reportData["category"].stringValue
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
      }
    }
  }
  
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if segue.identifier == AppSegues.dashboardReportDetail {
      if let detailVC = segue.destination as? ReportDetailVC {
        if let indexPath = sender as? IndexPath {
          let index = self.reportsDict.index(self.reportsDict.startIndex, offsetBy: (indexPath as NSIndexPath).section)
          let key = self.reportsDict.keys[index]
          if let reports = self.reportsDict[key] {
            detailVC.reportId = reports[(indexPath as NSIndexPath).row].id
            detailVC.report = reports[(indexPath as NSIndexPath).row]
          }
        }
      }
    }
  }
  
}

// MARK: - Networkng
extension DashboardVC {
  func dashboardNetworking() {
    if firstNetworking {
      self.startIndicator()
    }
    Alamofire.request(self.requestBaseURL, method: .get, parameters: nil)
      .responseJSON { response in
        if self.firstNetworking {
          self.stopIndicator()
          self.firstNetworking = false
        }
        switch response.result {
        case .success(let value):
          print(AppDebugMessages.serviceConnectionDashboardIsOk, self.requestBaseURL, separator: "\n")
          let json = JSON(value)
          let serviceCode = json["serviceCode"].intValue
                    
          if serviceCode == 0 {
            let data = json["data"]
            self.dashboardNetworkingSuccessful(data)
          }
            
          else {
            let exception = json["exception"]
            self.dashboardNetworkingUnsuccessful(exception)
          }
          
        case .failure(let error):
          self.createAlertController(title: AppAlertMessages.networkingFailuredTitle, message: AppAlertMessages.networkingFailuredMessage, controllerStyle: .alert, actionStyle: .destructive)
          debugPrint(error)
        }
    }
  }
  
  fileprivate func dashboardNetworkingSuccessful(_ data: JSON) {
    self.writeDashboardDataToModel(dataJsonFromNetworking: data)
    self.dashboardTableView.reloadData()
    if self.refreshControl.isRefreshing {
      self.refreshControl.endRefreshing()
    }
    //self.debugReportsDict()
  }
  
  fileprivate func dashboardNetworkingUnsuccessful(_ exception: JSON) {
    let c = exception["exceptionCode"].intValue
    let m = exception["exceptionMessage"].stringValue
    let (title, message) = self.getHandledExceptionDebug(exceptionCode: c, elseMessage: m)
    self.createAlertController(title: title, message: message, controllerStyle: .alert, actionStyle: .default)
  }
  
}

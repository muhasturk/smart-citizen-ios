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
  
  private var requestBaseURL: String {
    return AppAPI.serviceDomain + AppAPI.dashboardServiceURL + String(AppReadOnlyUser.roleId)
  }
  
  private var reportsDict: [String: [Report]] = [:]
  private var firstNetworking = true
  
  // MARK: - LC
  override func viewDidLoad() {
    super.viewDidLoad()
    self.configureTableView()
    self.dashboardNetworking()
  }
  
  private func configureTableView() {
    refreshControl = UIRefreshControl()
    refreshControl.tintColor = UIColor.redColor()
    refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
    refreshControl.addTarget(self, action: #selector(self.dashboardNetworking), forControlEvents: UIControlEvents.ValueChanged)
    self.dashboardTableView.addSubview(refreshControl)
  }
  
  // MARK: - Table Delegate
  func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    let index = self.reportsDict.startIndex.advancedBy(section)
    let key: String = self.reportsDict.keys[index]
    guard let reports = self.reportsDict[key] else {
      print("warning there is no '\(key)' key inside dict \(#function)")
      return 1
    }
    return reports.count
  }
  
  func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
    let index = self.reportsDict.startIndex.advancedBy(section)
    let key = self.reportsDict.keys[index]
    return key
  }
  
  func numberOfSectionsInTableView(tableView: UITableView) -> Int {
    return self.reportsDict.keys.count
  }
  
  func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCellWithIdentifier("dashboardCell", forIndexPath: indexPath)
    let sectionIndex = self.reportsDict.startIndex.advancedBy(indexPath.section)
    let key = self.reportsDict.keys[sectionIndex]
    guard let reportsArray = self.reportsDict[key] else {
      print("warning there is no '\(key)' key inside dict \(#function)")
      return UITableViewCell()
    }
    cell.textLabel?.text = reportsArray[indexPath.row].title
    return cell
  }
  
  func tableView(tableView: UITableView, titleForFooterInSection section: Int) -> String? {
    let index = self.reportsDict.startIndex.advancedBy(section)
    let key = self.reportsDict.keys[index]
    guard let reports = self.reportsDict[key] else {
      return nil
    }
    let count = reports.count
    return "\(key) kategorisinde \(count) rapor var."
  }
  
  func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    performSegueWithIdentifier(AppSegues.dashboardReportDetail, sender: indexPath)
  }
  
  var selectedReportId: Int?

  // MARK: - Networkng
  func dashboardNetworking() {
    if firstNetworking {
      self.startIndicator()
    }
    Alamofire.request(.GET, self.requestBaseURL, encoding: .JSON)
      .responseJSON { response in
        if self.firstNetworking {
          self.stopIndicator()
          self.firstNetworking = false
        }
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
              if self.refreshControl.refreshing {
                self.refreshControl.endRefreshing()
              }
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
        r.type = reportData["type"].stringValue
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
  
  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    if segue.identifier == AppSegues.dashboardReportDetail {
      if let detailVC = segue.destinationViewController as? ReportDetailVC {
        if let indexPath = sender as? NSIndexPath {
          let index = self.reportsDict.startIndex.advancedBy(indexPath.section)
          let key = self.reportsDict.keys[index]
          if let reports = self.reportsDict[key] {
            detailVC.reportId = reports[indexPath.row].id
            detailVC.report = reports[indexPath.row]
          }
        }
      }
    }
  }
  
}

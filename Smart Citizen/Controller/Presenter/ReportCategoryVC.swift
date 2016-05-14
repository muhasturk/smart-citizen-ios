//
//  ReportCategoryVC.swift
//  Smart Citizen
//
//  Created by Mustafa Hastürk on 14/05/16.
//  Copyright © 2016 Mustafa Hastürk. All rights reserved.
//

import UIKit

class ReportCategoryVC: AppVC, UITableViewDataSource, UITableViewDelegate {
  
  @IBOutlet weak var categoryTable: UITableView!
  
  private var reportCategories = [
    [0, "Elektrik", "url"],
    [1, "Su", "url"],
    [2, "Telefon", "url"]
  ]
  
  var selectedCategoryId: Int?
  var selectedCategoryTitle: String?
  
  @IBAction func cancelSelection(sender: AnyObject) {
    self.dismissViewControllerAnimated(true, completion: nil)
  }
  
  // MARK: - LC
  override func viewDidLoad() {
    super.viewDidLoad()
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
  }
  
  func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return self.reportCategories.count
  }
  
  func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCellWithIdentifier(AppCell.reportCategoryCell, forIndexPath: indexPath)
    
    cell.textLabel?.text = self.reportCategories[indexPath.row][1] as? String
    return cell
  }
  
  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    if segue.identifier == "saveReportCategory" {
      if let cell = sender as? UITableViewCell {
        let indexPath = self.categoryTable.indexPathForCell(cell)
        self.selectedCategoryId = self.reportCategories[indexPath!.row][0] as? Int
        self.selectedCategoryTitle = self.reportCategories[indexPath!.row][1] as? String
      }
    }
  }
  
}

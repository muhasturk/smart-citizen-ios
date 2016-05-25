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

class CategoryVC: AppVC, UITableViewDataSource, UITableViewDelegate {
  
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
    if let cell = tableView.dequeueReusableCellWithIdentifier(AppCell.categoryCell, forIndexPath: indexPath) as? CategoryCell {
      cell.textLabel?.text = self.reportCategories[indexPath.row][1] as? String
      return cell
    }
    
    else {
      return CategoryCell()
    }
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

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
    
  fileprivate var reportCategories = [
    [1, "Elektrik", "url"],
    [2, "Su", "url"],
    [3, "Kanalizasyon", "url"],
    [4, "Doğalgaz", "url"],
    [5, "Telefon", "url"],
    [6, "Yol Sorunu", "url"],
    [7, "Çevre Kirliliği", "url"],
    [8, "İllegal Park", "url"],
    [9, "Evsiz İnsan", "url"],
    [10, "Sokak Hayvanı", "url"],
  ]
  
  var selectedCategoryId: Int?
  var selectedCategoryTitle: String?
  
  @IBAction func cancelSelection(_ sender: AnyObject) {
    self.dismiss(animated: true, completion: nil)
  }
  
  // MARK: - LC
  override func viewDidLoad() {
    super.viewDidLoad()
  }

  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return self.reportCategories.count
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    if let cell = tableView.dequeueReusableCell(withIdentifier: AppCell.categoryCell, for: indexPath) as? CategoryCell {
      cell.textLabel?.text = self.reportCategories[(indexPath as NSIndexPath).row][1] as? String
      
      return cell
    }
    
    else {
      return CategoryCell()
    }
  }
  
  func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
    return "Lütfen bir kategori seçiniz..."
  }
  
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if segue.identifier == "saveReportCategory" {
      if let cell = sender as? UITableViewCell {
        let indexPath = self.categoryTable.indexPath(for: cell)
        self.selectedCategoryId = self.reportCategories[(indexPath! as NSIndexPath).row][0] as? Int
        self.selectedCategoryTitle = self.reportCategories[(indexPath! as NSIndexPath).row][1] as? String
      }
    }
  }
  
}

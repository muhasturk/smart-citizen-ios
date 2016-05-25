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

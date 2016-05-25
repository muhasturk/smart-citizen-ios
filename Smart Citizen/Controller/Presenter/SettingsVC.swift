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
import LTMorphingLabel

class SettingsVC: UIViewController {
  
  @IBOutlet weak var versionLabel: LTMorphingLabel!
  
  @IBAction func logoutApplication(sender: AnyObject) {
    AppConstants.AppUser = User()
    NSUserDefaults.standardUserDefaults().setBool(false, forKey: AppConstants.DefaultKeys.APP_ALIVE)
    performSegueWithIdentifier(AppSegues.doLogoutSegue, sender: sender)
  }
  
  // MARK: - LC
  override func viewDidLoad() {
    super.viewDidLoad()
  }
  
  override func viewDidAppear(animated: Bool) {
    self.setVersionLabelDynamically()
  }
  
  // MARK: - Version Label
  func setVersionLabelDynamically() -> Void {
    if let path = NSBundle.mainBundle().pathForResource("Info", ofType: "plist"),
      dict = NSDictionary(contentsOfFile: path) as? [String: AnyObject] {
      if let version = dict["CFBundleShortVersionString"] {
        versionLabel.morphingEffect = .Evaporate
        versionLabel.text = "Version: \(version as! String)"
      }
      else {
        print("CFBundleShortVersionString is missing on info.plist!")
      }
    }
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
  }
  
}

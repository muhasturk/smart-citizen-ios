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

class IntroVC: AppVC {
  
  @IBOutlet weak var backgroundImage: UIImageView!
  
  // MARK: - LC
  override func viewDidLoad() {
    super.viewDidLoad()
    self.configureUI()
  }
  
  fileprivate func configureUI() {
//    let gifManager = SwiftyGifManager(memoryLimit:20)
//    let gifImage = UIImage(gifName: "intro")
//    self.backgroundImage.setGifImage(gifImage, manager: gifManager, loopCount: -1)
  }
  
  // FIX: https://github.com/muhasturk/smart-citizen-ios/issues/4
  override func viewWillAppear(_ animated: Bool) {
    self.navigationController?.isNavigationBarHidden = true
  }
  
  override func viewWillDisappear(_ animated: Bool) {
    if (self.navigationController?.topViewController != self) {
      self.navigationController?.isNavigationBarHidden = false
    }
  }
  
}

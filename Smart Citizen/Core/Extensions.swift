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
import SwiftyJSON

// MARK: UIImageView
extension UIImageView {
  func downloadedFrom(imageURL link:String, contentMode mode: UIViewContentMode = .scaleAspectFill) {
    guard
      let url = URL(string: link)
      else {return}
    contentMode = mode
    URLSession.shared.dataTask(with: url, completionHandler: { (data, response, error) -> Void in
      guard
        let httpURLResponse = response as? HTTPURLResponse , httpURLResponse.statusCode == 200,
        let mimeType = response?.mimeType , mimeType.hasPrefix("image"),
        let data = data , error == nil,
        let imageData = UIImage(data: data)
        else {
          print(AppDebugMessages.downloadImageFromURLFailed + String(url));
          return
      }
      DispatchQueue.main.async { () -> Void in
        self.image = imageData
      }
    }).resume()
  }
}

// MARK: UImage
extension UIImage {
  func scaleWithCGSize(_ targetSize: CGSize) -> UIImage {
    
    let widthRatio: CGFloat = targetSize.width / self.size.width
    let heightRatio: CGFloat = targetSize.height / self.size.height
    
    var aspectRatio: CGFloat
    if widthRatio > heightRatio {
      aspectRatio = heightRatio
    }
    else {
      aspectRatio = widthRatio
    }

    let scaledWidth = self.size.width * aspectRatio
    let scaledHeight = self.size.height * aspectRatio
    
    let scaledSize = CGSize(width: scaledWidth, height: scaledHeight)
    let scaledImageRect = CGRect(x: 0, y: 0,
                                 width: scaledWidth, height: scaledHeight)
    
    
    UIGraphicsBeginImageContextWithOptions(scaledSize, false, 0)
    self.draw(in: scaledImageRect)
    let scaledImage = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
    
    return scaledImage!
  }
}

// MARK: - String
extension String {
  var isEmail: Bool {
    let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
    let emailTest  = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
    return emailTest.evaluate(with: self)
  }
  
  var isNotEmail: Bool {
    return !isEmail
  }
  
  var isNotEmpty: Bool {
    return !isEmpty
  }
  
}

// MARK: - JSON
extension JSON {
  var isNotEmpty: Bool {
    return !isEmpty
  }
}

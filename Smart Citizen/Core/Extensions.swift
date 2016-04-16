//
//  Extensions.swift
//  Smart Citizen
//
//  Created by Mustafa Hastürk on 16/04/16.
//  Copyright © 2016 Mustafa Hastürk. All rights reserved.
//

import UIKit
import SwiftyJSON

// MARK: UIImageView
extension UIImageView {
  func downloadedFrom(imageURL link:String, contentMode mode: UIViewContentMode = .ScaleAspectFill) {
    guard
      let url = NSURL(string: link)
      else {return}
    contentMode = mode
    NSURLSession.sharedSession().dataTaskWithURL(url, completionHandler: { (data, response, error) -> Void in
      guard
        let httpURLResponse = response as? NSHTTPURLResponse where httpURLResponse.statusCode == 200,
        let mimeType = response?.MIMEType where mimeType.hasPrefix("image"),
        let data = data where error == nil,
        let imageData = UIImage(data: data)
        else {
          print(AppDebugMessages.downloadImageFromURLFailed + String(url));
          return
      }
      dispatch_async(dispatch_get_main_queue()) { () -> Void in
        self.image = imageData
      }
    }).resume()
  }
}

// MARK: - String
extension String {
  var isEmail: Bool {
    let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
    let emailTest  = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
    return emailTest.evaluateWithObject(self)
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

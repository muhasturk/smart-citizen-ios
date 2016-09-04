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

class AppUtil {
  func getCustomBorderLayer(_ object: AnyObject, width: CGFloat, color: CGColor) -> CALayer {
    let layer = CALayer()
    layer.borderColor = color
    layer.borderWidth = width
    
    layer.frame = CGRect(x: 0, y: object.frame.size.height - width,
                         width:  object.frame.size.width,
                         height: object.frame.size.height)
    
    return layer
  }
  
  class func getRGBAUIColor(red: Int, green: Int, blue: Int, alpha: Float = 1.0) -> UIColor {
    
    let rgbaColor = UIColor(red: CGFloat(red)/255,
                            green: CGFloat(green)/255,
                            blue: CGFloat(blue)/255,
                            alpha: CGFloat(alpha))
    return rgbaColor
  }
}

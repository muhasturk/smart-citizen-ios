//
//  Util.swift
//  Smart Citizen
//
//  Created by Mustafa Hastürk on 21/11/15.
//  Copyright © 2015 Mustafa Hastürk. All rights reserved.
//

import UIKit

class Util {
    func getCustomBorderLayer(object: AnyObject, width: CGFloat, color: CGColor) -> CALayer {
        let layer = CALayer()
        layer.borderColor = color
        layer.borderWidth = width
        
        layer.frame = CGRect(x: 0, y: object.frame.size.height - width,
            width:  object.frame.size.width,
            height: object.frame.size.height)
        
        return layer
    }
    
    func getRGBAUIColor(red red: Int, green: Int, blue: Int, alpha: Float = 1.0) -> UIColor {
        
        let rgbaColor = UIColor(red: CGFloat(red)/255,
            green: CGFloat(green)/255,
            blue: CGFloat(blue)/255,
            alpha: CGFloat(alpha))
        return rgbaColor
    }
}
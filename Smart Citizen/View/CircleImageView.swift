//
//  CircleImageView.swift
//  Smart Citizen
//
//  Created by Mustafa Hastürk on 24/05/16.
//  Copyright © 2016 Mustafa Hastürk. All rights reserved.
//

import UIKit

class CircleImageView: UIImageView {

  override func layoutSubviews() {
    super.layoutSubviews()
    let radius: CGFloat = self.bounds.size.width / 2
    self.layer.cornerRadius = radius
  }

}

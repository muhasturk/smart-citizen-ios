//
//  Services.swift
//  Smart Citizen
//
//  Created by Mustafa Hastürk on 16/04/16.
//  Copyright © 2016 Mustafa Hastürk. All rights reserved.
//

import Foundation

struct AppAPI {
  static let serviceDomain = "http://159.203.219.208"
  static let servicePort = ":80/"
  
  static let loginServiceURL = "\(serviceDomain)/memberLogin"
  static let signUpServiceURL = "\(serviceDomain)/memberSignUp"
}
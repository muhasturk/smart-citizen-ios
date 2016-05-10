//
//  Services.swift
//  Smart Citizen
//
//  Created by Mustafa Hastürk on 16/04/16.
//  Copyright © 2016 Mustafa Hastürk. All rights reserved.
//

import Foundation

struct AppAPI {
  static let serviceDomain = "http://smart-citizen.mustafahasturk.com"
  
  static let loginServiceURL = "\(serviceDomain)/memberLogin"
  
  static let signUpServiceURL = "\(serviceDomain)/memberSignUp"
  
  static let dashboardServiceURL = "\(serviceDomain)/getReportsByType?reportType="
  
  static let reportServiceURL = "\(serviceDomain)/sendReport"
}
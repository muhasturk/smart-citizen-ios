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
  
  static let loginServiceURL = "/memberLogin"
  
  static let signUpServiceURL = "/memberSignUp"
  
  static let mapServiceURL = "/getUnorderedReportsByType?reportType="
  
  static let dashboardServiceURL = "/getReportsByType?reportType="
  
  static let reportServiceURL = "/sendReport"
}
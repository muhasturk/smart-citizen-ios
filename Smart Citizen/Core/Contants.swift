//
//  Contants.swift
//  Smart Citizen
//
//  Created by Mustafa Hastürk on 16/04/16.
//  Copyright © 2016 Mustafa Hastürk. All rights reserved.
//

import Foundation

struct AppSegues {
  static let doLoginSegue = "doLogin"
  static let doSignUpSegue = "doSignUp"
  static let doLogoutSegue = "doLogout"
  static let pushReportCategory = "pushReportCategory"
}

struct AppColors {
  
}

struct AppCell {
  static let reportCategoryCell = "reportCategoryCell"
}

struct AppConstants {
  
  static var AppUser = User()
  
  struct DefaultKeys {
    static let DEVICE_TOKEN = "KEY_DEVICE_TOKEN"
    static let APP_ALIVE = "KEY_APP_ALIVE"
    static let APP_USER = "KEY_APP_USER"
  }
  
}
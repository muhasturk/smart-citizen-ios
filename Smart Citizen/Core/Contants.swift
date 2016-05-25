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

import Foundation

struct AppSegues {
  static let doLoginSegue = "doLogin"
  static let doSignUpSegue = "doSignUp"
  static let doLogoutSegue = "doLogout"
  static let pushReportCategory = "pushReportCategory"
  static let mapReportDetail = "mapReportDetail"
  static let dashboardReportDetail = "dashboardReportDetail"
  static let profileReportDetail = "profileReportDetail"
}

struct AppReuseIdentifier {
  static let mapCustomAnnotationView = "SmartAnnotationView"
}

struct AppColors {
  
}

struct AppCell {
  static let categoryCell = "categoryCell"
}

struct AppConstants {
  
  static var AppUser = User()
  
  struct DefaultKeys {
    static let DEVICE_TOKEN = "KEY_DEVICE_TOKEN"
    static let APP_ALIVE = "KEY_APP_ALIVE"
    static let APP_USER = "KEY_APP_USER"
  }
  
}
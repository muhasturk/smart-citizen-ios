//
//  Exceptions.swift
//  Smart Citizen
//
//  Created by Mustafa Hastürk on 16/04/16.
//  Copyright © 2016 Mustafa Hastürk. All rights reserved.
//

import Foundation

enum ExceptionCode: Int {
  case EmailOrPasswordWrong = 1
  case ThereIsNoUserWithEmail
  case ThereIsaMemberWithEmail
}
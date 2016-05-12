//
//  Exceptions.swift
//  Smart Citizen
//
//  Created by Mustafa Hastürk on 16/04/16.
//  Copyright © 2016 Mustafa Hastürk. All rights reserved.
//

enum ExceptionCode: Int {
  
  /*
   All exception codes in this enumaration must be handled in base class
  */
  
  case EmailOrPasswordWrong = 1
  case ThereIsNoUserWithEmail
  case ThereIsaMemberWithEmail
  case BadRequest = 400
}
//
//  AlertMessagesFile.swift
//  Smart Citizen
//
//  Created by Mustafa Hastürk on 16/04/16.
//  Copyright © 2016 Mustafa Hastürk. All rights reserved.
//

import Foundation

struct AppAlertMessages {
  
  static let missingFieldTitle = "Eksik Giriş"

  // Login Scene
  static let loginMissingFieldMessage =  "Email veya şifre kısmı boş bırakılamaz."
  static let loginEmailFieldNotValidatedTitle = "Geçersiz Email"
  static let loginEmailFieldNotValidatedMessage = "Lütfen geçerli bir mail adresi giriniz."
  
  static let exceptionLoginWrongCredentialsTitle = "Geçersiz Giriş"
  static let exceptionLoginWrongCredentialsMessage = "Girmiş olduğunuz mail adresi ile şifre örtüşmüyor."
  
  static let defaultHandleExceptionCodeTitle = "Handle Edilmemiş Durum"
  static let defaultHandleExceptionCodeMessage = "Server'dan gelen durum handle edilmemiş."
  
}
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
  
  static let exceptionLoginThereIsNoUserWithEmailTitle = "Üye Bulunamadı"
  static let exceptionLoginThereIsNoUserWithEmailMessage = "Girmiş olduğunuz mail adresi ile kayıtlı bir kullanıcı bulunamadı."
  
  // SignUp Scene
  static let exceptionAlreadyRegisteredEmailTitle = "Zaten Üye"
  static let exceptionAlreadyRegisteredEmailMessage = "Girmiş olduğunuz mail adresi ile üye olmuş bir kullanıcı bulunmaktadır."
  
  static let exceptionLoginWrongCredentialsTitle = "Geçersiz Giriş"
  static let exceptionLoginWrongCredentialsMessage = "Girmiş olduğunuz mail adresi ile şifre örtüşmüyor."
  
  static let defaultHandleExceptionCodeTitle = "Handle Edilmemiş Durum"
  static let defaultHandleExceptionCodeMessage = "Server'dan gelen durum handle edilmemiş."
  
  static let networkingFailuredTitle = "Bağlantı Hatası"
  static let networkingFailuredMessage = "Hizmete bağlanmakta sorun yaşıyoruz."
  
}
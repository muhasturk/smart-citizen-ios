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

struct AppAlertMessages {
  
  static let missingFieldTitle = "Eksik Giriş"

  // Login Scene
  static let loginMissingFieldMessage =  "Email veya şifre kısmı boş bırakılamaz."
  static let emailFieldNotValidatedTitle = "Geçersiz Email"
  static let emailFieldNotValidatedMessage = "Lütfen geçerli bir mail adresi giriniz."
  
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
  
  // MARK: Report
  static let parameterMissingTitle = "Parametre Eksik"
  static let parameterMissingMessage = "Servisin istediği parametreler eksik girilmiş."
  
}
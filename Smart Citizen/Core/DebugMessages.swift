//
//  DebugMessages.swift
//  Smart Citizen
//
//  Created by Mustafa Hastürk on 16/04/16.
//  Copyright © 2016 Mustafa Hastürk. All rights reserved.
//

import Foundation

struct AppDebugMessages {
  static let keyDataIsNotExistOrIsEmpty = "'data' key inside JSON is empty or not exist"
  
  static let downloadImageFromURLFailed = "Problem when download image from URL:\n"
  
  static let serviceConnectionLoginIsOk = "Login servis bağlantısı başarılı"
  
  static let serviceConnectionSignUpIsOk = "Sign servisi bağlantısı başarılı"
  
  static let cameraDeviceNotAvailableTitle = "Kamera Bulunamadı"
  static let cameraDeviceNotAvailableMessage = "Mobil cihaz üzerinde kamera bulunamadı"
  static let cameraDeviceNotAvailable = "Cihaz üzerinde UIImagePickerControllerSourceType.Camera bulunamadı."
  
  static let photosNotAvailable = "Cihaz üzerinde UIImagePickerControllerSourceType.PhotoLibrary bulunamadı."
  static let photosNotAvailableTitle = "Photos Bulunamadı"
  static let photosNotAvailableMessage = "Mobil cihaz üzerinde Photoss uygulaması bulunamadı."
  
  static let momentsNotAvailable = "Cihaz üzerinde UIImagePickerControllerSourceType.SavedPhotosAlbum buunamadı"
  static let momentsNotAvailableTitle = "Moments Erişilemedi"
  static let momentsNotAvailableMessage = "Mobil cihaz üerinde Moments erişilemedi."
}
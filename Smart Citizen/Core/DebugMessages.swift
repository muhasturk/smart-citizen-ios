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

struct AppDebugMessages {
  static let keyDataIsNotExistOrIsEmpty = "'data' key inside JSON is empty or not exist"
  
  static let downloadImageFromURLFailed = "Problem when download image from URL:\n"
  
  // MARK: - Service Connection
  static let serviceConnectionLoginIsOk = "Login servis bağlantısı başarılı"
  
  static let serviceConnectionSignUpIsOk = "Sign servisi bağlantısı başarılı"
  
  static let serviceConnectionMapIsOk = "Map servisi bağlantısı başarılı"
  
  static let serviceConnectionDashboardIsOk = "Dashboard servisi bağlantısı başarılı"
  
  static let serviceConnectionReportIsOk = "Report servisi bağlantısı başarılı"
  
  static let serviceConnectionProfileIsOk = "Profile servis bağlantısı başarılı"

  
  static let cameraDeviceNotAvailableTitle = "Kamera Bulunamadı"
  static let cameraDeviceNotAvailableMessage = "Mobil cihaz üzerinde kamera bulunamadı"
  static let cameraDeviceNotAvailable = "Cihaz üzerinde UIImagePickerControllerSourceType.Camera bulunamadı."
  
  static let photosNotAvailable = "Cihaz üzerinde UIImagePickerControllerSourceType.PhotoLibrary bulunamadı."
  static let photosNotAvailableTitle = "Photos Bulunamadı"
  static let photosNotAvailableMessage = "Mobil cihaz üzerinde Photoss uygulaması bulunamadı."
  
  static let momentsNotAvailable = "Cihaz üzerinde UIImagePickerControllerSourceType.SavedPhotosAlbum buunamadı"
  static let momentsNotAvailableTitle = "Moments Erişilemedi"
  static let momentsNotAvailableMessage = "Mobil cihaz üerinde Moments erişilemedi."
  
  static let reportNotPassed = "Report object not passed from segue"
}
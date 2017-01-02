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

import UIKit
import Alamofire
import SwiftyJSON
import AWSS3

class ReportVC: AppVC, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
  
  // MARK: - IBOutlet
  @IBOutlet weak var choosenImage: UIImageView!
  @IBOutlet weak var descriptionField: UITextView!
  @IBOutlet weak var categoryButton: UIButton!
  @IBOutlet weak var titleField: UITextField!
  @IBOutlet weak var mediaButton: UIButton!
  
  var categoryId: Int?

  var categoryTitle: String? {
    didSet {
      self.categoryButton.setTitle(categoryTitle, for: UIControlState())
    }
  }
  
  var categorySelected = false
  
  fileprivate var imagePicked = false {
    willSet {
      if newValue {
        self.mediaButton.setTitle("Resmi Değiştir", for: UIControlState())
      }
      else {
        self.mediaButton.setTitle("Resim Ekle", for: UIControlState())
      }
    }
  }
  
  // MARK: Properties
  fileprivate let requestBaseURL = AppAPI.serviceDomain + AppAPI.reportServiceURL
  fileprivate let imagePicker = UIImagePickerController()
  fileprivate let AWSS3BucketName = "smart-citizen"
  
  // MARK: - LC
  override func viewDidLoad() {
    super.viewDidLoad()
    self.view.dodo.style.bar.hideOnTap = true
    self.view.dodo.topLayoutGuide = topLayoutGuide

    super.locationManager.startUpdatingLocation()
    self.configureImagePickerController()
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
  }
  
  override func viewDidAppear(_ animated: Bool) {
    super.addKeyboardObserver()
  }
  
  override func viewDidDisappear(_ animated: Bool) {
    self.removeKeyboardObserver()
    super.locationManager.stopUpdatingLocation()
  }
  
  // MARK: - Action
  @IBAction func sendReportAction(_ sender: AnyObject) {
    if self.isAllFieldCompleted(){
      self.makeDialogForSend()
    }
    else {
      super.createAlertController(title: AppAlertMessages.missingFieldTitle, message: AppAlertMessages.reportMissingFieldMessage, controllerStyle: .alert, actionStyle: .default)
    }
  }
  
  fileprivate func makeDialogForSend() {
    let ac = UIAlertController(title: "Raporu Onaylayın", message: "Raporunuz sistemimize yüklenecektir.\nOnaylıyor musunuz?", preferredStyle: .alert)
    let okAction = UIAlertAction(title: "Yükle", style: .default) { (UIAlertAction) in
      
      self.view.dodo.info("Rapor yükleniyor...")
      self.uploadImageForAWSS3()
    }
    let cancelAction = UIAlertAction(title: "İptal Et", style: .cancel, handler: nil)
    ac.addAction(okAction)
    ac.addAction(cancelAction)
    self.present(ac, animated: true, completion: nil)
  }
  
  fileprivate func isAllFieldCompleted() -> Bool {
    return self.imagePicked && self.titleField.text!.isNotEmpty &&
      self.descriptionField.text.isNotEmpty && self.categorySelected
  }
  
  @IBAction func clearFieldAction(_ sender: AnyObject) {
    self.clearFields()
  }
  
  @IBAction func selectCategory(_ sender: AnyObject) {
    self.performSegue(withIdentifier: AppSegues.pushReportCategory, sender: sender)
  }
  
  func clearFields() {
    self.choosenImage.image = UIImage(named: "Placeholder")
    self.categorySelected = false
    self.titleField.text = ""
    self.descriptionField.text = ""
    self.categoryButton.setTitle("Kategori", for: UIControlState())
  }
  
  // MARK: - Networking
  func uploadImageForAWSS3() {
    let ext = "jpg"
    let t: UIImage = self.choosenImage.image!
    let pickedImage = t.scaleWithCGSize(CGSize(width: 500, height: 500))
    let temporaryDirectoryURL = URL(fileURLWithPath: NSTemporaryDirectory())
    let imageURL: URL = temporaryDirectoryURL.appendingPathComponent("pickedImage.png")
    let pathString = imageURL.absoluteString // has file:// prefix
    let onlyPathString = pathString.trimmingCharacters(in: CharacterSet(charactersIn: "file://"))
    //let imageData: NSData = UIImagePNGRepresentation(pickedImage)!
    let imageData: Data = UIImageJPEGRepresentation(pickedImage, 0.7)!
    try? imageData.write(to: URL(fileURLWithPath: onlyPathString), options: [.atomic]) // change onlypathstring
    
    let uploadRequest = AWSS3TransferManagerUploadRequest()
    uploadRequest?.body = imageURL
    uploadRequest?.key = ProcessInfo.processInfo.globallyUniqueString + "." + ext
    uploadRequest?.bucket = self.AWSS3BucketName
    uploadRequest?.contentType = "image/" + ext
    uploadRequest?.acl = .publicRead
    
    let transferManager = AWSS3TransferManager.default()
    transferManager?.upload(uploadRequest).continue({ (task) -> Any? in
      if let error = task.error {
        print("Upload failed ❌ (\(error))")
      }
      
      if let exception = task.exception {
        print("Upload failed ❌ (\(exception))")
      }
      
      guard task.result != nil else {
        self.view.dodo.error("Seçtiğiniz resim AWS servise yüklenemedi.")
        self.createAlertController(title: "Yükleme Başarısız", message: "Seçtiğiniz resim AWS servise yüklenemedi.", controllerStyle: .alert, actionStyle: .destructive)
        print("Seçtiğiniz resim AWS servise yüklenemedi.")
        return ""
      }
      let uploadedImageURL = "https://s3-us-west-2.amazonaws.com/\(self.AWSS3BucketName)/\(uploadRequest?.key!)"
      print(uploadedImageURL)
      let params = self.configureReportNetworkingParameters(imageUrl: uploadedImageURL)
      self.reportNetworking(networkingParameters: params as [String : AnyObject])
      return ""
    })

  }

  fileprivate func configureReportNetworkingParameters(imageUrl url: String) -> [String: Any] {
    var latitude: Double?
    var longitude: Double?
    
    if let location = super.locationManager.location?.coordinate {
      latitude = location.latitude
      longitude = location.longitude
    }
    
    let params: [String: Any] = [
      "email": AppReadOnlyUser.email as Any,
      "password": AppReadOnlyUser.password as Any,
      "latitude": latitude ?? 40.984312,
      "longitude": longitude ?? 28.753676,
      "title": self.titleField.text!,
      "description": self.descriptionField.text!,
      "categoryId": categoryId!,
      "imageUrl": url
    ]
    
    return params
  }
  
  
  // MARK: - Image Picker
  fileprivate func configureImagePickerController() {
    self.imagePicker.delegate = self
    //    self.picker.allowsEditing = true
    //    if let mediaTypes = UIImagePickerController.availableMediaTypesForSourceType(.Camera) {
    //      self.picker.mediaTypes = mediaTypes
    //    }
  }
  
  @IBAction func chooseMediaAction(_ sender: AnyObject) {
    let actionSheet = UIAlertController(title: "Medya Kaynağı", message: "Medya eklemek için bir kaynak seçiniz.", preferredStyle: .actionSheet)
    
    let cameraAction = UIAlertAction(title: "Camera", style: .default) { (UIAlertAction) in
      self.pickFromCamera()
    }
    
    let photosAction = UIAlertAction(title: "Photos", style: .default) { (UIAlertAction) in
      self.pickFromPhotos()
    }
    
    let momentsAction = UIAlertAction(title: "Momemts", style: .default) { (UIAlertAction) in
      self.pickFromMoments()
    }
    
    let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
    
    actionSheet.addAction(momentsAction)
    actionSheet.addAction(photosAction)
    actionSheet.addAction(cameraAction)
    actionSheet.addAction(cancelAction)
    self.present(actionSheet, animated: true, completion: nil)
  }
  
  
  fileprivate func pickFromCamera() {
    if UIImagePickerController.isSourceTypeAvailable(.camera) {
      self.imagePicker.sourceType = .camera
      self.imagePicker.modalPresentationStyle = .currentContext
      self.present(self.imagePicker, animated: true, completion: nil)
    }
    else {
      self.createAlertController(title: AppDebugMessages.cameraDeviceNotAvailableTitle, message: AppDebugMessages.cameraDeviceNotAvailableMessage, controllerStyle: .alert, actionStyle: .destructive)
      print(AppDebugMessages.cameraDeviceNotAvailable)
    }
  }
  
  fileprivate func pickFromPhotos() {
    if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.photoLibrary) {
      self.imagePicker.sourceType = .photoLibrary
      self.present(self.imagePicker, animated: true, completion: nil)
    }
    else {
      self.createAlertController(title: AppDebugMessages.photosNotAvailableTitle, message: AppDebugMessages.photosNotAvailableMessage, controllerStyle: .alert, actionStyle: .destructive)
      print(AppDebugMessages.photosNotAvailable)
    }
  }
  
  fileprivate func pickFromMoments() {
    if UIImagePickerController.isSourceTypeAvailable(.savedPhotosAlbum) {
      self.imagePicker.sourceType = .savedPhotosAlbum
      self.present(self.imagePicker, animated: true, completion: nil)
    }
    else {
      self.createAlertController(title: AppDebugMessages.momentsNotAvailableTitle, message: AppDebugMessages.momentsNotAvailableMessage, controllerStyle: .alert, actionStyle: .destructive)
      print(AppDebugMessages.momentsNotAvailable)
    }
  }
  
  // MARK: - Image Picker Delegate
  func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
    if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
      UIImageWriteToSavedPhotosAlbum(pickedImage, nil, nil, nil)
      self.choosenImage.image = pickedImage
      self.imagePicked = true
    }
    self.dismiss(animated: true, completion: nil)
  }
  
  func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
    self.dismiss(animated: true, completion: nil)
  }
  
  override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
    self.view.endEditing(true)
  }

  
  // MARK: Unwind
  @IBAction func unwindToReportScene(_ segue: UIStoryboardSegue) {
    if segue.identifier == "saveReportCategory"{
      if let sourceVC = segue.source as? CategoryVC {
        self.categorySelected = true
        self.categoryTitle = sourceVC.selectedCategoryTitle
        self.categoryId = sourceVC.selectedCategoryId
      }
    }
  }
  
}

// MARK: - Networking
extension ReportVC {
  
  fileprivate func reportNetworking(networkingParameters params: [String: AnyObject]) {
    Alamofire.request(self.requestBaseURL, method: .post, parameters: params, encoding: JSONEncoding.default)
      .responseJSON { response in
        self.stopIndicator()
        switch response.result {
        case .success(let value):
          print(AppDebugMessages.serviceConnectionReportIsOk, self.requestBaseURL, separator: "\n")
          let json = JSON(value)
          let serviceCode = json["serviceCode"].intValue
          self.view.dodo.style.bar.hideAfterDelaySeconds = 3
          
          if serviceCode == 0 {
            self.reportNetworkingSuccessful()
          }
            
          else {
            let exception = json["exception"]
            self.reportNetworkingUnsuccessful(exception)
          }
          
        case .failure(let error):
          self.createAlertController(title: AppAlertMessages.networkingFailuredTitle, message: AppAlertMessages.networkingFailuredMessage, controllerStyle: .alert, actionStyle: .destructive)
          debugPrint(error)
        }
    }
  }

  fileprivate func reportNetworkingSuccessful() {
    self.view.dodo.success("Raporunuz sistemimize kaydedildi.")
    super.createAlertController(title: "Rapor Gönderildi", message: "Raporunuz sistemimize kaydedildi.", controllerStyle: .alert, actionStyle: .default)
    self.clearFields()
  }
  
  fileprivate func reportNetworkingUnsuccessful(_ exception: JSON) {
    self.view.dodo.error("Rapor yüklemesi başarısız oldu.")
  }
  
}

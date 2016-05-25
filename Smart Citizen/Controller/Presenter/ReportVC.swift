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
      self.categoryButton.setTitle(categoryTitle, forState: .Normal)
    }
  }
  
  var categorySelected = false
  
  private var imagePicked = false {
    willSet {
      if newValue {
        self.mediaButton.setTitle("Resmi Değiştir", forState: .Normal)
      }
      else {
        self.mediaButton.setTitle("Resim Ekle", forState: .Normal)
      }
    }
  }
  
  // MARK: Properties
  private let requestBaseURL = AppAPI.serviceDomain + AppAPI.reportServiceURL
  private let imagePicker = UIImagePickerController()
  private let AWSS3BucketName = "smart-citizen"
  private var uploadDoneForAWSS3 = false
  
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
  
  override func viewDidAppear(animated: Bool) {
    super.addKeyboardObserver()
  }
  
  override func viewDidDisappear(animated: Bool) {
    self.removeKeyboardObserver()
    super.locationManager.stopUpdatingLocation()
  }
  
  // MARK: - Action
  @IBAction func sendReportAction(sender: AnyObject) {
    if self.isAllFieldCompleted(){
      self.makeDialogForSend()
    }
    else {
      super.createAlertController(title: AppAlertMessages.missingFieldTitle, message: AppAlertMessages.reportMissingFieldMessage, controllerStyle: .Alert, actionStyle: .Default)
    }
  }
  
  private func makeDialogForSend() {
    let ac = UIAlertController(title: "Raporu Onaylayın", message: "Raporunuz sistemimize yüklenecektir.\nOnaylıyor musunuz?", preferredStyle: .Alert)
    let okAction = UIAlertAction(title: "Yükle", style: .Default) { (UIAlertAction) in
      
      self.view.dodo.info("Rapor yükleniyor...")
      self.uploadImageForAWSS3()
    }
    let cancelAction = UIAlertAction(title: "İptal Et", style: .Cancel, handler: nil)
    ac.addAction(okAction)
    ac.addAction(cancelAction)
    self.presentViewController(ac, animated: true, completion: nil)
  }
  
  private func isAllFieldCompleted() -> Bool {
    return self.imagePicked && self.titleField.text!.isNotEmpty &&
      self.descriptionField.text.isNotEmpty && self.categorySelected
  }
  
  @IBAction func clearFieldAction(sender: AnyObject) {
    self.clearFields()
  }
  
  @IBAction func selectCategory(sender: AnyObject) {
    self.performSegueWithIdentifier(AppSegues.pushReportCategory, sender: sender)
  }
  
  func clearFields() {
    self.choosenImage.image = UIImage(named: "Placeholder")
    self.categorySelected = false
    self.titleField.text = ""
    self.descriptionField.text = ""
    self.categoryButton.setTitle("Kategori", forState: .Normal)
  }
  
  // MARK: - Networking
  func uploadImageForAWSS3() {
    let ext = "jpg"
    let pickedImage: UIImage = self.choosenImage.image!
    let temporaryDirectoryURL = NSURL(fileURLWithPath: NSTemporaryDirectory())
    let imageURL: NSURL = temporaryDirectoryURL.URLByAppendingPathComponent("pickedImage.png")
    let pathString = imageURL.absoluteString // has file:// prefix
    let onlyPathString = pathString.stringByTrimmingCharactersInSet(NSCharacterSet(charactersInString: "file://"))
    //let imageData: NSData = UIImagePNGRepresentation(pickedImage)!
    let imageData: NSData = UIImageJPEGRepresentation(pickedImage, 0.4)!
    imageData.writeToFile(onlyPathString, atomically: true) // change onlypathstring
    
    let uploadRequest = AWSS3TransferManagerUploadRequest()
    uploadRequest.body = imageURL
    uploadRequest.key = NSProcessInfo.processInfo().globallyUniqueString + "." + ext
    uploadRequest.bucket = self.AWSS3BucketName
    uploadRequest.contentType = "image/" + ext
    uploadRequest.ACL = .PublicRead
    
    let transferManager = AWSS3TransferManager.defaultS3TransferManager()
    transferManager.upload(uploadRequest).continueWithBlock { (task) -> AnyObject! in
      
      if let error = task.error {
        print("Upload failed ❌ (\(error))")
      }
      
      if let exception = task.exception {
        print("Upload failed ❌ (\(exception))")
      }
      
      guard task.result != nil else {
        super.stopIndicator()
        self.createAlertController(title: "Yükleme Başarısız", message: "Seçtiğiniz resim AWS servise yüklenemedi.", controllerStyle: .Alert, actionStyle: .Destructive)
        print("Seçtiğiniz resim AWS servise yüklenemedi.")
        return ""
      }
      let uploadedImageURL = "https://s3-us-west-2.amazonaws.com/\(self.AWSS3BucketName)/\(uploadRequest.key!)"
      print(uploadedImageURL)
      let params = self.configureReportNetworkingParameters(imageUrl: uploadedImageURL)
      self.reportNetworking(networkingParameters: params)
      return ""
    }
  }

  private func configureReportNetworkingParameters(imageUrl url: String) -> [String: AnyObject] {
    var latitude: Double?
    var longitude: Double?
    
    if let location = super.locationManager.location?.coordinate {
      latitude = location.latitude
      longitude = location.longitude
    }
    
    let params: [String: AnyObject] = [
      "email": AppReadOnlyUser.email,
      "password": AppReadOnlyUser.password,
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
  private func configureImagePickerController() {
    self.imagePicker.delegate = self
    //    self.picker.allowsEditing = true
    //    if let mediaTypes = UIImagePickerController.availableMediaTypesForSourceType(.Camera) {
    //      self.picker.mediaTypes = mediaTypes
    //    }
  }
  
  @IBAction func chooseMediaAction(sender: AnyObject) {
    let actionSheet = UIAlertController(title: "Medya Kaynağı", message: "Medya eklemek için bir kaynak seçiniz.", preferredStyle: .ActionSheet)
    
    let cameraAction = UIAlertAction(title: "Camera", style: .Default) { (UIAlertAction) in
      self.pickFromCamera()
    }
    
    let photosAction = UIAlertAction(title: "Photos", style: .Default) { (UIAlertAction) in
      self.pickFromPhotos()
    }
    
    let momentsAction = UIAlertAction(title: "Momemts", style: .Default) { (UIAlertAction) in
      self.pickFromMoments()
    }
    
    let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: nil)
    
    actionSheet.addAction(momentsAction)
    actionSheet.addAction(photosAction)
    actionSheet.addAction(cameraAction)
    actionSheet.addAction(cancelAction)
    self.presentViewController(actionSheet, animated: true, completion: nil)
  }
  
  
  private func pickFromCamera() {
    if UIImagePickerController.isSourceTypeAvailable(.Camera) {
      self.imagePicker.sourceType = .Camera
      self.imagePicker.modalPresentationStyle = .CurrentContext
      self.presentViewController(self.imagePicker, animated: true, completion: nil)
    }
    else {
      self.createAlertController(title: AppDebugMessages.cameraDeviceNotAvailableTitle, message: AppDebugMessages.cameraDeviceNotAvailableMessage, controllerStyle: .Alert, actionStyle: .Destructive)
      print(AppDebugMessages.cameraDeviceNotAvailable)
    }
  }
  
  private func pickFromPhotos() {
    if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.PhotoLibrary) {
      self.imagePicker.sourceType = .PhotoLibrary
      self.presentViewController(self.imagePicker, animated: true, completion: nil)
    }
    else {
      self.createAlertController(title: AppDebugMessages.photosNotAvailableTitle, message: AppDebugMessages.photosNotAvailableMessage, controllerStyle: .Alert, actionStyle: .Destructive)
      print(AppDebugMessages.photosNotAvailable)
    }
  }
  
  private func pickFromMoments() {
    if UIImagePickerController.isSourceTypeAvailable(.SavedPhotosAlbum) {
      self.imagePicker.sourceType = .SavedPhotosAlbum
      self.presentViewController(self.imagePicker, animated: true, completion: nil)
    }
    else {
      self.createAlertController(title: AppDebugMessages.momentsNotAvailableTitle, message: AppDebugMessages.momentsNotAvailableMessage, controllerStyle: .Alert, actionStyle: .Destructive)
      print(AppDebugMessages.momentsNotAvailable)
    }
  }
  
  // MARK: - Image Picker Delegate
  func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
    if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
      UIImageWriteToSavedPhotosAlbum(pickedImage, nil, nil, nil)
      self.choosenImage.image = pickedImage
      self.imagePicked = true
    }
    self.dismissViewControllerAnimated(true, completion: nil)
  }
  
  func imagePickerControllerDidCancel(picker: UIImagePickerController) {
    self.dismissViewControllerAnimated(true, completion: nil)
  }
  
  override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
    self.view.endEditing(true)
  }

  
  // MARK: Unwind
  @IBAction func unwindToReportScene(segue: UIStoryboardSegue) {
    if segue.identifier == "saveReportCategory"{
      if let sourceVC = segue.sourceViewController as? CategoryVC {
        self.categorySelected = true
        self.categoryTitle = sourceVC.selectedCategoryTitle
        self.categoryId = sourceVC.selectedCategoryId
      }
    }
  }
  
}

// MARK: - Networking
extension ReportVC {
  
  private func reportNetworking(networkingParameters params: [String: AnyObject]) {
    Alamofire.request(.POST, self.requestBaseURL, parameters: params, encoding: .JSON)
      .responseJSON { response in
        self.stopIndicator()
        switch response.result {
        case .Success(let value):
          print(AppDebugMessages.serviceConnectionReportIsOk, self.requestBaseURL, separator: "\n")
          let json = JSON(value)
          let serviceCode = json["serviceCode"].intValue
          self.view.dodo.style.bar.hideAfterDelaySeconds = 2
          
          if serviceCode == 0 {
            self.reportNetworkingSuccessful()
          }
            
          else {
            let exception = json["exception"]
            self.reportNetworkingUnsuccessful(exception)
          }
          
        case .Failure(let error):
          self.createAlertController(title: AppAlertMessages.networkingFailuredTitle, message: AppAlertMessages.networkingFailuredMessage, controllerStyle: .Alert, actionStyle: .Destructive)
          debugPrint(error)
        }
    }
  }

  private func reportNetworkingSuccessful() {
    self.view.dodo.success("Raporunuz sistemimize kaydedildi.")
    super.createAlertController(title: "Rapor Gönderildi", message: "Raporunuz sistemimize kaydedildi.", controllerStyle: .Alert, actionStyle: .Default)
    self.clearFields()
  }
  
  private func reportNetworkingUnsuccessful(exception: JSON) {
    self.view.dodo.error("Rapor yüklemesi başarısız oldu.")
    let c = exception["exceptionCode"].intValue
    let m = exception["exceptionMessage"].stringValue
    let (title, message) = self.getHandledExceptionDebug(exceptionCode: c, elseMessage: m)
    self.createAlertController(title: title, message: message, controllerStyle: .Alert, actionStyle: .Default)
  }
  
}

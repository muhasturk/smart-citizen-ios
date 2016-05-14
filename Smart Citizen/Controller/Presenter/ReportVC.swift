//
//  ReportVC.swift
//  Smart Citizen
//
//  Created by Mustafa Hastürk on 03/12/15.
//  Copyright © 2015 Mustafa Hastürk. All rights reserved.
//

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
  
  var categoryId: Int?

  var categoryTitle: String? {
    didSet {
      self.categoryButton.setTitle(categoryTitle, forState: .Normal)
    }
  }
  
  var categorySelected = false
  
  private var imagePicked = false
  
  // MARK: Properties
  private let requestBaseURL = AppAPI.serviceDomain + AppAPI.reportServiceURL
  private let imagePicker = UIImagePickerController()
  private let AWSS3BucketName = "smart-citizen"
  private var uploadDoneForAWSS3 = false
  
  // MARK: - LC
  override func viewDidLoad() {
    super.viewDidLoad()
    print(AppConstants.AppUser.email)
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
  }
  
  // MARK: - Action
  @IBAction func sendReportAction(sender: AnyObject) {
    if self.isAllFieldCompleted(){
      self.startIndicator()
      self.uploadImageForAWSS3()
    }
    else {
      super.createAlertController(title: AppAlertMessages.missingFieldTitle, message: AppAlertMessages.loginMissingFieldMessage, controllerStyle: .Alert, actionStyle: .Default)
    }
  }
  
  private func isAllFieldCompleted() -> Bool {
    return self.imagePicked && self.titleField.text!.isNotEmpty && self.descriptionField.text.isNotEmpty && self.categorySelected
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
    self.categoryButton.setTitle("Kategori Seçin", forState: .Normal)
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
    let imageData: NSData = UIImageJPEGRepresentation(pickedImage, 0.5)!
    imageData.writeToFile(onlyPathString, atomically: true) // change onlypathstring
    
    let uploadRequest = AWSS3TransferManagerUploadRequest()
    uploadRequest.body = imageURL
    /**
     Use for uploaded image url to do that be unique
     */
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
    let params = [
      "email": readOnlyUser.email,
      "password": readOnlyUser.password,
      "latitude": 40.983203,
      "longitude": 28.728038,
      "title": "başlık",
      "description": "Fiber bağlantımız sürekli kopuyor.",
      "category": 5,
      "imageUrl": url
    ]
    return params as! [String : AnyObject]
  }
  
  private func reportNetworking(networkingParameters params: [String: AnyObject]) {
    Alamofire.request(.POST, self.requestBaseURL, parameters: params, encoding: .JSON)
      .responseJSON { response in
        self.stopIndicator()
        switch response.result {
        case .Success(let value):
          print(AppDebugMessages.serviceConnectionReportIsOk, self.requestBaseURL, separator: "\n")
          let json = JSON(value)
          let serviceCode = json["serviceCode"].intValue
          
          if serviceCode == 0 {
            super.createAlertController(title: "Rapor Gönderildi", message: "Raporunuz sistemimize kaydedildi.", controllerStyle: .Alert, actionStyle: .Default)
            self.clearFields()
          }
            
          else {
            let exception = json["exception"]
            let c = exception["exceptionCode"].intValue
            let m = exception["exceptionMessage"].stringValue
            let (title, message) = self.getHandledExceptionDebug(exceptionCode: c, elseMessage: m)
            self.createAlertController(title: title, message: message, controllerStyle: .Alert, actionStyle: .Default)
          }
          
        case .Failure(let error):
          self.createAlertController(title: AppAlertMessages.networkingFailuredTitle, message: AppAlertMessages.networkingFailuredMessage, controllerStyle: .Alert, actionStyle: .Destructive)
          debugPrint(error)
        }
    }
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
      if let sourceVC = segue.sourceViewController as? ReportCategoryVC {
        self.categoryTitle = sourceVC.selectedCategoryTitle!
        self.categorySelected = true
        print("category: \(self.categorySelected)")
        print(sourceVC.selectedCategoryId)
        self.categoryId = sourceVC.selectedCategoryId
      }
    }
  }
  
}

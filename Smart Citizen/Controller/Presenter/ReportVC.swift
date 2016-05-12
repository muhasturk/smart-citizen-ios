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
  @IBOutlet weak var descriptionView: UITextView!

  // MARK: Properties
  private let requestBaseURL = AppAPI.serviceDomain + AppAPI.reportServiceURL
  private let picker = UIImagePickerController()
  private let AWSS3BucketName = "smart-citizen"
  private var uploadDoneForAWSS3 = false
  
  // MARK: - LC
  override func viewDidLoad() {
    super.viewDidLoad()
    print(AppConstants.AppUser.email)
    self.configurePickerController()
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
  }
  
  override func viewDidAppear(animated: Bool) {
    super.viewDidAppear(true)
    super.addKeyboardObserver()
  }
  override func viewDidDisappear(animated: Bool) {
    self.removeKeyboardObserver()
  }
  
  // MARK: - Action
  @IBAction func sendReportAction(sender: AnyObject) {
    self.startIndicator()
    self.uploadImageForAWSS3()
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
      "title": "İnternet Yok",
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
            print("done")
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

  // MARK: - Picker
  private func configurePickerController() {
    self.picker.delegate = self
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
    
    let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel) { (UIAlertAction) in
      self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    actionSheet.addAction(momentsAction)
    actionSheet.addAction(photosAction)
    actionSheet.addAction(cameraAction)
    actionSheet.addAction(cancelAction)
    self.presentViewController(actionSheet, animated: true, completion: nil)
  }
  
  
  private func pickFromCamera() {
    if UIImagePickerController.isSourceTypeAvailable(.Camera) {
      self.picker.sourceType = .Camera
      self.picker.modalPresentationStyle = .CurrentContext
      self.presentViewController(self.picker, animated: true, completion: nil)
    }
    else {
      self.createAlertController(title: AppDebugMessages.cameraDeviceNotAvailableTitle, message: AppDebugMessages.cameraDeviceNotAvailableMessage, controllerStyle: .Alert, actionStyle: .Destructive)
      print(AppDebugMessages.cameraDeviceNotAvailable)
    }
  }
  
  private func pickFromPhotos() {
    if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.PhotoLibrary) {
      self.picker.sourceType = .PhotoLibrary
      self.presentViewController(self.picker, animated: true, completion: nil)
    }
    else {
      self.createAlertController(title: AppDebugMessages.photosNotAvailableTitle, message: AppDebugMessages.photosNotAvailableMessage, controllerStyle: .Alert, actionStyle: .Destructive)
      print(AppDebugMessages.photosNotAvailable)
    }
  }
  
  private func pickFromMoments() {
    if UIImagePickerController.isSourceTypeAvailable(.SavedPhotosAlbum) {
      self.picker.sourceType = .SavedPhotosAlbum
      self.presentViewController(self.picker, animated: true, completion: nil)
    }
    else {
      self.createAlertController(title: AppDebugMessages.momentsNotAvailableTitle, message: AppDebugMessages.momentsNotAvailableMessage, controllerStyle: .Alert, actionStyle: .Destructive)
      print(AppDebugMessages.momentsNotAvailable)
    }
  }
  
  // MARK: - Picker Delegate
  func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
    if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
      UIImageWriteToSavedPhotosAlbum(pickedImage, nil, nil, nil)
      self.choosenImage.image = pickedImage
    }
    self.dismissViewControllerAnimated(true, completion: nil)
  }
  
  func imagePickerControllerDidCancel(picker: UIImagePickerController) {
    self.dismissViewControllerAnimated(true, completion: nil)
  }
  
  override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
    self.view.endEditing(true)
  }

  
}

//
//  ReportVC.swift
//  Smart Citizen
//
//  Created by Mustafa Hastürk on 03/12/15.
//  Copyright © 2015 Mustafa Hastürk. All rights reserved.
//

import UIKit
import Alamofire
import AWSS3

class ReportVC: AppVC, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
  
  @IBOutlet weak var choosenImage: UIImageView!
  let picker = UIImagePickerController()
  
  @IBOutlet weak var descriptionView: UITextView!
  private let AWSS3BucketName = "smart-citizen"
  
  @IBAction func sendReportAction(sender: AnyObject) {
    let ext = "jpg"
    let imageURL = NSBundle.mainBundle().URLForResource("engın", withExtension: ext)!
    
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
      
      if task.result != nil {
        print(task.result?.url)
        let s3URL = NSURL(string: "https://s3-us-west-2.amazonaws.com/\(self.AWSS3BucketName)/\(uploadRequest.key!)")!
        print("Uploaded to:\n\(s3URL)")
      }
      else {
        print("Unexpected empty result.")
      }
      
      return ""
    }
  }

  
  // MARK: - LC
  override func viewDidLoad() {
    super.viewDidLoad()
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
      self.captureFromCamera()
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
  
  
  private func captureFromCamera() {
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

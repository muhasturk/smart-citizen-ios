//
//  ReportVC.swift
//  Smart Citizen
//
//  Created by Mustafa Hastürk on 03/12/15.
//  Copyright © 2015 Mustafa Hastürk. All rights reserved.
//

import UIKit
import Alamofire

class ReportVC: AppVC, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
  
  @IBOutlet weak var choosenImage: UIImageView!
  let picker = UIImagePickerController()

  override func viewDidLoad() {
    super.viewDidLoad()
    self.configurePickerController()
  }
  
  private func configurePickerController() {
    self.picker.delegate = self
    self.picker.allowsEditing = false
  }
  
  @IBAction func chooseMediaAction(sender: AnyObject) {
    let actionSheet = UIAlertController(title: "Medya Kaynağı", message: nil, preferredStyle: .ActionSheet)
    
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

  func imagePickerController(picker: UIImagePickerController, didFinishPickingImage image: UIImage, editingInfo: [String : AnyObject]?) {
    print("Image selected")
    self.dismissViewControllerAnimated(true, completion: nil)
    self.choosenImage.image = image
  }
  
  func imagePickerControllerDidCancel(picker: UIImagePickerController) {
    self.dismissViewControllerAnimated(true, completion: nil)
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
  }
  
}

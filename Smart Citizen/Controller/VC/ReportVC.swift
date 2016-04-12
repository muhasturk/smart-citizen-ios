//
//  ReportVC.swift
//  Smart Citizen
//
//  Created by Mustafa Hastürk on 03/12/15.
//  Copyright © 2015 Mustafa Hastürk. All rights reserved.
//

import UIKit

class ReportVC: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate {

    @IBOutlet weak var choosenImage: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func captureFromCamera(sender: AnyObject) {
        self.createImagePickerController(.Camera)
    }

    @IBAction func pickFromPhotos(sender: AnyObject) {
        self.createImagePickerController(.PhotoLibrary)
    }
    
    @IBAction func pickFromMoments(sender: AnyObject) {
        self.createImagePickerController(.SavedPhotosAlbum)
    }
    

    func createImagePickerController(sourceType: UIImagePickerControllerSourceType) -> Void {
        
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = sourceType
        picker.allowsEditing = false
        
        self.presentViewController(picker, animated: true, completion: nil)
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingImage image: UIImage, editingInfo: [String : AnyObject]?) {
        print("Image selected")
        self.dismissViewControllerAnimated(true, completion: nil)
        self.choosenImage.image = image
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
}

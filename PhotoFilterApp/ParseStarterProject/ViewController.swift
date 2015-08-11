//
//  ViewController.swift
//
//  Copyright 2011-present Parse Inc. All rights reserved.
//

import UIKit
import Parse

class ViewController: UIViewController {

  @IBOutlet weak var imageView: UIImageView!
  @IBAction func optionsTapped(sender: AnyObject) {
    let alert = UIAlertController(title: PhotoFilterConsts.ImportPhotoFrom, message: PhotoFilterConsts.PickOne, preferredStyle: .ActionSheet)
    let cameraAction = UIAlertAction(title: PhotoFilterConsts.CameraAction, style: UIAlertActionStyle.Destructive) { (action) -> Void in
      self.startImagePicker(.Camera)
    }
    let savedPhotosAlbumAction = UIAlertAction(title: PhotoFilterConsts.SavedPhotosAlbum, style: UIAlertActionStyle.Destructive) { (action) -> Void in
      self.startImagePicker(.SavedPhotosAlbum)
    }
    let photoLibraryAction = UIAlertAction(title: PhotoFilterConsts.PhotoLibraryAction, style: UIAlertActionStyle.Destructive) { (action) -> Void in
      self.startImagePicker(.PhotoLibrary)
    }
    let cancelAction = UIAlertAction(title: PhotoFilterConsts.CancelAction, style: UIAlertActionStyle.Cancel, handler: nil)
    alert.addAction(cameraAction)
    alert.addAction(savedPhotosAlbumAction)
    alert.addAction(photoLibraryAction)
    alert.addAction(cancelAction)
    presentViewController(alert, animated: true, completion: nil)
  }
  override func viewDidLoad() {
      super.viewDidLoad()
  }
  
  func startImagePicker(sourceType: UIImagePickerControllerSourceType) -> Bool {
    let imagePC = UIImagePickerController()
    imagePC.delegate = self
    imagePC.allowsEditing = true
    if UIImagePickerController.isSourceTypeAvailable(sourceType) {
      imagePC.sourceType = sourceType
      presentViewController(imagePC, animated: true, completion: nil)
      return true
    }
    return false
  }
}

extension ViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
  func imagePickerControllerDidCancel(picker: UIImagePickerController) {
    picker.dismissViewControllerAnimated(true, completion: nil)
  }
  func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [NSObject : AnyObject]) {
    if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
      picker.dismissViewControllerAnimated(true, completion: nil)
      imageView.image = image
    }
    else {
      imageView.image = nil
    }
  }
}

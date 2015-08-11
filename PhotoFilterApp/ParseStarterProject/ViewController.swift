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
    if let image = imageView.image {
      actionSheetForFilter()
    }
    else {
      actionSheetForImagePicker()
    }
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
  }
  
  func actionSheetForImagePicker() {
    let alert = UIAlertController(title: PhotoFilterConsts.ImportPhotoFrom, message: PhotoFilterConsts.PickOne, preferredStyle: .ActionSheet)
    for sourceType in UIImagePickerControllerSourceType.allCases {
      let sourceAction = UIAlertAction(title: sourceType.actionTitle, style: UIAlertActionStyle.Destructive) { (action) -> Void in
        self.startImagePicker(sourceType)
      }
      alert.addAction(sourceAction)
    }
    let cancelAction = UIAlertAction(title: PhotoFilterConsts.CancelAction, style: UIAlertActionStyle.Cancel, handler: nil)
    alert.addAction(cancelAction)
    presentViewController(alert, animated: true, completion: nil)
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
  
  func actionSheetForFilter() {
    let alert = UIAlertController(title: PhotoFilterConsts.ChooseFilter, message: PhotoFilterConsts.PickOne, preferredStyle: .ActionSheet)
    for filterType in FilterType.allCases {
      let filterAction = UIAlertAction(title: filterType.actionTitle, style: UIAlertActionStyle.Default) { (action) -> Void in
        self.applyFilter(filterType)
      }
      alert.addAction(filterAction)
    }
    let cancelAction = UIAlertAction(title: PhotoFilterConsts.CancelAction, style: UIAlertActionStyle.Cancel, handler: nil)
    alert.addAction(cancelAction)
    presentViewController(alert, animated: true, completion: nil)
  }
  
  func applyFilter(filterType: FilterType) {
    println("applying filter: \(filterType)")
    let ciImage = CIImage(image: imageView.image)
    let filter = CIFilter(name: filterType.name)
    filter.setValue(ciImage, forKey: kCIInputImageKey)
    let ciImageWithFilter = filter.outputImage
    let context = CIContext()
    let cgImage = context.createCGImage(ciImageWithFilter, fromRect: ciImageWithFilter.extent())
    let uiImage = UIImage(CGImage: cgImage)
  }
}

extension ViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
  func imagePickerControllerDidCancel(picker: UIImagePickerController) {
    picker.dismissViewControllerAnimated(true, completion: nil)
  }
  func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [NSObject : AnyObject]) {
    imageView.image = info[UIImagePickerControllerOriginalImage] as? UIImage ?? nil
    picker.dismissViewControllerAnimated(true, completion: nil)
  }
}

  extension UIImagePickerControllerSourceType {
  var actionTitle: String {
    get {
      switch self {
      case .Camera: return PhotoFilterConsts.CameraAction
      case .SavedPhotosAlbum: return PhotoFilterConsts.SavedPhotosAlbumAction
      case .PhotoLibrary: return PhotoFilterConsts.PhotoLibraryAction
      }
    }
  }
  // used for enumeration; tried to get GeneratorOf<T> to work but not successful
  static var allCases: [UIImagePickerControllerSourceType] { return [.Camera, .SavedPhotosAlbum, .PhotoLibrary] }
}


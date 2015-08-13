//
//  ViewController.swift
//
//  Copyright 2011-present Parse Inc. All rights reserved.
//

import UIKit
import Parse

class ViewController: UIViewController {

  private var previousImage: UIImage?
  var displayImage: UIImage? {
    willSet {
      previousImage = newValue
    }
    didSet {
      imageView.image = displayImage
      collectionView.reloadData()
    }
  }
  private var filterSet: FilterSet?
  
  @IBOutlet weak var imageView: UIImageView!
  @IBOutlet weak var optionsButton: UIButton!
  @IBOutlet weak var doneButton: UIBarButtonItem!
  @IBOutlet weak var collectionView: UICollectionView! {
    didSet {
      collectionView.dataSource = self
      collectionView.delegate = self
    }
  }
  @IBAction func undoTapped(sender: AnyObject) {
    displayImage = previousImage
  }
  @IBAction func doneTapped(sender: AnyObject) {
    if let image = imageView.image {
      let reducedImage = ImageResizer.resize(image, size: CGSize(width: 600, height: 600), withRoundedCorner: nil)
      if let imageData = UIImageJPEGRepresentation(reducedImage, 1.0) {
        let file = PFFile(name: PhotoFilterConsts.PostImageFilename, data: imageData)
        let imagePost = PFObject(className: PhotoFilterConsts.ParsePostClassname)
        imagePost[PhotoFilterConsts.PostImage] = file
        imagePost.saveInBackgroundWithBlock { (result, error) -> Void in
          if let error = error {
            if error.code == PFErrorCode.ErrorConnectionFailed.rawValue {
              // handle error while in a background queue
            }
          }
          if result {
            // nothing to do except perhaps to report success
          }
        }
      }
    }
  }
  @IBAction func optionsTapped(sender: AnyObject) {
    if let image = imageView.image {
      //actionSheetForFilter()
    }
    else {
      actionSheetForImagePicker()
    }
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    filterSet = FilterSet()
  }
  
  func actionSheetForImagePicker() {
    let alert = UIAlertController(title: PhotoFilterConsts.ImportPhotoFrom, message: PhotoFilterConsts.PickOne, preferredStyle: .ActionSheet)
    alert.modalPresentationStyle = .Popover
    alert.popoverPresentationController?.sourceView = view
    alert.popoverPresentationController?.sourceRect = optionsButton.frame
    for sourceType in UIImagePickerControllerSourceType.allCases {
      if UIImagePickerController.isSourceTypeAvailable(sourceType) {
        let sourceAction = UIAlertAction(title: sourceType.actionTitle, style: UIAlertActionStyle.Destructive) { (action) -> Void in
          self.startImagePicker(sourceType)
        }
        alert.addAction(sourceAction)
      }
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
  
  private func filteredImage(image: UIImage, filterType: FilterType) -> UIImage? {
    let context = CIContext(options: nil)
    let parameters = parametersFor(filterType)
    let name = filterType.name
    switch filterType {
    case .CIColorMonochrome(let filter):
      return filter(name, parameters, context, image)
    case .CIColorCrossPolynomial(let filter):
      return filter(name, parameters, context, image)
    case .CIHighlightShadowAdjust(let filter):
      return filter(name, parameters, context, image)
    }
  }

  // this would eventually be in a detail view controller that would allow the
  // various parameters to be set based on the type of filter
  private func parametersFor(filterType: FilterType) -> [String:AnyObject] {
    var parameters = [String:AnyObject]()
    switch filterType {
    case .CIColorMonochrome:
      parameters["inputColor"] = CIColor(CGColor: UIColor.grayColor().CGColor)
      parameters["inputIntensity"] = NSNumber(float: 0.7)
    case .CIColorCrossPolynomial:
      let redFloatArray: [CGFloat] = [0,0,0,0,3,0,0,0,0,0]
      let redVector = CIVector(values: redFloatArray, count: redFloatArray.count)
      let greenFloatArray: [CGFloat] = [0,0,0,0,0,0,0,4,0,0]
      let greenVector = CIVector(values: greenFloatArray, count: greenFloatArray.count)
      let blueFloatArray: [CGFloat] = [0,0,5,0,0,0,0,0,0,0]
      let blueVector = CIVector(values: blueFloatArray, count: blueFloatArray.count)
      parameters["inputRedCoefficients"] = redVector
      parameters["inputGreenCoefficients"] = greenVector
      parameters["inputBlueCoefficients"] = blueVector
    case .CIHighlightShadowAdjust:
      parameters["inputHighlightAmount"] = NSNumber(float: 0.77)
      parameters["inputShadowAmount"] = NSNumber(float: 0.71)
    }
    return parameters
  }
//  func actionSheetForFilter() {
//    let alert = UIAlertController(title: PhotoFilterConsts.ChooseFilter, message: PhotoFilterConsts.PickOne, preferredStyle: .ActionSheet)
//    alert.modalPresentationStyle = .Popover
//    alert.popoverPresentationController?.barButtonItem = doneButton
//    
//    for filterType in FilterType.possibleFilters {
//      let filterAction = UIAlertAction(title: filterType.actionTitle, style: UIAlertActionStyle.Default) { (action) -> Void in
//        self.applyFilter(filterType)
//      }
//      alert.addAction(filterAction)
//    }
//    let cancelAction = UIAlertAction(title: PhotoFilterConsts.CancelAction, style: UIAlertActionStyle.Cancel, handler: nil)
//    alert.addAction(cancelAction)
//    presentViewController(alert, animated: true, completion: nil)
//  }
}

extension ViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
  func imagePickerControllerDidCancel(picker: UIImagePickerController) {
    picker.dismissViewControllerAnimated(true, completion: nil)
  }
  func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [NSObject : AnyObject]) {
    displayImage = info[UIImagePickerControllerEditedImage] as? UIImage ?? nil
    picker.dismissViewControllerAnimated(true, completion: nil)
  }
}

extension ViewController: UICollectionViewDataSource {
  func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return filterSet?.possibleFilters.count ?? 0
  }
  func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
    let cell = collectionView.dequeueReusableCellWithReuseIdentifier(StoryboardConsts.CollectionViewCellReuseIdentifier, forIndexPath: indexPath) as! ThumbnailCell
    
    if let displayImage = displayImage, filterSet = filterSet {
      let filterType = filterSet.possibleFilters[indexPath.row]
      cell.thumbImage = filteredImage(displayImage, filterType: filterType)
    }
    else {
      cell.thumbImage = nil
    }
    return cell
  }
}
extension ViewController: UICollectionViewDelegate {
  func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
    if let displayImage = displayImage, filterSet = filterSet {
      let filterType = filterSet.possibleFilters[indexPath.row]
      self.displayImage = filteredImage(displayImage, filterType: filterType)
    }
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




//
//  ViewController.swift
//
//  Copyright 2011-present Parse Inc. All rights reserved.
//

import UIKit
import Parse

class ViewController: UIViewController {

  // MARK: Public Properties
  var displayImage: UIImage? {
    didSet {
      if originalImage == nil {
        originalImage = displayImage
      }
      imageView.image = displayImage
      collectionView.reloadData()
    }
  }
  
  // MARK: Private Properties
  private var originalImage: UIImage?
  private var filterSet: FilterSet?
  private lazy var context = CIContext(options: nil)
  
  // MARK: IBOutlets
  @IBOutlet weak var imageView: UIImageView!
  @IBOutlet weak var busyIndicator: UIActivityIndicatorView!
  @IBOutlet weak var collectionViewBottomConstraint: NSLayoutConstraint!
  @IBOutlet weak var collectionView: UICollectionView! {
    didSet {
      collectionView.dataSource = self
      collectionView.delegate = self
    }
  }
  // MARK: IBActions
  func addTapped() {
    actionSheetForImagePicker()
  }
  override func setEditing(editing: Bool, animated: Bool) {
    super.setEditing(editing, animated: animated)
    
  }
  func cancelTapped() {
    displayImage = originalImage
  }
  func saveTapped() {
    uploadImage()
  }
  // MARK: Life Cycle Methods
  override func viewDidLoad() {
    super.viewDidLoad()
    navigationItem
    navigationItem.leftBarButtonItem = editButtonItem()
    navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Add, target: self, action: "addTapped")
    if UIDevice.currentDevice().userInterfaceIdiom == UIUserInterfaceIdiom.Phone {
      UIView.animateWithDuration(0.3) { () -> Void in
        self.collectionViewBottomConstraint.constant = 0
        self.view.layoutIfNeeded()
      }
    }
    filterSet = FilterSet()
  }
  // MARK: Private Helper Methods
  private func actionSheetForImagePicker() {
    let alert = UIAlertController(title: PhotoFilterConsts.ImportPhotoFrom, message: PhotoFilterConsts.PickOne, preferredStyle: .ActionSheet)
    alert.modalPresentationStyle = .Popover
    alert.popoverPresentationController?.barButtonItem = navigationItem.leftBarButtonItem
    //alert.popoverPresentationController?.sourceView = view
    //alert.popoverPresentationController?.sourceRect = optionsButton.frame
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
  
  private func startImagePicker(sourceType: UIImagePickerControllerSourceType) -> Bool {
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

  private func uploadImage() {
    if let image = imageView.image {
      let reducedImage = ImageResizer.resize(image, size: CGSize(width: 600, height: 600), withRoundedCorner: nil)
      if let imageData = UIImageJPEGRepresentation(reducedImage, 1.0) {
        let pfFile = PFFile(name: PhotoFilterConsts.PostImageFilename, data: imageData)
        let pfObject = PFObject(className: PhotoFilterConsts.ParsePostClassname)
        pfObject[PhotoFilterConsts.PostImage] = pfFile
        pfObject.saveInBackgroundWithBlock { (result, error) -> Void in
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
}

// MARK: UIImagePickerControllerDelegate
// MARK: UINavigationControllerDelegate
extension ViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
  func imagePickerControllerDidCancel(picker: UIImagePickerController) {
    picker.dismissViewControllerAnimated(true, completion: nil)
  }
  func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [NSObject : AnyObject]) {
    displayImage = info[UIImagePickerControllerEditedImage] as? UIImage ?? nil
    picker.dismissViewControllerAnimated(true, completion: nil)
  }
}
// MARK: UICollectionViewDataSource
extension ViewController: UICollectionViewDataSource {
  func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return filterSet?.possibleFilters.count ?? 0
  }
  func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
    let cell = collectionView.dequeueReusableCellWithReuseIdentifier(StoryboardConsts.ThumbnailCellReuseIdentifier, forIndexPath: indexPath) as! ThumbnailCell
    
    if let displayImage = displayImage, filterSet = filterSet {
      let filterType = filterSet.possibleFilters[indexPath.row]
      busyIndicator.startAnimating()
      cell.thumbImage = filteredImage(displayImage, filterType: filterType)
      busyIndicator.stopAnimating()
    }
    else {
      cell.thumbImage = nil
    }
    return cell
  }
}
// MARK: UICollectionViewDelegate
extension ViewController: UICollectionViewDelegate {
  func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
    if let displayImage = displayImage, filterSet = filterSet {
      let filterType = filterSet.possibleFilters[indexPath.row]
      busyIndicator.startAnimating()
      self.displayImage = filteredImage(displayImage, filterType: filterType)
      busyIndicator.stopAnimating()
    }
  }
}
// MARK: UICollectionViewDataSource
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




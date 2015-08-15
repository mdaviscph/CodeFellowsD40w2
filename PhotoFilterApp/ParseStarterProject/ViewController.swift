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
      imageView.image = displayImage
      collectionView.reloadData()
    }
  }
  
  // MARK: Private Properties
  private var originalNewImage: UIImage? {
    didSet {
      if originalNewImage != nil && UIDevice.currentDevice().userInterfaceIdiom == UIUserInterfaceIdiom.Phone {
        navigationItem.leftBarButtonItem = editButtonItem()
        setEditing(false, animated: true)
      }
    }
  }
  private var filterSet: FilterSet?
  private lazy var context = CIContext(options: nil)
  
  // MARK: IBOutlets
  @IBOutlet weak var imageView: UIImageView!
  @IBOutlet weak var busyIndicator: UIActivityIndicatorView!
  @IBOutlet weak var collectionViewBottomConstraint: NSLayoutConstraint! {
    didSet {
      if UIDevice.currentDevice().userInterfaceIdiom == UIUserInterfaceIdiom.Phone {
        collectionViewBottomConstraint.constant = StoryboardConsts.CollectionViewBottomConstantHidden
      }
    }
  }
  @IBOutlet weak var collectionView: UICollectionView! {
    didSet {
      collectionView.dataSource = self
      collectionView.delegate = self
    }
  }
  // MARK: IBActions
  func addTapped() {
    actionSheetForAddTapped()
  }
  // setEditing (and left Edit/Done button) is only used for iPhones
  override func setEditing(editing: Bool, animated: Bool) {
    super.setEditing(editing, animated: animated)
    let collectionViewBottomConstant: CGFloat
    if editing {
      collectionViewBottomConstant = StoryboardConsts.CollectionViewBottomConstantShow
      navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Cancel, target: self, action: "cancelTapped")    }
    else {
      collectionViewBottomConstant = StoryboardConsts.CollectionViewBottomConstantHidden
      navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Add, target: self, action: "addTapped")
    }
    if animated {
      UIView.animateWithDuration(StoryboardConsts.CollectionViewAnimationDuration) { () -> Void in
        self.collectionViewBottomConstraint.constant = collectionViewBottomConstant
        self.view.layoutIfNeeded()
      }
    } else {
        collectionViewBottomConstraint.constant = collectionViewBottomConstant
        view.layoutIfNeeded()
    }
  }
  func cancelTapped() {
    displayImage = originalNewImage
  }
  func saveTapped() {
    uploadImage()
  }
  
  // MARK: Life Cycle Methods
  override func viewDidLoad() {
    super.viewDidLoad()
    navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Add, target: self, action: "addTapped")
    if UIDevice.currentDevice().userInterfaceIdiom == UIUserInterfaceIdiom.Phone {
      setEditing(false, animated: true)
    }
    filterSet = FilterSet()
  }
  
  // MARK: - Navigation
  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    if segue.identifier == StoryboardConsts.ShowGallerySequeIdentifier, let galleryVC = segue.destinationViewController as? GalleryCollectionViewController {
      galleryVC.delegate = self
      galleryVC.targetImageSize = imageView.frame.size
    }
  }
  
  // MARK: Private Helper Methods
  private func actionSheetForAddTapped() {
    let alert = UIAlertController(title: PhotoFilterConsts.ImportPhotoFrom, message: PhotoFilterConsts.PickOne, preferredStyle: .ActionSheet)
    alert.modalPresentationStyle = .Popover
    alert.popoverPresentationController?.barButtonItem = navigationItem.leftBarButtonItem
    //alert.popoverPresentationController?.sourceView = view
    //alert.popoverPresentationController?.sourceRect = optionsButton.frame
    for sourceType in UIImagePickerControllerSourceType.allCases {
      if UIImagePickerController.isSourceTypeAvailable(sourceType) {
        let sourceAction = UIAlertAction(title: sourceType.actionTitle, style: .Default) { (action) -> Void in
          self.startImagePicker(sourceType)
        }
        alert.addAction(sourceAction)
      }
    }
    let galleryAction = UIAlertAction(title: PhotoFilterConsts.GalleryAction, style: UIAlertActionStyle.Default) { (action) -> Void in
      self.performSegueWithIdentifier(StoryboardConsts.ShowGallerySequeIdentifier, sender: self.navigationItem.rightBarButtonItem)
    }
    let cancelAction = UIAlertAction(title: PhotoFilterConsts.CancelAction, style: UIAlertActionStyle.Cancel, handler: nil)
    alert.addAction(galleryAction)
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
    if let image = info[UIImagePickerControllerEditedImage] as? UIImage {
      displayImage = image
      originalNewImage = image
    }
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
// MARK: ImageSelectedDelegate
extension ViewController: ImageSelectedDelegate {
  func controllerDidSelectImage(image: UIImage) {
    displayImage = image
    originalNewImage = image
  }
}

// MARK: UIImagePickerControllerSourceType extension
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



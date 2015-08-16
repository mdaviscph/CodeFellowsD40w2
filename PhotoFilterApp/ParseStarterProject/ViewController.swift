//
//  ViewController.swift
//
//  Copyright 2011-present Parse Inc. All rights reserved.
//

import UIKit
import Parse
import Social

class ViewController: UIViewController {

  // MARK: Public Properties
  var displayImage: UIImage? {
    didSet {
      let date = NSDate()
      if let displayImage = displayImage {
        let reducedImage = ImageResizer.resize(displayImage, size: imageView.frame.size, withRoundedCorner: nil)
        imageView.image = reducedImage
      } else {
        imageView.image = nil
      }
      collectionView.reloadData()
    }
  }
  
  // MARK: Private Properties
  private var originalNewImage: UIImage?
  private var filterSet: FilterSet?
  
  //private lazy var context = CIContext(options: nil)
  private lazy var context = CIContext(EAGLContext: EAGLContext(API: EAGLRenderingAPI.OpenGLES2), options: [kCIContextWorkingColorSpace:NSNull()])
  
  // MARK: IBOutlets
  @IBOutlet weak var imageView: UIImageView!
  @IBOutlet weak var collectionViewBottomConstraint: NSLayoutConstraint!
  @IBOutlet weak var collectionView: UICollectionView! {
    didSet {
      collectionView.dataSource = self
      collectionView.delegate = self
    }
  }
  
  // MARK: Button Related Methods
  func addTapped() {
    actionSheetForAddTapped()
    setNavigationItemButtons(true)
  }
  func editTapped() {
    setNavigationItemButtons(true)
  }
  func undoTapped() {
    displayImage = originalNewImage
  }
  func doneTapped() {
    actionSheetForDoneTapped()
    setNavigationItemButtons(false)
  }
  func cancelAdd() {
    setNavigationItemButtons(false)
  }
  func cancelSave() {
    
  }

  private func setNavigationItemButtons(editing: Bool) {
    let collectionViewBottomConstant: CGFloat
    if editing {
      collectionViewBottomConstant = StoryboardConsts.CollectionViewBottomConstantShow
      navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Undo, target: self, action: "undoTapped")
      navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Done, target: self, action: "doneTapped")
    }
    else {
      collectionViewBottomConstant = StoryboardConsts.CollectionViewBottomConstantHidden
      navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Add, target: self, action: "addTapped")
      if UIDevice.currentDevice().userInterfaceIdiom == UIUserInterfaceIdiom.Phone && originalNewImage != nil {
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Edit, target: self, action: "editTapped")
      }
    }
    if UIDevice.currentDevice().userInterfaceIdiom == UIUserInterfaceIdiom.Phone {
      UIView.animateWithDuration(StoryboardConsts.CollectionViewAnimationDuration) { () -> Void in
        self.collectionViewBottomConstraint.constant = collectionViewBottomConstant
        self.view.layoutIfNeeded()
      }
    }
  }

  // MARK: Life Cycle Methods
  override func viewDidLoad() {
    super.viewDidLoad()
    setNavigationItemButtons(false)
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
    let alert = UIAlertController(title: PhotoFilterConsts.ImportPhotoFrom, message: PhotoFilterConsts.PickImport, preferredStyle: .ActionSheet)
    alert.modalPresentationStyle = .Popover
    alert.popoverPresentationController?.barButtonItem = navigationItem.rightBarButtonItem
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
    let cancelAction = UIAlertAction(title: PhotoFilterConsts.CancelAction, style: UIAlertActionStyle.Cancel) { (action) -> Void in
      self.cancelAdd()
    }
    alert.addAction(galleryAction)
    alert.addAction(cancelAction)
    presentViewController(alert, animated: true, completion: nil)
  }
  
  private func actionSheetForDoneTapped() {
    let alert = UIAlertController(title: PhotoFilterConsts.SaveOrShare, message: PhotoFilterConsts.PickSave, preferredStyle: .ActionSheet)
    alert.modalPresentationStyle = .Popover
    alert.popoverPresentationController?.barButtonItem = navigationItem.leftBarButtonItem
    let uploadAction = UIAlertAction(title: PhotoFilterConsts.UploadAction, style: UIAlertActionStyle.Default) { (action) -> Void in
      self.uploadImage()
    }
    let saveToPhoneAction = UIAlertAction(title: PhotoFilterConsts.SaveToPhoneAction, style: UIAlertActionStyle.Default) { (action) -> Void in
      self.saveImageToPhone()
    }
    let shareOnTwitterAction = UIAlertAction(title: PhotoFilterConsts.ShareOnTwitterAction, style: UIAlertActionStyle.Default) { (action) -> Void in
      self.shareImageOnTwitter()
    }
    let cancelAction = UIAlertAction(title: PhotoFilterConsts.CancelAction, style: UIAlertActionStyle.Cancel) { (action) -> Void in
      self.cancelSave()
    }
    alert.addAction(uploadAction)
    alert.addAction(saveToPhoneAction)
    alert.addAction(shareOnTwitterAction)
    alert.addAction(cancelAction)
    presentViewController(alert, animated: true, completion: nil)
  }
  
  private func startImagePicker(sourceType: UIImagePickerControllerSourceType) {
    let imagePC = UIImagePickerController()
    imagePC.delegate = self
    imagePC.allowsEditing = true
    if UIImagePickerController.isSourceTypeAvailable(sourceType) {
      imagePC.sourceType = sourceType
      presentViewController(imagePC, animated: true, completion: nil)
    }
  }
  
  private func uploadImage() {
    if let image = displayImage {
      let reducedImage = ImageResizer.resize(image, size: StoryboardConsts.UploadImageSize, withRoundedCorner: nil)
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
  
  private func saveImageToPhone() {
    
  }
  
  private func shareImageOnTwitter() {
    
    if SLComposeViewController.isAvailableForServiceType(SLServiceTypeTwitter) {
      if let image = displayImage {
        let reducedImage = ImageResizer.resize(image, size: StoryboardConsts.TwitterImageSize, withRoundedCorner: nil)
        let socialComposeVC = SLComposeViewController(forServiceType: SLServiceTypeTwitter)
        socialComposeVC.completionHandler = { (result) -> Void in
          if result == .Cancelled {
            NSOperationQueue.mainQueue().addOperationWithBlock { () -> Void in
              self.cancelSave()
            }
          }
        }
        if socialComposeVC.setInitialText(PhotoFilterConsts.TwitterImageText) && socialComposeVC.addImage(reducedImage) {
          presentViewController(socialComposeVC, animated: true, completion: nil)
        }
      }
    }
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
}

// MARK: UIImagePickerControllerDelegate
// MARK: UINavigationControllerDelegate
extension ViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
  func imagePickerControllerDidCancel(picker: UIImagePickerController) {
    picker.dismissViewControllerAnimated(true, completion: nil)
    cancelAdd()
  }
  func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [NSObject : AnyObject]) {
    picker.dismissViewControllerAnimated(true, completion: nil)
    if let image = info[UIImagePickerControllerEditedImage] as? UIImage {
      displayImage = image
      originalNewImage = image
    }
  }
}
// MARK: UICollectionViewDataSource
extension ViewController: UICollectionViewDataSource {
  func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return filterSet?.possibleFilters.count ?? 0
  }
  func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
    let cell = collectionView.dequeueReusableCellWithReuseIdentifier(StoryboardConsts.ThumbnailCellReuseIdentifier, forIndexPath: indexPath) as! ThumbnailCell
    let tag = ++cell.tag
    cell.thumbImage = nil
    if let displayImage = displayImage, filterSet = filterSet {
      let filterType = filterSet.possibleFilters[indexPath.row]
      let date = NSDate()
      NSOperationQueue().addOperationWithBlock { () -> Void in
        let image = self.filteredImage(displayImage, filterType: filterType)
        NSOperationQueue.mainQueue().addOperationWithBlock { () -> Void in
          if cell.tag == tag {
            cell.thumbImage = image
          }
          println(String(format: "filtered image in %0.4f seconds", -date.timeIntervalSinceNow))
        }
      }
    }
    return cell
  }
}
// MARK: UICollectionViewDelegate
extension ViewController: UICollectionViewDelegate {
  func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
    if let displayImage = displayImage, filterSet = filterSet {
      let filterType = filterSet.possibleFilters[indexPath.row]
      let date = NSDate()
      self.displayImage = filteredImage(displayImage, filterType: filterType)
      println(String(format: "filtered image in %0.4f seconds", -date.timeIntervalSinceNow))
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



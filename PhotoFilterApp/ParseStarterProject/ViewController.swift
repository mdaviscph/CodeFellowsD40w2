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
      let reducedImage = ImageResizer.resize(image, size: CGSize(width: 600, height: 600))
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
  
  func actionSheetForFilter() {
    let alert = UIAlertController(title: PhotoFilterConsts.ChooseFilter, message: PhotoFilterConsts.PickOne, preferredStyle: .ActionSheet)
    alert.modalPresentationStyle = .Popover
    alert.popoverPresentationController?.barButtonItem = doneButton
    
    for filterType in FilterType.possibleFilters {
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
    var filter: CIFilter?
    switch filterType {
    // for now define parameters here until I can figure out a better way/place
    case .CIColorCrossPolynomial (let paramaters):
      filter = CIFilter(name: filterType.name, withInputParameters: paramaters)
    case .CIColorMonochrome (let ciColorParameter, let numberParameter):
      var parameters = [String:AnyObject]()
      for (key, value) in ciColorParameter {
        parameters[key] = value
      }
      for (key, value) in numberParameter {
        parameters[key] = value
      }
      filter = CIFilter(name: filterType.name, withInputParameters: parameters)
    case .CIHighlightShadowAdjust (let parameters):
      filter = CIFilter(name: filterType.name, withInputParameters: parameters)
    default:
      break
    }
    if let filter = filter {
      filter.setValue(ciImage, forKey: kCIInputImageKey)
      let ciImageWithFilter = filter.outputImage
      let context = CIContext(options: nil)
      let cgImage = context.createCGImage(ciImageWithFilter, fromRect: ciImageWithFilter.extent())
      displayImage = UIImage(CGImage: cgImage)
    }
  }
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
    return FilterType.possibleFilters.count
  }
  func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
    let cell = collectionView.dequeueReusableCellWithReuseIdentifier(StoryboardConsts.CollectionViewCellReuseIdentifier, forIndexPath: indexPath) as! ThumbnailCell
    cell.thumbImage = displayImage
    return cell
  }
}
extension UIViewController: UICollectionViewDelegate {
  
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
extension FilterType {
  static var possibleFilters: [FilterType] {
    
    // Color Monochrome
    let ciColor = CIColor(CGColor: UIColor.grayColor().CGColor)
    let number = NSNumber(float: 0.7)
    // Color Cross Polynomial
    let redFloatArray: [CGFloat] = [0,0,0,0,3,0,0,0,0,0]
    let redVector = CIVector(values: redFloatArray, count: redFloatArray.count)
    let greenFloatArray: [CGFloat] = [0,0,0,0,0,0,0,4,0,0]
    let greenVector = CIVector(values: greenFloatArray, count: greenFloatArray.count)
    let blueFloatArray: [CGFloat] = [0,0,5,0,0,0,0,0,0,0]
    let blueVector = CIVector(values: blueFloatArray, count: blueFloatArray.count)
    // Line Overlay
    let highlightAmount = NSNumber(float: 0.77)
    let shadowAmount = NSNumber(float: 0.71)
    
    return [
      .CIColorMonochrome(["inputColor":ciColor], ["inputIntensity":number]),
      .CIColorCrossPolynomial(["inputRedCoefficients":redVector, "inputGreenCoefficients":greenVector, "inputBlueCoefficients":blueVector]),
      .CIHighlightShadowAdjust(["inputHighlightAmount":highlightAmount, "inputShadowAmount":shadowAmount])
    ]
  }
}

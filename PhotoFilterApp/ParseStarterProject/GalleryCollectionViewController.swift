//
//  GalleryCollectionViewController.swift
//  ParseStarterProject
//
//  Created by mike davis on 8/13/15.
//  Copyright (c) 2015 Parse. All rights reserved.
//

import UIKit
import Photos

class GalleryCollectionViewController: UICollectionViewController {

  // MARK: Public Properties
  weak var delegate: ImageSelectedDelegate?
  var targetImageSize = StoryboardConsts.DisplayImageTargetSize
  
  // MARK: Private Properties
  private var imagesMetaData: PHFetchResult?
  private var collectionViewScale: CGFloat = 1
  
  // MARK: Action Selector Methods
  func pinchGesture(sender: UIPinchGestureRecognizer) {
    switch sender.state {
    case .Began:
      collectionViewScale = sender.scale
    case .Ended:
      collectionViewScale *= sender.scale
      scaleCollectionView(collectionViewScale)
    default:
      break
    }
  }

  // MARK: Lifecycle Methods
  override func viewDidLoad() {
    super.viewDidLoad()
    
    // Uncomment the following line to preserve selection between presentations
    // clearsSelectionOnViewWillAppear = false
    
    // Register cell classes
    // leaving this call in caused the IBOutlet for the UIImageView to not be setup
    //collectionView!.registerClass(ThumbnailCell.self, forCellWithReuseIdentifier: reuseIdentifier)
    
    let recognizer = UIPinchGestureRecognizer(target: self, action: "pinchGesture:")
    collectionView?.addGestureRecognizer(recognizer)
    
    let date = NSDate()
    imagesMetaData = PHAsset.fetchAssetsWithMediaType(PHAssetMediaType.Image, options: nil)
    println(String(format: "fetchAssetsWithMediaType in %0.4f seconds", -date.timeIntervalSinceNow))
  }
  
  // MARK: Private Helper Methods
  func scaleCollectionView(scale: CGFloat) {
    if let layout = collectionView?.collectionViewLayout as? UICollectionViewFlowLayout {
      collectionView!.performBatchUpdates({ () -> Void in
        layout.itemSize *= scale
        layout.itemSize.width = min(max(layout.itemSize.width, StoryboardConsts.GalleryCellMinimumSize), StoryboardConsts.GalleryCellMaximumSize)
        layout.itemSize.height = min(max(layout.itemSize.height, StoryboardConsts.GalleryCellMinimumSize), StoryboardConsts.GalleryCellMaximumSize)
        layout.invalidateLayout()
        }, completion: { (finished) -> Void in
          collectionView?.reloadData()    // breakpoint shows this in main-thread
      })
    }
  }
  
  // MARK: UICollectionViewDataSource
  override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return imagesMetaData?.count ?? 0
  }

  override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
    let cell = collectionView.dequeueReusableCellWithReuseIdentifier(StoryboardConsts.ThumbnailCellReuseIdentifier, forIndexPath: indexPath) as! ThumbnailCell
    cell.thumbImage = nil
    var targetSize = StoryboardConsts.GalleryCellTargetSize
    if let size = collectionView.layoutAttributesForItemAtIndexPath(indexPath)?.bounds.size {
      targetSize = size
    }
    
    if let asset = imagesMetaData?[indexPath.row] as? PHAsset {
      let requestId = PHCachingImageManager().requestImageForAsset(asset, targetSize: targetSize, contentMode: PHImageContentMode.AspectFill, options: nil) { (image, info) -> Void in
        if let image = image {
          cell.thumbImage = image
        }
        else {
          // do something with dictionary possibly using PHImageCancelledKey or PHImageErrorKey
        }
      }
    }
    return cell
  }

}


// MARK: UICollectionViewDelegate
extension GalleryCollectionViewController: UICollectionViewDelegate {
  override func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
    if let asset = imagesMetaData?[indexPath.row] as? PHAsset {
      let options = PHImageRequestOptions()
      options.synchronous = true
      NSOperationQueue().addOperationWithBlock { () -> Void in
        let date = NSDate()
        let requestId = PHCachingImageManager().requestImageForAsset(asset, targetSize: self.targetImageSize, contentMode: PHImageContentMode.AspectFill, options: options) { (image, info) -> Void in
          if let image = image {
            NSOperationQueue.mainQueue().addOperationWithBlock { () -> Void in
              println(String(format: "requestImageForAsset in %0.4f seconds", -date.timeIntervalSinceNow))
              self.navigationController?.popViewControllerAnimated(true)
              self.delegate?.controllerDidSelectImage(image)
            }
          }
          else {
            // do something with dictionary possibly using PHImageCancelledKey or PHImageErrorKey
          }
        }
      }
    }
  }
}

// MARK: ImageSelectedDelegate Protocol
protocol ImageSelectedDelegate: class {
  func controllerDidSelectImage(UIImage) -> Void
}

private func * (lhs: CGSize, rhs: CGFloat) -> CGSize {
  return CGSize(width: lhs.width*rhs, height: lhs.height*rhs)
}
private func *= (inout lhs: CGSize, rhs: CGFloat) {
  lhs = lhs * rhs
}


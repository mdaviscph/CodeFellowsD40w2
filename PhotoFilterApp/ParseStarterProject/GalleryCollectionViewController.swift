//
//  GalleryCollectionViewController.swift
//  ParseStarterProject
//
//  Created by mike davis on 8/13/15.
//  Copyright (c) 2015 Parse. All rights reserved.
//

import UIKit
import Photos

let reuseIdentifier = StoryboardConsts.ThumbnailCellReuseIdentifier

class GalleryCollectionViewController: UICollectionViewController {

  weak var delegate: ImageSelectedDelegate?
  var targetImageSize = StoryboardConsts.DisplayImageTargetSize
  
  private var imagesMetaData: PHFetchResult?
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    // Uncomment the following line to preserve selection between presentations
    // clearsSelectionOnViewWillAppear = false
    
    // Register cell classes
    // leaving this call in caused the IBOutlet for the UIImageView to not be setup
    //collectionView!.registerClass(ThumbnailCell.self, forCellWithReuseIdentifier: reuseIdentifier)
    
    let date = NSDate()
    imagesMetaData = PHAsset.fetchAssetsWithMediaType(PHAssetMediaType.Image, options: nil)
    println(String(format: "fetchAssetsWithMediaType in %0.4f seconds", -date.timeIntervalSinceNow))
  }
  
  // MARK: UICollectionViewDataSource
  override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return imagesMetaData?.count ?? 0
  }

  override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
    let cell = collectionView.dequeueReusableCellWithReuseIdentifier(reuseIdentifier, forIndexPath: indexPath) as! ThumbnailCell
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


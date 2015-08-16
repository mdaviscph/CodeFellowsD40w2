//
//  ThumbnailCell.swift
//  ParseStarterProject
//
//  Created by mike davis on 8/12/15.
//  Copyright (c) 2015 Parse. All rights reserved.
//

import UIKit

class ThumbnailCell: UICollectionViewCell {
 
  // MARK: Public Properties
  var thumbImage: UIImage? {
    didSet {
      if let thumbImage = thumbImage, imageView = imageView {
        let reducedImage = ImageResizer.resize(thumbImage, size: imageView.bounds.size, withRoundedCorner: UIColor.whiteColor())
        imageView.image = reducedImage
      }
    }
  }
  // MARK: IBOutlets
  @IBOutlet weak var imageView: UIImageView!
}

//
//  ThumbnailCell.swift
//  ParseStarterProject
//
//  Created by mike davis on 8/12/15.
//  Copyright (c) 2015 Parse. All rights reserved.
//

import UIKit

class ThumbnailCell: UICollectionViewCell {
  
  var thumbImage: UIImage? {
    didSet {
      imageView.image = thumbImage
    }
  }
  @IBOutlet weak var imageView: UIImageView!
}

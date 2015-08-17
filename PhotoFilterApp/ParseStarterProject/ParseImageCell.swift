//
//  ParseImageCell.swift
//  ParseStarterProject
//
//  Created by mike davis on 8/13/15.
//  Copyright (c) 2015 Parse. All rights reserved.
//

import UIKit

class ParseImageCell: UITableViewCell {

  // MARK: Public Properties
  var parseImage: UIImage? {
    didSet {
      if let parseImage = parseImage, reducedImageView = reducedImageView  {
        let reducedImage = ImageResizer.resize(parseImage, size: reducedImageView.frame.size, withRoundedCorner: nil)
        reducedImageView.image = reducedImage
      }
    }
  }
  // MARK: IBOutlets
  @IBOutlet weak var reducedImageView: UIImageView!
}

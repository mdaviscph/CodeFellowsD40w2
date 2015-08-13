//
//  ImageResizer.swift
//  ParseStarterProject
//
//  Created by mike davis on 8/12/15.
//  Copyright (c) 2015 Parse. All rights reserved.
//

import UIKit

class ImageResizer {
  
  class func resize(image: UIImage, size: CGSize) -> UIImage {
    // fastest way to resize an image; from nshipster.com
    UIGraphicsBeginImageContext(size)
    let rect = CGRect(origin: CGPoint.zeroPoint, size: size)
    image.drawInRect(rect)
    let resizedImage = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
    return resizedImage
  }
}
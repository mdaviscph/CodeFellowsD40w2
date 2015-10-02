//
//  ImageResizer.swift
//  ParseStarterProject
//
//  Created by mike davis on 8/12/15.
//  Copyright (c) 2015 Parse. All rights reserved.
//

import UIKit

class ImageResizer {
  
  // MARK: Class Methods
  class func resize(image: UIImage, size: CGSize, withRoundedCorner color: UIColor?) -> UIImage {
    // fastest way to resize an image; from nshipster.com
    print("image resized: \(image.size)->", terminator: "")
    let date = NSDate()
    UIGraphicsBeginImageContext(size)
    let rect = CGRect(origin: CGPoint.zero, size: size)
    image.drawInRect(rect)
    if let color = color {
      let inset = size.width/8
      let path = UIBezierPath(roundedRect: CGRectInset(rect, -inset, -inset), cornerRadius: size.width/4)
      color.setStroke()
      path.lineWidth = inset*2
      path.stroke()
    }
    let resizedImage = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
    print(String(format: "\(resizedImage.size) in %0.4f seconds", -date.timeIntervalSinceNow))
    return resizedImage
  }
}
//
//  FilterSet.swift
//  ParseStarterProject
//
//  Created by mike davis on 8/12/15.
//  Copyright (c) 2015 Parse. All rights reserved.
//

import UIKit

class FilterSet {
  
  // MARK: Public Properties
  var possibleFilters = [FilterType]()
  
  init() {
    possibleFilters.append(FilterType.CIColorMonochrome(imageAfterFilter))
    possibleFilters.append(FilterType.CIColorCrossPolynomial(imageAfterFilter))
    possibleFilters.append(FilterType.CIHighlightShadowAdjust(imageAfterFilter))
  }
  // MARK: Private Methods
  private  func imageAfterFilter(name: String, parameters: [String:AnyObject], context: CIContext, image: UIImage) -> UIImage? {
    let ciImage = CIImage(image: image)
    let filter = CIFilter(name: name, withInputParameters: parameters)
    filter.setValue(ciImage, forKey: kCIInputImageKey)
    let ciImageWithFilter = filter.outputImage
    let cgImage = context.createCGImage(ciImageWithFilter, fromRect: ciImageWithFilter.extent())
    let orientation = image.imageOrientation
    switch orientation {
    case .Down:  return UIImage(CGImage: cgImage, scale: 1.0, orientation: UIImageOrientation.Down)
    case .Left:  return UIImage(CGImage: cgImage, scale: 1.0, orientation: UIImageOrientation.Left)
    case .Right: return UIImage(CGImage: cgImage, scale: 1.0, orientation: UIImageOrientation.Right)
    default: return UIImage(CGImage: cgImage)
    }
  }
}

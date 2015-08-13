//
//  FilterSet.swift
//  ParseStarterProject
//
//  Created by mike davis on 8/12/15.
//  Copyright (c) 2015 Parse. All rights reserved.
//

import UIKit

class FilterSet {
  
  var possibleFilters = [FilterType]()
  
  init() {
    possibleFilters.append(FilterType.CIColorMonochrome(imageAfterFilter))
    possibleFilters.append(FilterType.CIColorCrossPolynomial(imageAfterFilter))
    possibleFilters.append(FilterType.CIHighlightShadowAdjust(imageAfterFilter))
  }
  private  func imageAfterFilter(name: String, parameters: [String:AnyObject], context: CIContext, image: UIImage) -> UIImage? {
    let ciImage = CIImage(image: image)
    let filter = CIFilter(name: name, withInputParameters: parameters)
    filter.setValue(ciImage, forKey: kCIInputImageKey)
    let ciImageWithFilter = filter.outputImage
    let cgImage = context.createCGImage(ciImageWithFilter, fromRect: ciImageWithFilter.extent())
    return UIImage(CGImage: cgImage)
  }
}

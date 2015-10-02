//
//  FilterType.swift
//  ParseStarterProject
//
//  Created by mike davis on 8/11/15.
//  Copyright (c) 2015 Parse. All rights reserved.
//

import UIKit

enum FilterType {
  case CIColorMonochrome ((String, [String:AnyObject], CIContext, UIImage) -> UIImage?)
  case CIColorCrossPolynomial ((String, [String:AnyObject], CIContext, UIImage) -> UIImage?)
  case CIHighlightShadowAdjust ((String, [String:AnyObject], CIContext, UIImage) -> UIImage?)
  
  // MARK: Public Properties
  // used for CIFilter(name: String)
  var name: String {
    get {
      switch self {
      case .CIColorMonochrome: return "CIColorMonochrome"
      case .CIColorCrossPolynomial: return "CIColorCrossPolynomial"
      case .CIHighlightShadowAdjust: return "CIHighlightShadowAdjust"
      }
    }
  }
}
// MARK: Printable
extension FilterType: CustomStringConvertible {
  var description: String {
    get {
      switch self {
      case .CIColorMonochrome: return "Color Monochrome Filter"
      case .CIColorCrossPolynomial: return "Color Cross Polynomial Filter"
      case .CIHighlightShadowAdjust: return "Highlight Shadow Adjust Filter"
      }
    }
  }
}

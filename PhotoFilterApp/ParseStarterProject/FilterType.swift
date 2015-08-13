//
//  FilterType.swift
//  ParseStarterProject
//
//  Created by mike davis on 8/11/15.
//  Copyright (c) 2015 Parse. All rights reserved.
//

import Foundation
import CoreImage
import UIKit

enum FilterType {
  case CIColorMonochrome ([String:CIColor], [String:NSNumber])
  case CIColorCrossPolynomial ([String:CIVector])
  case CIHighlightShadowAdjust ([String:NSNumber])
  var actionTitle: String {
    get {
      switch self {
      case .CIColorMonochrome: return PhotoFilterConsts.ColorMonochromeAction
      case .CIColorCrossPolynomial: return PhotoFilterConsts.ColorCrossPolynomialAction
      case .CIHighlightShadowAdjust: return PhotoFilterConsts.HighlightShadowAdjustAction
      }
    }
  }
  // name used for CIFilter(name: String)
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
extension FilterType: Printable {
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

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
  case CITriangleKaleidoscope
  var actionTitle: String {
    get {
      switch self {
      case .CIColorMonochrome: return PhotoFilterConsts.ColorMonochromeAction
      case .CIColorCrossPolynomial: return PhotoFilterConsts.ColorCrossPolynomialAction
      case .CITriangleKaleidoscope: return PhotoFilterConsts.TriangleKaleidoscopeAction
      }
    }
  }
  // name used for CIFilter(name: String)
  var name: String {
    get {
      switch self {
      case .CIColorMonochrome: return "CIColorMonochrome"
      case .CIColorCrossPolynomial: return "CIColorCrossPolynomial"
      case .CITriangleKaleidoscope: return "CITriangleKaleidoscope"
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
      case .CITriangleKaleidoscope: return "Triangle Kaleidoscope Filter"
      }
    }
  }
}
extension FilterType {
  static var possibleFilters: [FilterType] {
    let ciColor = CIColor(CGColor: UIColor.grayColor().CGColor)
    let number = NSNumber(float: 0.7)
    
    let redFloatArray: [CGFloat] = [0,0,0,0,3,0,0,0,0,0]
    let redVector = CIVector(values: redFloatArray, count: redFloatArray.count)
    let greenFloatArray: [CGFloat] = [0,0,0,0,0,0,0,4,0,0]
    let greenVector = CIVector(values: greenFloatArray, count: greenFloatArray.count)
    let blueFloatArray: [CGFloat] = [0,0,5,0,0,0,0,0,0,0]
    let blueVector = CIVector(values: blueFloatArray, count: blueFloatArray.count)

    return [
      .CIColorMonochrome(["inputColor":ciColor], ["inputIntensity":number]),
      .CIColorCrossPolynomial(["inputRedCoefficients":redVector, "inputGreenCoefficients":greenVector, "inputBlueCoefficients":blueVector]),
      .CITriangleKaleidoscope] }
}

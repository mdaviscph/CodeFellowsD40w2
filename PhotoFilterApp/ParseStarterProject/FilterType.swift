//
//  FilterType.swift
//  ParseStarterProject
//
//  Created by mike davis on 8/11/15.
//  Copyright (c) 2015 Parse. All rights reserved.
//

import Foundation

enum FilterType: Int {
  case CIColorMonochrome, CIColorCrossPolynomial, CITriangleKaleidoscope
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
// used for enumeration; tried to get GeneratorOf<T> to work but not successful
extension FilterType {
  static var allCases: [FilterType] { return [.CIColorMonochrome, .CIColorCrossPolynomial, .CITriangleKaleidoscope] }
}

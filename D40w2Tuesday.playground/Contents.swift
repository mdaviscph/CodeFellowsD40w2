//Code Challenge: Write a function that returns all the odd elements of an array

import Foundation

let array1 = ["even","odd","even","odd","even"]
let array2 = [1,2,3,4,5,6]
let array3: [Character] = ["a","b"]
let array4 = [Int]()
let array5 = [[1,2],[3,4],[5,6],[7,8]]
let array6 = [true]

func oddElements(array: [String]) -> [String] {
  var result = [String]()
  for (index, item) in enumerate(array) {
    if index%2 != 0 { result.append(item) }
  }
  return result
}

extension Array {
  func itemsAtoddIndicies() -> [T] {
    var result = [T]()
    for (index, item) in enumerate(self) {
      if index%2 != 0 { result.append(item) }
    }
    return result
  }
}


oddElements(array1)
array1.itemsAtoddIndicies()
array2.itemsAtoddIndicies()
array3.itemsAtoddIndicies()
array4.itemsAtoddIndicies()
array5.itemsAtoddIndicies()
array6.itemsAtoddIndicies()

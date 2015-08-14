// Code Challenge: Write a function that computes the list of the first 100 Fibonacci numbers.

import Foundation

// according to wikipedia:
// in mathmatics the Fibonacci sequence starts with 1,1
// in modern usage the sequence starts with 0,1
let startMathmatics:[UInt] = [1,1]
let startModern:[UInt] = [0,1]

func fibonacciSequence(start: [UInt], requestedCount: Int) -> ([UInt], [Double]?) {
  var result = start
  var resultMore: [Double]?
  var sum = start.reduce(0, combine: +)
  for _ in start.count..<requestedCount {
    let last = result.last!
    var overflow = false
    result.append(sum)
    (sum, overflow: overflow) = UInt.addWithOverflow(sum, last)
    if overflow {
      break
    }
  }
  if result.count != requestedCount {
    let lastOne = Double(result.removeLast())
    let lastZero = Double(result.removeLast())
    resultMore = fibonacciSequence([lastZero,lastOne], requestedCount - result.count)
  }
  return (result, resultMore)
}
func fibonacciSequence(start: [Double], requestedCount: Int) -> [Double] {
  var result = start
  var sum = start.reduce(0, combine: +)
  for _ in start.count..<requestedCount {
    let last = result.last!
    var overflow = false
    result.append(sum)
    sum += last
  }
  return result
}

println(fibonacciSequence(startMathmatics, 100))
fibonacciSequence(startModern, 10)
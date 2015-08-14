// Code Challenge: Write a function that tests whether a string is a palindrome

import Foundation

let string1 = "abcdefedcba"
let string2 = "abcdeedcba"
let string3 = ""
let string4 = "a"
let string5 = "bb"
let string6 = "cdc"
let string7 = "de"
let string8 = "fghfgh"
let string9 = "😀😁😂😃😂😁😀"

extension String {
  func reverse() -> String {
    var result = String()
    for character in self {
      result.insert(character, atIndex: result.startIndex)
    }
    return result
  }
}
func isPalindrome(string: String) -> Bool {
  
  if count(string) < 1 { return false }
  let endOfFirstHalf = count(string)/2
  let startOfSecondHalf = endOfFirstHalf*2 == count(string) ? endOfFirstHalf : endOfFirstHalf+1
  let firstHalf = string.substringToIndex(advance(string.startIndex, endOfFirstHalf))
  let secondHalf = string.substringFromIndex(advance(string.startIndex, startOfSecondHalf))
  println(firstHalf, secondHalf)
  return firstHalf == secondHalf.reverse()
}

isPalindrome(string1)
isPalindrome(string2)
isPalindrome(string3)
isPalindrome(string4)
isPalindrome(string5)
isPalindrome(string6)
isPalindrome(string7)
isPalindrome(string8)
isPalindrome(string9)
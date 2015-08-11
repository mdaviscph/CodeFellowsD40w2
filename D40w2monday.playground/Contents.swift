// Code Challenge: Write a function that determines how many words there are in a sentence
// Note: I am assuming that a word is defined as non-whitespace separated by white-space where white-space is defined as tabs or spaces. Should probably include separation by punctuation or newlines.

import Foundation

let wordBreak: [Character] = [" ","\t","\n","!","@","#","$","%","^","&","*","(",")",
  "-","_","=","+","{","}","[","]","\\","|",";",":",",","<",".",">","/","?"]

let string1 = "now is the time for all good men to come to the aid of their country"
let string2 = "a rat in tom's house might eat tom's ice cream"
let string3 = "\tone        "
let string4 = "two.words"
let string5 = ""
let string6 = "one"
let string7 = "()"

func countWords (string: String) -> Int {
  var result = 0
  var inBreak = true
  for character in string {
    if contains(wordBreak, character) {
      inBreak = true
    } else if inBreak {
      result++
      inBreak = false
    }
  }
  return result
}

countWords(string1)
countWords(string2)
countWords(string3)
countWords(string4)
countWords(string5)
countWords(string6)
countWords(string7)
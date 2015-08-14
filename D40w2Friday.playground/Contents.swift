// Coding Challenge: Stack

import Foundation

// I implemented this earlier in another App, with some help from a couple of stackoverflow posts to
// better understand generics after looking at the stack struct implementation in Apple's Swift iBook
// and finding out how you loose built-in support for things like sequencing.

extension Array {
  mutating func push(item: (T)) {
    self.append(item)
  }
  mutating func pop() -> T? {
    return self.isEmpty ? nil : self.removeLast()
  }
  func peekAt(index: Int) -> T? {
    return index < self.count ? self[index] : nil
  }
  func peek() -> T? {
    return peekAt(self.count-1)
  }
}

var stack = [1,2,3,4,5,6,7,8,9,10]

for _ in 0..<5 {
 stack.pop()
}
stack
for i in 0..<5 {
  stack.push(i)
}
stack
stack.peek()
stack.peekAt(4)
stack.peekAt(20)
for i in 0..<20 {
  stack.pop()
}
stack
stack.push(8)
stack.pop()
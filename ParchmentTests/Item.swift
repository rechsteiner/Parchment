import Foundation
@testable import Parchment

struct Item: PagingItem, Equatable, Comparable {
  let index: Int
  
  var identifier: Int {
    return index
  }
}

func ==(lhs: Item, rhs: Item) -> Bool {
  return lhs.index == rhs.index
}

func <(lhs: Item, rhs: Item) -> Bool {
  return lhs.index < rhs.index
}

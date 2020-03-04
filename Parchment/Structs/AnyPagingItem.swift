import Foundation

struct AnyPagingItem: PagingItem, Hashable, Comparable {
  let base: PagingItem
  
  init(base: PagingItem) {
    self.base = base
  }
  
  func hash(into hasher: inout Hasher) {
    hasher.combine(base.identifier)
  }
  
  static func < (lhs: AnyPagingItem, rhs: AnyPagingItem) -> Bool {
    return lhs.base.isBefore(item: rhs.base)
  }
  
  static func == (lhs: AnyPagingItem, rhs: AnyPagingItem) -> Bool {
    return lhs.base.isEqual(to: rhs.base)
  }
}

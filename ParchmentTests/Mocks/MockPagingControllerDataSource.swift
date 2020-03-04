import Foundation
@testable import Parchment

final class MockPagingControllerDataSource: PagingMenuDataSource {
  
  var maxIndexAfter: Int = Int.max
  var minIndexBefore: Int = Int.min
  
  func pagingItemBefore(pagingItem: PagingItem) -> PagingItem? {
    guard let item = pagingItem as? Item else { return nil }
    if item.index > minIndexBefore {
      return Item(index: item.index - 1)
    }
    return nil
  }
  
  func pagingItemAfter(pagingItem: PagingItem) -> PagingItem? {
    guard let item = pagingItem as? Item else { return nil }
    if item.index < maxIndexAfter {
      return Item(index: item.index + 1)
    }
    return nil
  }
  
}

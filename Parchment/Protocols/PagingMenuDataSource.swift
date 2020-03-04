import Foundation

public protocol PagingMenuDataSource: class {
  func pagingItemBefore(pagingItem: PagingItem) -> PagingItem?
  func pagingItemAfter(pagingItem: PagingItem) -> PagingItem?
}

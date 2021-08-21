import Foundation

public protocol PagingMenuDataSource: AnyObject {
  func pagingItemBefore(pagingItem: PagingItem) -> PagingItem?
  func pagingItemAfter(pagingItem: PagingItem) -> PagingItem?
}

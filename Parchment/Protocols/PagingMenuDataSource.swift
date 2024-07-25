import Foundation

public protocol PagingMenuDataSource: AnyObject {
    @MainActor
    func pagingItemBefore(pagingItem: PagingItem) -> PagingItem?
    @MainActor
    func pagingItemAfter(pagingItem: PagingItem) -> PagingItem?
}

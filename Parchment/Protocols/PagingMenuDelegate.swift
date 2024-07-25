import Foundation

public protocol PagingMenuDelegate: AnyObject {
    @MainActor
    func selectContent(pagingItem: PagingItem, direction: PagingDirection, animated: Bool)
    @MainActor
    func removeContent()
}

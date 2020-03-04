import Foundation

public protocol PagingMenuDelegate: class {
  func selectContent(pagingItem: PagingItem, direction: PagingDirection, animated: Bool)
  func removeContent()
}

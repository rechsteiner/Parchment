import Foundation
import UIKit

class PagingStaticDataSource: PagingViewControllerInfiniteDataSource {
  
  private(set) var items: [PagingItem] = []
  private let viewControllers: [UIViewController]
  
  init(viewControllers: [UIViewController]) {
    self.viewControllers = viewControllers
    self.reloadItems()
  }
  
  func pagingItem(at index: Int) -> PagingItem {
    return items[index]
  }
  
  func reloadItems() {
    self.items = viewControllers.enumerated().map {
      return PagingIndexItem(index: $0, title: $1.title ?? "")
    }
  }
  
  func pagingViewController(_: PagingViewController, viewControllerFor pagingItem: PagingItem) -> UIViewController {
    guard let index = items.firstIndex(where: { $0.isEqual(to: pagingItem) }) else {
      fatalError("pagingViewController:viewControllerFor: PagingItem does not exist")
    }
    return viewControllers[index]
  }
  
  func pagingViewController(_: PagingViewController, itemBefore pagingItem: PagingItem) -> PagingItem? {
    guard let index = items.firstIndex(where: { $0.isEqual(to: pagingItem) }) else { return nil }
    if index > 0 {
      return items[index - 1]
    }
    return nil
  }
  
  func pagingViewController(_: PagingViewController, itemAfter pagingItem: PagingItem) -> PagingItem? {
    guard let index = items.firstIndex(where: { $0.isEqual(to: pagingItem) }) else { return nil }
    if index < items.count - 1 {
      return items[index + 1]
    }
    return nil
  }
  
}

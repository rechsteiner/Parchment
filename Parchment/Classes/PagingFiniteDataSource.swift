import Foundation
import UIKit

class PagingFiniteDataSource: PagingViewControllerInfiniteDataSource {
  
  var items: [PagingItem] = []
  var viewControllerForIndex: ((Int) -> UIViewController?)?
  
  func pagingViewController(_: PagingViewController, viewControllerFor pagingItem: PagingItem) -> UIViewController {
    guard let index = items.firstIndex(where: { $0.isEqual(to: pagingItem) }) else {
      fatalError("pagingViewController:viewControllerFor: PagingItem does not exist")
    }
    guard let viewController = viewControllerForIndex?(index) else {
       fatalError("pagingViewController:viewControllerFor: No view controller exist for PagingItem")
    }
    
    return viewController
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

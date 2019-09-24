import Foundation
import UIKit

class IndexedPagingDataSource<T: PagingItem>:
  PagingViewControllerInfiniteDataSource where T: Hashable & Comparable {
  
  var items: [T] = []
  var viewControllerForIndex: ((Int) -> UIViewController?)?
  
  func pagingViewController<U>(
    _ pagingViewController: PagingViewController<U>,
    viewControllerForPagingItem item: U) -> UIViewController {
    guard let index = items.firstIndex(of: item as! T) else {
      fatalError("pagingViewController:viewControllerForPagingItem: PagingItem does not exist")
    }
    guard let viewController = viewControllerForIndex?(index) else {
       fatalError("pagingViewController:viewControllerForPagingItem: No view controller exist for PagingItem")
    }
    
    return viewController
  }
  
  func pagingViewController<U>(
    _ pagingViewController: PagingViewController<U>,
    pagingItemBeforePagingItem item: U) -> U? {
    guard let index = items.firstIndex(of: item as! T) else { return nil }
    if index > 0 {
      return items[index - 1] as? U
    }
    return nil
  }
  
  func pagingViewController<U>(
    _ pagingViewController: PagingViewController<U>,
    pagingItemAfterPagingItem item: U) -> U? {
    guard let index = items.firstIndex(of: item as! T) else { return nil }
    if index < items.count - 1 {
      return items[index + 1] as? U
    }
    return nil
  }
}

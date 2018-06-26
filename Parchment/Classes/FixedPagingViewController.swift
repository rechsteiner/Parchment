import UIKit

/// A subclass of `PagingViewController` that can be used when you
/// have a fixed array of view controllers. It will setup a data
/// source for all the view controllers and display the menu items
/// with the view controllers title.
///
/// Using this class requires you to allocate all the view controllers
/// up-front, which in some cases might be to expensive. If that is
/// the case, take a look at `PagingViewController` on how to create
/// your own implementation that matches your needs.
open class FixedPagingViewController: PagingViewController<PagingIndexItem> {
  
  /// An array of the content view controllers. If you need to call
  /// `select(pagingItem:)` you can use the index of these view
  /// controller to select the item you want.
  public let viewControllers: [UIViewController]
  
  /// Creates an instance of `FixedPagingViewController`. By default,
  /// it will select the first view controller in the array. You can
  /// call `select(pagingItem:)` if you need select something else.
  ///
  /// - Parameter viewControllers: An array of view controllers
  public init(viewControllers: [UIViewController]) {
    self.viewControllers = viewControllers
    super.init()
    dataSource = self
  }

  required public init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }  
}

extension FixedPagingViewController: PagingViewControllerDataSource {
  
  public func numberOfViewControllers<T>(in: PagingViewController<T>) -> Int {
    return viewControllers.count
  }
  
  public func pagingViewController<T>(_ pagingViewController: PagingViewController<T>, pagingItemForIndex index: Int) -> T {
    return PagingIndexItem(index: index, title: viewControllers[index].title ?? "") as! T
  }
  
  public func pagingViewController<T>(_ pagingViewController: PagingViewController<T>, viewControllerForIndex index: Int) -> UIViewController {
    return viewControllers[index]
  }
  
}

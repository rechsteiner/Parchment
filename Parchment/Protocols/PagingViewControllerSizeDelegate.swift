import UIKit

public protocol PagingViewControllerSizeDelegate: class {
  
  /// Manually control the width for a given `PagingItem`. Parchment
  /// does not support self-sizing cells, so you have to use this if
  /// you have a cell that you want to size based on its content.
  ///
  /// - Parameter pagingViewController: The `PagingViewController`
  /// instance
  /// - Parameter pagingItem: The `PagingItem` instance
  /// - Parameter isSelected: A boolean that indicates whether the
  /// given `PagingItem` is selected
  /// - Returns: The width for the `PagingItem`
  func pagingViewController(
    _: PagingViewController,
    widthForPagingItem pagingItem: PagingItem,
    isSelected: Bool) -> CGFloat
}

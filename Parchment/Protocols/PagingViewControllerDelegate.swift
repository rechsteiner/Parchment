import Foundation
import UIKit

/// The `PagingViewControllerDelegate` protocol defines methods that
/// can used to determine when the user navigates between view
/// controllers, or to define the width of a given `PagingItem`.
public protocol PagingViewControllerDelegate: class {
  
  /// Called whenever a scroll transition is in progress.
  ///
  /// - Parameter currentPagingItem: The currently selected `PagingItem`
  /// - Parameter upcomingPagingItem: The `PagingItem` being scrolled to
  /// - Parameter startingViewController: The view controller for the
  /// current paging item
  /// - Parameter destinationViewController: The view controller for
  /// the upcoming paging item
  /// - Parameter progress: The progress of the scroll transition
  func pagingViewController<T>(
    _ pagingViewController: PagingViewController<T>,
    isScrollingFromItem currentPagingItem: T,
    toItem upcomingPagingItem: T?,
    startingViewController: UIViewController,
    destinationViewController: UIViewController?,
    progress: CGFloat)
  
  /// Called whenever a scroll transition is about to start.
  ///
  /// - Parameter pagingItem: The `PagingItem` being scrolled to
  /// - Parameter startingViewController: The view controller for the
  /// current paging item
  /// - Parameter destinationViewController: The view controller for
  /// the upcoming paging item
  func pagingViewController<T>(
    _ pagingViewController: PagingViewController<T>,
    willScrollToItem pagingItem: T,
    startingViewController: UIViewController,
    destinationViewController: UIViewController)
  
  /// Called whenever a scroll transition completes or is cancelled.
  ///
  /// - Parameter pagingItem: The `PagingItem` that was scroll to
  /// - Parameter startingViewController: The view controller for the
  /// current paging item
  /// - Parameter destinationViewController: The view controller for
  /// the upcoming paging item
  /// - Parameter transitionSuccessful: Boolean that indicates whether
  /// the transition to the paging item was successful or not
  func pagingViewController<T>(
    _ pagingViewController: PagingViewController<T>,
    didScrollToItem pagingItem: T,
    startingViewController: UIViewController?,
    destinationViewController: UIViewController,
    transitionSuccessful: Bool)
  
  /// Manually control the width for a given `PagingItem`. Parchment
  /// does not support self-sizing cells, so you have to use this if
  /// you have a cell that you want to size based on its content.
  ///
  /// - Parameter pagingViewController: The `PagingViewController`
  /// instance
  /// - Parameter pagingItem: The `PagingItem` instance
  /// - Parameter isSelected: A boolean that indicates whether the
  /// given `PagingItem` is selected
  /// - Returns: The width for the `PagingItem` or nil
  func pagingViewController<T>(
    _ pagingViewController: PagingViewController<T>,
    widthForPagingItem pagingItem: T,
    isSelected: Bool) -> CGFloat?
}

public extension PagingViewControllerDelegate {

  func pagingViewController<T>(
    _ pagingViewController: PagingViewController<T>,
    isScrollingFromItem currentPagingItem: T,
    toItem upcomingPagingItem: T?,
    startingViewController: UIViewController,
    destinationViewController: UIViewController?,
    progress: CGFloat) {
    return
  }
  
  func pagingViewController<T>(
    _ pagingViewController: PagingViewController<T>,
    willScrollToItem pagingItem: T,
    startingViewController: UIViewController,
    destinationViewController: UIViewController) {
    return
  }
  
  func pagingViewController<T>(
    _ pagingViewController: PagingViewController<T>,
    didScrollToItem pagingItem: T,
    startingViewController: UIViewController?,
    destinationViewController: UIViewController,
    transitionSuccessful: Bool) {
    return
  }
  
  func pagingViewController<T>(
    _ pagingViewController: PagingViewController<T>,
    widthForPagingItem pagingItem: T,
    isSelected: Bool) -> CGFloat? {
    return nil
  }
}

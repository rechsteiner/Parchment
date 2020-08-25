import Foundation
import UIKit

/// The `PagingViewControllerDelegate` protocol defines methods that
/// can used to determine when the user navigates between view
/// controllers.
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
  func pagingViewController(
    _: PagingViewController,
    isScrollingFromItem currentPagingItem: PagingItem,
    toItem upcomingPagingItem: PagingItem?,
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
  func pagingViewController(
    _: PagingViewController,
    willScrollToItem pagingItem: PagingItem,
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
  func pagingViewController(
    _ pagingViewController: PagingViewController,
    didScrollToItem pagingItem: PagingItem,
    startingViewController: UIViewController?,
    destinationViewController: UIViewController,
    transitionSuccessful: Bool)
  
  /// Called when paging cell is selected in the menu.
  ///
  /// - Parameter pagingViewController: The `PagingViewController` instance
  /// - Parameter pagingItem: The item that was selected.
  func pagingViewController(
    _ pagingViewController: PagingViewController,
    didSelectItem pagingItem: PagingItem)
    
  /// Called when paging cell is selected
  /// - Parameter pagingViewController: The `PagingViewController` instance
  /// - Parameter index: The index for selected paging cell
  /// - Parameter selectedItem: The selected item
  /// - Parameter currenItem: The current item
  func pagingViewController(
        _ pagingViewController: PagingViewController,
        didSelectPagingCellAt index: Int,
        selectedItem: PagingItem,
        currentItem: PagingItem)
}

public extension PagingViewControllerDelegate {

  func pagingViewController(
    _: PagingViewController,
    isScrollingFromItem currentPagingItem: PagingItem,
    toItem upcomingPagingItem: PagingItem?,
    startingViewController: UIViewController,
    destinationViewController: UIViewController?,
    progress: CGFloat) {
    return
  }
  
  func pagingViewController(
    _ pagingViewController: PagingViewController,
    willScrollToItem pagingItem: PagingItem,
    startingViewController: UIViewController,
    destinationViewController: UIViewController) {
    return
  }
  
  func pagingViewController(
    _ pagingViewController: PagingViewController,
    didScrollToItem pagingItem: PagingItem,
    startingViewController: UIViewController?,
    destinationViewController: UIViewController,
    transitionSuccessful: Bool) {
    return
  }
  
  func pagingViewController(
    _ pagingViewController: PagingViewController,
    didSelectItem pagingItem: PagingItem) {
    return
  }
    
  func pagingViewController(
    _ pagingViewController: PagingViewController,
    didSelectPagingCellAt index: Int,
    selectedItem: PagingItem,
    currentItem: PagingItem){
    return
  }
}

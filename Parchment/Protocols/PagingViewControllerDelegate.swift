import Foundation
import UIKit

/// The `PagingViewControllerDelegate` protocol defines methods that
/// can used to determine when the user navigates between view
/// controllers.
public protocol PagingViewControllerDelegate: AnyObject {
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
        progress: CGFloat
    )

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
        destinationViewController: UIViewController
    )

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
        transitionSuccessful: Bool
    )

    /// Called when paging cell is selected in the menu.
    ///
    /// - Parameter pagingViewController: The `PagingViewController` instance
    /// - Parameter pagingItem: The item that was selected.
    /// - Parameter index: The index for selected paging cell
    /// - Parameter currentItem: The current item
    func pagingViewController(
      _ pagingViewController: PagingViewController,
      didSelectItem pagingItem: PagingItem,
      didSelectPagingCellAt index: Int,
      currentItem: PagingItem)
}

public extension PagingViewControllerDelegate {
    func pagingViewController(
        _: PagingViewController,
        isScrollingFromItem _: PagingItem,
        toItem _: PagingItem?,
        startingViewController _: UIViewController,
        destinationViewController _: UIViewController?,
        progress _: CGFloat
    ) {
        return
    }

    func pagingViewController(
        _: PagingViewController,
        willScrollToItem _: PagingItem,
        startingViewController _: UIViewController,
        destinationViewController _: UIViewController
    ) {
        return
    }

    func pagingViewController(
        _: PagingViewController,
        didScrollToItem _: PagingItem,
        startingViewController _: UIViewController?,
        destinationViewController _: UIViewController,
        transitionSuccessful _: Bool
    ) {
        return
    }

    func pagingViewController(
        _ pagingViewController: PagingViewController,
        didSelectItem pagingItem: PagingItem,
        didSelectPagingCellAt index: Int,
        currentItem: PagingItem) {
      return
    }
}

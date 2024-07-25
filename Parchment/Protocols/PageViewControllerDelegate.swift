import UIKit

/// The `PageViewControllerDelegate` protocol defines methods that
/// can used to determine when the user navigates between view
/// controllers.
public protocol PageViewControllerDelegate: AnyObject {
    /// Called whenever the user is about to start scrolling to a view
    /// controller.
    ///
    /// - Parameters:
    ///   - pageViewController: The `PageViewController` instance.
    ///   - startingViewController: The view controller the user is
    ///   scrolling from.
    ///   - destinationViewController: The view controller the user is
    ///   scrolling towards.
    @MainActor
    func pageViewController(
        _ pageViewController: PageViewController,
        willStartScrollingFrom startingViewController: UIViewController,
        destinationViewController: UIViewController
    )

    /// Called whenever a scroll transition is in progress.
    ///
    /// - Parameters:
    ///   - pageViewController: The `PageViewController` instance.
    ///   - startingViewController: The view controller the user is
    ///   scrolling from.
    ///   - destinationViewController: The view controller the user is
    ///   scrolling towards. Will be nil if the user is scrolling
    ///   towards one of the edges.
    ///   - progress: The progress of the scroll transition. Between 0
    ///   and 1.
    @MainActor
    func pageViewController(
        _ pageViewController: PageViewController,
        isScrollingFrom startingViewController: UIViewController,
        destinationViewController: UIViewController?,
        progress: CGFloat
    )

    /// Called when the user finished scrolling to a new view.
    ///
    /// - Parameters:
    ///   - pageViewController: The `PageViewController` instance.
    ///   - startingViewController: The view controller the user is
    ///   scrolling from.
    ///   - destinationViewController: The view controller the user is
    ///   scrolling towards.
    ///   - transitionSuccessful: A boolean indicating whether the
    ///   transition completed, or was cancelled by the user.
    @MainActor
    func pageViewController(
        _ pageViewController: PageViewController,
        didFinishScrollingFrom startingViewController: UIViewController,
        destinationViewController: UIViewController,
        transitionSuccessful: Bool
    )
}

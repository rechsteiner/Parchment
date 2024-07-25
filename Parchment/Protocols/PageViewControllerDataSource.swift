import UIKit

/// The `PageViewControllerDataSource` protocol is used to provide
/// the view controller you want to display.
public protocol PageViewControllerDataSource: AnyObject {
    /// Return the view controller before a given view controller.
    ///
    /// - Parameters:
    ///   - pageViewController: The `PageViewController` instance.
    ///   - viewController: The current view controller.
    @MainActor
    func pageViewController(
        _ pageViewController: PageViewController,
        viewControllerBeforeViewController viewController: UIViewController
    ) -> UIViewController?

    /// Return the view controller after a given view controller.
    ///
    /// - Parameters:
    ///   - pageViewController: The `PageViewController` instance.
    ///   - viewController: The current view controller.
    @MainActor
    func pageViewController(
        _ pageViewController: PageViewController,
        viewControllerAfterViewController viewController: UIViewController
    ) -> UIViewController?
}

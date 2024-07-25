import UIKit

@MainActor
protocol PageViewManagerDelegate: AnyObject {
    func scrollForward()
    func scrollReverse()
    func layoutViews(for viewControllers: [UIViewController], keepContentOffset: Bool)
    func addViewController(_ viewController: UIViewController)
    func removeViewController(_ viewController: UIViewController)
    func beginAppearanceTransition(
        isAppearing: Bool,
        viewController: UIViewController,
        animated: Bool
    )
    func endAppearanceTransition(viewController: UIViewController)
    func willScroll(
        from selectedViewController: UIViewController,
        to destinationViewController: UIViewController
    )
    func isScrolling(
        from selectedViewController: UIViewController,
        to destinationViewController: UIViewController?,
        progress: CGFloat
    )
    func didFinishScrolling(
        from selectedViewController: UIViewController,
        to destinationViewController: UIViewController,
        transitionSuccessful: Bool
    )
}

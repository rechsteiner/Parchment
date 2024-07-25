import UIKit

@MainActor
protocol PageViewManagerDataSource: AnyObject {
    func viewControllerBefore(_ viewController: UIViewController) -> UIViewController?
    func viewControllerAfter(_ viewController: UIViewController) -> UIViewController?
}

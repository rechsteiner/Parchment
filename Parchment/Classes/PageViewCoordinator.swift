import UIKit

@available(iOS 14.0, *)
@MainActor
final class PageViewCoordinator: PagingViewControllerDataSource, PagingViewControllerDelegate {
    final class WeakReference<T: AnyObject> {
        weak var value: T?

        init(value: T) {
            self.value = value
        }
    }

    var parent: PagingControllerRepresentableView
    var controllers: [Int: WeakReference<UIViewController>] = [:]

    init(_ pagingController: PagingControllerRepresentableView) {
        parent = pagingController
    }

    func numberOfViewControllers(in _: PagingViewController) -> Int {
        return parent.items.count
    }

    func pagingViewController(
        _: PagingViewController,
        viewControllerAt index: Int
    ) -> UIViewController {
        let item = parent.items[index]
        let hostingViewController: UIViewController

        if let controller = controllers[item.identifier]?.value {
            hostingViewController = controller
        } else {
            let controller = hostingController(for: item)
            controllers[item.identifier] = WeakReference(value: controller)
            hostingViewController = controller
        }

        let backgroundColor = parent.options.pagingContentBackgroundColor
        hostingViewController.view.backgroundColor = backgroundColor
        return hostingViewController
    }

    func pagingViewController(
        _: PagingViewController,
        pagingItemAt index: Int
    ) -> PagingItem {
        parent.items[index]
    }

    func pagingViewController(
        _ controller: PagingViewController,
        didScrollToItem pagingItem: PagingItem,
        startingViewController _: UIViewController?,
        destinationViewController _: UIViewController,
        transitionSuccessful _: Bool
    ) {
        if let item = pagingItem as? PageItem,
           let index = parent.items.firstIndex(where: { $0.isEqual(to: item) }) {
            parent.selectedIndex = index
        }

        parent.onDidScroll?(pagingItem)
    }

    func pagingViewController(
        _: PagingViewController,
        willScrollToItem pagingItem: PagingItem,
        startingViewController _: UIViewController,
        destinationViewController _: UIViewController
    ) {
        parent.onWillScroll?(pagingItem)
    }

    func pagingViewController(
        _: PagingViewController,
        didSelectItem pagingItem: PagingItem
    ) {
        parent.onDidSelect?(pagingItem)
    }

    private func hostingController(for pagingItem: PagingItem) -> UIViewController {
        var hostingViewController: UIViewController
        if let item = pagingItem as? PageItem {
            hostingViewController = item.page.content()
        } else {
            assertionFailure("""
            PageItem is required when using the SwiftUI wrappers.
            Please report if you somehow ended up here.
            """)
            hostingViewController = UIViewController()
        }
        return hostingViewController
    }
}

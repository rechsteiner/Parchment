import UIKit
import Parchment

final class InfiniteLoopingViewController: UIViewController {
    let items: [String] = [
        "Sunday",
        "Monday",
        "Tuesday",
        "Wednesday",
        "Thursday",
        "Friday",
        "Saturday"
    ]

    override func viewDidLoad() {
        super.viewDidLoad()

        let pagingViewController = PagingViewController()
        pagingViewController.infiniteDataSource = self

        // Make sure you add the PagingViewController as a child view
        // controller and constrain it to the edges of the view.
        addChild(pagingViewController)
        view.addSubview(pagingViewController.view)
        view.constrainToEdges(pagingViewController.view)
        pagingViewController.didMove(toParent: self)
        pagingViewController.select(pagingItem: PagingIndexItem(index: 0, title: items.first!))
    }
}

/// Implements the `PagingViewControllerInfiniteDataSource` and wraps
/// the items whenever we reaches the end or beginning of the items.
extension InfiniteLoopingViewController: PagingViewControllerInfiniteDataSource {
    func pagingViewController(_: PagingViewController, itemAfter pagingItem: PagingItem) -> PagingItem? {
        let nextIndex = (pagingItem as! PagingIndexItem).index + 1
        if items.count <= nextIndex { // Loop if out of range
            return PagingIndexItem(index: 0, title: items.first!)
        }
        return PagingIndexItem(index: nextIndex, title: items[nextIndex])
    }

    func pagingViewController(_: PagingViewController, itemBefore pagingItem: PagingItem) -> PagingItem? {
        let nextIndex = (pagingItem as! PagingIndexItem).index - 1
        if nextIndex < 0 { // Loop if out of range
            return PagingIndexItem(index: items.count - 1, title: items.last!)
        }
        return PagingIndexItem(index: nextIndex, title: items[nextIndex])
    }

    func pagingViewController(_: PagingViewController, viewControllerFor pagingItem: PagingItem) -> UIViewController {
        ContentViewController(title: (pagingItem as! PagingIndexItem).title)
    }
}

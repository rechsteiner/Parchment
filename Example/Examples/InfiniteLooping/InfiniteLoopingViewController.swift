import UIKit
import Parchment

final class InfiniteLoopingViewController: UIViewController {
    let items: [PagingIndexItem] = [
        "Sunday",
        "Monday",
        "Tuesday",
        "Wednesday",
        "Thursday",
        "Friday",
        "Saturday"
    ].enumerated().map(PagingIndexItem.init(index:title:))

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
        pagingViewController.select(pagingItem: items.first!)
    }
}

/// Implements the `PagingViewControllerInfiniteDataSource` and wraps
/// the items whenever we reaches the end or beginning of the items.
extension InfiniteLoopingViewController: PagingViewControllerInfiniteDataSource {
    func pagingViewController(_: PagingViewController, itemAfter pagingItem: PagingItem) -> PagingItem? {
        let nextIndex = (pagingItem as! PagingIndexItem).index + 1
        if nextIndex > items.last!.index { // Loop if out of range
            return items.first!
        }
        return items[nextIndex]
    }

    func pagingViewController(_: PagingViewController, itemBefore pagingItem: PagingItem) -> PagingItem? {
        let nextIndex = (pagingItem as! PagingIndexItem).index - 1
        if nextIndex < items.first!.index { // Loop if out of range
            return items.last!
        }
        return items[nextIndex]
    }

    func pagingViewController(_: PagingViewController, viewControllerFor pagingItem: PagingItem) -> UIViewController {
        let item = pagingItem as! PagingIndexItem
        return ContentViewController(title: item.title)
    }
}

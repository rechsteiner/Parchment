import Foundation
import UIKit
import Testing
@testable import Parchment

struct PagingViewControllerDelegateTests {
    @Test func didSelectItem() async {
        await confirmation { didSelect in
            if #available(iOS 13.0, *) {
                await MainActor.run {
                    let viewController0 = UIViewController()
                    let viewController1 = UIViewController()
                    let pagingViewController = PagingViewController(viewControllers: [
                        viewController0,
                        viewController1
                    ])

                    let delegate = Delegate()
                    let window = UIWindow(frame: UIScreen.main.bounds)
                    window.rootViewController = pagingViewController
                    window.makeKeyAndVisible()
                    pagingViewController.view.layoutIfNeeded()
                    pagingViewController.delegate = delegate

                    delegate.didSelectItem = { item in
                        let upcomingItem = pagingViewController.state.upcomingPagingItem as? PagingIndexItem
                        let item = item as! PagingIndexItem
                        #expect(item.index == 1)
                        #expect(upcomingItem == item)
                        didSelect()
                    }

                    let indexPath = IndexPath(item: 1, section: 0)
                    pagingViewController.collectionView.delegate?.collectionView?(
                        pagingViewController.collectionView,
                        didSelectItemAt: indexPath
                    )
                }
            }
        }
    }

    @Test func didScrollToItem() async {
        await confirmation { didSelect in
            if #available(iOS 13.0, *) {
                await MainActor.run {
                    let viewController0 = UIViewController()
                    let viewController1 = UIViewController()
                    let pagingViewController = PagingViewController(viewControllers: [
                        viewController0,
                        viewController1
                    ])

                    let delegate = Delegate()
                    let window = UIWindow(frame: UIScreen.main.bounds)
                    window.rootViewController = pagingViewController
                    window.makeKeyAndVisible()
                    pagingViewController.view.layoutIfNeeded()
                    pagingViewController.delegate = delegate

                    delegate.didSelectItem = { item in
                        let upcomingItem = pagingViewController.state.upcomingPagingItem as? PagingIndexItem
                        let item = item as! PagingIndexItem
                        #expect(item.index == 1)
                        #expect(upcomingItem == item)
                        didSelect()
                    }

                    let indexPath = IndexPath(item: 1, section: 0)
                    pagingViewController.collectionView.delegate?.collectionView?(
                        pagingViewController.collectionView,
                        didSelectItemAt: indexPath
                    )
                }
            }
        }
    }
}

private final class Delegate: PagingViewControllerDelegate {
    var didSelectItem: ((PagingItem) -> Void)?

    func pagingViewController(_ pagingViewController: PagingViewController, didSelectItem pagingItem: PagingItem) {
        didSelectItem?(pagingItem)
    }
}

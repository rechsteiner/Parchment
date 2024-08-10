import Foundation
@testable import Parchment
import UIKit
import XCTest

@MainActor
final class PagingViewControllerDelegateTests: XCTestCase {
    func testDidSelectItem() {
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

        let expectation = XCTestExpectation()

        delegate.didSelectItem = { item in
            let upcomingItem = pagingViewController.state.upcomingPagingItem as? PagingIndexItem
            let item = item as! PagingIndexItem
            XCTAssertEqual(item.index, 1)
            XCTAssertEqual(upcomingItem, item)
            expectation.fulfill()
        }

        let indexPath = IndexPath(item: 1, section: 0)
        pagingViewController.collectionView.delegate?.collectionView?(
            pagingViewController.collectionView,
            didSelectItemAt: indexPath
        )

        wait(for: [expectation], timeout: 1)
    }

    func testDidScrollToItem() {
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

        let expectation = XCTestExpectation()

        delegate.didSelectItem = { item in
            let upcomingItem = pagingViewController.state.upcomingPagingItem as? PagingIndexItem
            let item = item as! PagingIndexItem
            XCTAssertEqual(item.index, 1)
            XCTAssertEqual(upcomingItem, item)
            expectation.fulfill()
        }

        let indexPath = IndexPath(item: 1, section: 0)
        pagingViewController.collectionView.delegate?.collectionView?(
            pagingViewController.collectionView,
            didSelectItemAt: indexPath
        )

        wait(for: [expectation], timeout: 1)
    }
}

private final class Delegate: PagingViewControllerDelegate {
    var didSelectItem: ((PagingItem) -> Void)?

    func pagingViewController(_ pagingViewController: PagingViewController, didSelectItem pagingItem: PagingItem) {
        didSelectItem?(pagingItem)
    }
}

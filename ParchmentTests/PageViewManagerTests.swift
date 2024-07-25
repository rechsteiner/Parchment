import Foundation
@testable import Parchment
import XCTest

@MainActor
final class PageViewManagerTests: XCTestCase {
    var dataSource: MockPageViewManagerDataSource!
    var delegate: MockPageViewManagerDelegate!
    var manager: PageViewManager!

    override func setUp() {
        dataSource = MockPageViewManagerDataSource()
        delegate = MockPageViewManagerDelegate()
        manager = PageViewManager()
        manager.dataSource = dataSource
        manager.delegate = delegate
    }

    // MARK: - Selection

    func testSelectWhenEmpty() {
        let previousVc = UIViewController()
        let selectedVc = UIViewController()
        let nextVc = UIViewController()

        dataSource.viewControllerBefore = { _ in previousVc }
        dataSource.viewControllerAfter = { _ in nextVc }

        manager.viewDidAppear(false)
        manager.select(viewController: selectedVc, animated: true)

        XCTAssertEqual(delegate.calls, [
            .beginAppearanceTransition(true, selectedVc, true),
            .addViewController(previousVc),
            .addViewController(selectedVc),
            .addViewController(nextVc),
            .layoutViews([previousVc, selectedVc, nextVc]),
            .endAppearanceTransition(selectedVc),
        ])
    }

    func testSelectAllNewViewControllersForwardAnimated() {
        let oldPreviousVc = UIViewController()
        let oldSelectedVc = UIViewController()
        let oldNextVc = UIViewController()

        let newPreviousVc = UIViewController()
        let newSelectedVc = UIViewController()
        let newNextVc = UIViewController()

        dataSource.viewControllerBefore = { _ in oldPreviousVc }
        dataSource.viewControllerAfter = { _ in oldNextVc }
        manager.viewDidAppear(false)
        manager.select(viewController: oldSelectedVc)

        delegate.calls = []

        dataSource.viewControllerBefore = { _ in newPreviousVc }
        dataSource.viewControllerAfter = { _ in newNextVc }
        manager.select(viewController: newSelectedVc, animated: true)
        manager.didScroll(progress: 0.1)
        manager.didScroll(progress: 1)

        XCTAssertEqual(delegate.calls, [
            // Add the new upcoming view controller
            .removeViewController(oldNextVc),
            .addViewController(newSelectedVc),
            .layoutViews([oldPreviousVc, oldSelectedVc, newSelectedVc]),

            // Animate the scroll towards the new view
            .scrollForward,
            .isScrolling(from: oldSelectedVc, to: newSelectedVc, progress: 0.1),
            .willScroll(from: oldSelectedVc, to: newSelectedVc),
            .beginAppearanceTransition(true, newSelectedVc, true),
            .beginAppearanceTransition(false, oldSelectedVc, true),

            // Replace the previously selected with the new previous view
            // once the transition completes. Should be left with all the
            // new view controllers.
            .isScrolling(from: oldSelectedVc, to: newSelectedVc, progress: 1),
            .didFinishScrolling(from: oldSelectedVc, to: newSelectedVc, success: true),
            .removeViewController(oldPreviousVc),
            .addViewController(newNextVc),
            .removeViewController(oldSelectedVc),
            .addViewController(newPreviousVc),
            .layoutViews([newPreviousVc, newSelectedVc, newNextVc]),

            // End the appearance transitions after doing layout.
            .endAppearanceTransition(oldSelectedVc),
            .endAppearanceTransition(newSelectedVc),
        ])
    }

    func testCancelSelectAllNewViewControllersForwardAnimated() {
        let oldPreviousVc = UIViewController()
        let oldSelectedVc = UIViewController()
        let oldNextVc = UIViewController()

        let newPreviousVc = UIViewController()
        let newSelectedVc = UIViewController()
        let newNextVc = UIViewController()

        dataSource.viewControllerBefore = { _ in oldPreviousVc }
        dataSource.viewControllerAfter = { _ in oldNextVc }
        manager.viewDidAppear(false)
        manager.select(viewController: oldSelectedVc)

        dataSource.viewControllerBefore = { _ in newPreviousVc }
        dataSource.viewControllerAfter = { _ in newNextVc }
        manager.select(viewController: newSelectedVc, animated: true)
        manager.didScroll(progress: 0.1)

        delegate.calls = []

        dataSource.viewControllerAfter = { _ in oldNextVc }
        manager.didScroll(progress: 0.0)

        XCTAssertEqual(delegate.calls, [
            .isScrolling(from: oldSelectedVc, to: newSelectedVc, progress: 0.0),
            .beginAppearanceTransition(true, oldSelectedVc, true),
            .beginAppearanceTransition(false, newSelectedVc, true),

            // Expect that we remove the view controller that was selected
            // and replace it with the "old next" view controller.
            .removeViewController(newSelectedVc),
            .addViewController(oldNextVc),
            .layoutViews([oldPreviousVc, oldSelectedVc, oldNextVc]),

            .endAppearanceTransition(oldSelectedVc),
            .endAppearanceTransition(newSelectedVc),
            .didFinishScrolling(from: oldSelectedVc, to: newSelectedVc, success: false),
        ])
    }

    func testSelectAllNewViewControllersReverseAnimated() {
        let oldPreviousVc = UIViewController()
        let oldSelectedVc = UIViewController()
        let oldNextVc = UIViewController()

        let newPreviousVc = UIViewController()
        let newSelectedVc = UIViewController()
        let newNextVc = UIViewController()

        dataSource.viewControllerBefore = { _ in oldPreviousVc }
        dataSource.viewControllerAfter = { _ in oldNextVc }
        manager.viewDidAppear(false)
        manager.select(viewController: oldSelectedVc)

        delegate.calls = []

        dataSource.viewControllerBefore = { _ in newPreviousVc }
        dataSource.viewControllerAfter = { _ in newNextVc }
        manager.select(viewController: newSelectedVc, direction: .reverse, animated: true)
        manager.didScroll(progress: -0.1)
        manager.didScroll(progress: -1)

        XCTAssertEqual(delegate.calls, [
            // Add the new upcoming view controller
            .removeViewController(oldPreviousVc),
            .addViewController(newSelectedVc),
            .layoutViews([newSelectedVc, oldSelectedVc, oldNextVc]),

            // Animate the scroll towards the new view
            .scrollReverse,
            .isScrolling(from: oldSelectedVc, to: newSelectedVc, progress: -0.1),
            .willScroll(from: oldSelectedVc, to: newSelectedVc),
            .beginAppearanceTransition(true, newSelectedVc, true),
            .beginAppearanceTransition(false, oldSelectedVc, true),

            // Replace the previously selected with the new next view
            // once the transition completes. Should be left with all the
            // new view controllers.
            .isScrolling(from: oldSelectedVc, to: newSelectedVc, progress: -1),
            .didFinishScrolling(from: oldSelectedVc, to: newSelectedVc, success: true),
            .removeViewController(oldNextVc),
            .addViewController(newPreviousVc),
            .removeViewController(oldSelectedVc),
            .addViewController(newNextVc),
            .layoutViews([newPreviousVc, newSelectedVc, newNextVc]),

            // End the appearance transitions after doing layout.
            .endAppearanceTransition(oldSelectedVc),
            .endAppearanceTransition(newSelectedVc),
        ])
    }

    func testCancelSelectAllNewViewControllersReverseAnimated() {
        let oldPreviousVc = UIViewController()
        let oldSelectedVc = UIViewController()
        let oldNextVc = UIViewController()

        let newPreviousVc = UIViewController()
        let newSelectedVc = UIViewController()
        let newNextVc = UIViewController()

        dataSource.viewControllerBefore = { _ in oldPreviousVc }
        dataSource.viewControllerAfter = { _ in oldNextVc }
        manager.viewDidAppear(false)
        manager.select(viewController: oldSelectedVc)

        dataSource.viewControllerBefore = { _ in newPreviousVc }
        dataSource.viewControllerAfter = { _ in newNextVc }
        manager.select(viewController: newSelectedVc, direction: .reverse, animated: true)
        manager.didScroll(progress: -0.1)

        delegate.calls = []

        dataSource.viewControllerBefore = { _ in oldPreviousVc }
        manager.didScroll(progress: 0.0)

        XCTAssertEqual(delegate.calls, [
            .isScrolling(from: oldSelectedVc, to: newSelectedVc, progress: 0.0),
            .beginAppearanceTransition(true, oldSelectedVc, true),
            .beginAppearanceTransition(false, newSelectedVc, true),

            // Expect that we remove the view controller that was selected
            // and replace it with the "old previous" view controller.
            .removeViewController(newSelectedVc),
            .addViewController(oldPreviousVc),
            .layoutViews([oldPreviousVc, oldSelectedVc, oldNextVc]),

            .endAppearanceTransition(oldSelectedVc),
            .endAppearanceTransition(newSelectedVc),
            .didFinishScrolling(from: oldSelectedVc, to: newSelectedVc, success: false),
        ])
    }

    func testSelectAllNewViewControllersWithoutAnimation() {
        let oldPreviousVc = UIViewController()
        let oldSelectedVc = UIViewController()
        let oldNextVc = UIViewController()

        let newPreviousVc = UIViewController()
        let newSelectedVc = UIViewController()
        let newNextVc = UIViewController()

        dataSource.viewControllerBefore = { _ in oldPreviousVc }
        dataSource.viewControllerAfter = { _ in oldNextVc }
        manager.viewDidAppear(false)
        manager.select(viewController: oldSelectedVc)

        delegate.calls = []

        dataSource.viewControllerBefore = { _ in newPreviousVc }
        dataSource.viewControllerAfter = { _ in newNextVc }
        manager.select(viewController: newSelectedVc, animated: false)

        XCTAssertEqual(delegate.calls, [
            // Start the appearance transitions.
            .beginAppearanceTransition(false, oldSelectedVc, false),
            .beginAppearanceTransition(true, newSelectedVc, false),

            // Remove old view controllers and add new ones.
            .removeViewController(oldPreviousVc),
            .removeViewController(oldSelectedVc),
            .removeViewController(oldNextVc),
            .addViewController(newPreviousVc),
            .addViewController(newSelectedVc),
            .addViewController(newNextVc),
            .layoutViews([newPreviousVc, newSelectedVc, newNextVc]),

            // End the appearance transitions after doing layout.
            .endAppearanceTransition(oldSelectedVc),
            .endAppearanceTransition(newSelectedVc),
        ])
    }

    func testSelectShiftOneForwardWithoutAnimation() {
        let viewController0 = UIViewController()
        let viewController1 = UIViewController()
        let viewController2 = UIViewController()
        let viewController3 = UIViewController()

        dataSource.viewControllerBefore = { _ in viewController0 }
        dataSource.viewControllerAfter = { _ in viewController2 }
        manager.viewDidAppear(false)
        manager.select(viewController: viewController1)

        delegate.calls = []

        dataSource.viewControllerBefore = { _ in viewController1 }
        dataSource.viewControllerAfter = { _ in viewController3 }
        manager.select(viewController: viewController2, animated: false)

        XCTAssertEqual(delegate.calls, [
            // Start the appearance transitions.
            .beginAppearanceTransition(false, viewController1, false),
            .beginAppearanceTransition(true, viewController2, false),

            // Remove the old view controller and add the new one.
            .removeViewController(viewController0),
            .addViewController(viewController3),
            .layoutViews([viewController1, viewController2, viewController3]),

            // End the appearance transitions after doing layout.
            .endAppearanceTransition(viewController1),
            .endAppearanceTransition(viewController2),
        ])
    }

    func testSelectShiftOneReverseWithoutAnimation() {
        let viewController0 = UIViewController()
        let viewController1 = UIViewController()
        let viewController2 = UIViewController()
        let viewController3 = UIViewController()

        dataSource.viewControllerBefore = { _ in viewController1 }
        dataSource.viewControllerAfter = { _ in viewController3 }
        manager.viewDidAppear(false)
        manager.select(viewController: viewController2)

        delegate.calls = []

        dataSource.viewControllerBefore = { _ in viewController0 }
        dataSource.viewControllerAfter = { _ in viewController2 }
        manager.select(viewController: viewController1, animated: false)

        XCTAssertEqual(delegate.calls, [
            // Start the appearance transitions.
            .beginAppearanceTransition(false, viewController2, false),
            .beginAppearanceTransition(true, viewController1, false),

            // Remove the old view controller and add the new one.
            .removeViewController(viewController3),
            .addViewController(viewController0),
            .layoutViews([viewController0, viewController1, viewController2]),

            // End the appearance transitions after doing layout.
            .endAppearanceTransition(viewController2),
            .endAppearanceTransition(viewController1),
        ])
    }

    func testSelectNextAnimated() {
        let viewController0 = UIViewController()
        let viewController1 = UIViewController()
        let viewController2 = UIViewController()

        dataSource.viewControllerBefore = { _ in viewController0 }
        dataSource.viewControllerAfter = { _ in viewController2 }
        manager.viewDidAppear(false)
        manager.select(viewController: viewController1)

        delegate.calls = []

        dataSource.viewControllerAfter = { _ in nil }
        dataSource.viewControllerBefore = { _ in
            XCTFail()
            return nil
        }

        manager.selectNext(animated: true)
        manager.didScroll(progress: 0.1)

        // Assert that the willScroll event is triggered which means the
        // initialDirection state was reset.
        XCTAssertEqual(delegate.calls, [
            .scrollForward,
            .isScrolling(from: viewController1, to: viewController2, progress: 0.1),
            .willScroll(from: viewController1, to: viewController2),
            .beginAppearanceTransition(true, viewController2, true),
            .beginAppearanceTransition(false, viewController1, true),
        ])
    }

    func testSelectNextWithoutAnimation() {
        let viewController0 = UIViewController()
        let viewController1 = UIViewController()
        let viewController2 = UIViewController()
        let viewController3 = UIViewController()

        dataSource.viewControllerBefore = { _ in viewController0 }
        dataSource.viewControllerAfter = { _ in viewController2 }
        manager.viewDidAppear(false)
        manager.select(viewController: viewController1)

        delegate.calls = []

        dataSource.viewControllerAfter = { _ in viewController3 }
        dataSource.viewControllerBefore = { _ in
            XCTFail()
            return nil
        }

        manager.selectNext(animated: false)

        // Expect that it moves the view controllers immediately instead
        // of triggered the .scrollForward event.
        XCTAssertEqual(delegate.calls, [
            .beginAppearanceTransition(false, viewController1, false),
            .beginAppearanceTransition(true, viewController2, false),
            .removeViewController(viewController0),
            .addViewController(viewController3),
            .layoutViews([viewController1, viewController2, viewController3]),
            .endAppearanceTransition(viewController1),
            .endAppearanceTransition(viewController2),
        ])
    }

    func testSelectPreviousAnimated() {
        let viewController0 = UIViewController()
        let viewController1 = UIViewController()
        let viewController2 = UIViewController()

        dataSource.viewControllerBefore = { _ in viewController0 }
        dataSource.viewControllerAfter = { _ in viewController2 }
        manager.viewDidAppear(false)
        manager.select(viewController: viewController1)

        delegate.calls = []

        dataSource.viewControllerBefore = { _ in nil }
        dataSource.viewControllerAfter = { _ in
            XCTFail()
            return nil
        }

        manager.selectPrevious(animated: true)
        manager.didScroll(progress: -0.1)

        // Expect that the willScroll event is triggered which means the
        // initialDirection state was reset.
        XCTAssertEqual(delegate.calls, [
            .scrollReverse,
            .isScrolling(from: viewController1, to: viewController0, progress: -0.1),
            .willScroll(from: viewController1, to: viewController0),
            .beginAppearanceTransition(true, viewController0, true),
            .beginAppearanceTransition(false, viewController1, true),
        ])
    }

    func testSelectPreviousWithoutAnimation() {
        let viewController0 = UIViewController()
        let viewController1 = UIViewController()
        let viewController2 = UIViewController()
        let viewController3 = UIViewController()

        dataSource.viewControllerBefore = { _ in viewController1 }
        dataSource.viewControllerAfter = { _ in viewController3 }
        manager.viewDidAppear(false)
        manager.select(viewController: viewController2)

        delegate.calls = []

        dataSource.viewControllerBefore = { _ in viewController0 }
        dataSource.viewControllerAfter = { _ in
            XCTFail()
            return nil
        }

        manager.selectPrevious(animated: false)

        // Expect that it moves the view controllers immediately instead
        // of triggered the .scrollForward event.
        XCTAssertEqual(delegate.calls, [
            .beginAppearanceTransition(false, viewController2, false),
            .beginAppearanceTransition(true, viewController1, false),
            .removeViewController(viewController3),
            .addViewController(viewController0),
            .layoutViews([viewController0, viewController1, viewController2]),
            .endAppearanceTransition(viewController2),
            .endAppearanceTransition(viewController1),
        ])
    }

    // MARK: - Scrolling

    func testStartedScrollingForward() {
        let selectedVc = UIViewController()
        let nextVc = UIViewController()

        dataSource.viewControllerAfter = { _ in nextVc }
        manager.viewDidAppear(false)
        manager.select(viewController: selectedVc)
        delegate.calls = []

        manager.willBeginDragging()
        manager.didScroll(progress: 0.1)

        XCTAssertEqual(delegate.calls, [
            .isScrolling(from: selectedVc, to: nextVc, progress: 0.1),
            .willScroll(from: selectedVc, to: nextVc),
            .beginAppearanceTransition(true, nextVc, true),
            .beginAppearanceTransition(false, selectedVc, true),
        ])
    }

    func testStartedScrollingForwardNextNil() {
        let selectedVc = UIViewController()

        manager.viewDidAppear(false)
        manager.select(viewController: selectedVc)
        delegate.calls = []

        manager.willBeginDragging()
        manager.didScroll(progress: 0.1)

        XCTAssertEqual(delegate.calls, [
            .isScrolling(from: selectedVc, to: nil, progress: 0.1),
        ])
    }

    func testStartedScrollingReverse() {
        let selectedVc = UIViewController()
        let previousVc = UIViewController()

        dataSource.viewControllerBefore = { _ in previousVc }
        manager.viewDidAppear(false)
        manager.select(viewController: selectedVc)
        delegate.calls = []

        manager.willBeginDragging()
        manager.didScroll(progress: -0.1)

        XCTAssertEqual(delegate.calls, [
            .isScrolling(from: selectedVc, to: previousVc, progress: -0.1),
            .willScroll(from: selectedVc, to: previousVc),
            .beginAppearanceTransition(true, previousVc, true),
            .beginAppearanceTransition(false, selectedVc, true),
        ])
    }

    func testStartedScrollingReversePreviousNil() {
        let selectedVc = UIViewController()

        manager.viewDidAppear(false)
        manager.select(viewController: selectedVc)
        delegate.calls = []

        manager.willBeginDragging()
        manager.didScroll(progress: -0.1)

        XCTAssertEqual(delegate.calls, [
            .isScrolling(from: selectedVc, to: nil, progress: -0.1),
        ])
    }

    func testIsScrollingForward() {
        let selectedVc = UIViewController()
        let nextVc = UIViewController()

        manager.viewDidAppear(false)
        dataSource.viewControllerAfter = { _ in nextVc }
        manager.select(viewController: selectedVc)

        manager.willBeginDragging()
        manager.didScroll(progress: 0.1)
        delegate.calls = []
        manager.didScroll(progress: 0.2)
        manager.didScroll(progress: 0.3)

        XCTAssertEqual(delegate.calls, [
            .isScrolling(from: selectedVc, to: nextVc, progress: 0.2),
            .isScrolling(from: selectedVc, to: nextVc, progress: 0.3),
        ])
    }

    func testIsScrollingReverse() {
        let previousVc = UIViewController()
        let selectedVc = UIViewController()

        dataSource.viewControllerBefore = { _ in previousVc }
        manager.viewDidAppear(false)
        manager.select(viewController: selectedVc)

        manager.willBeginDragging()
        manager.didScroll(progress: -0.1)
        delegate.calls = []
        manager.didScroll(progress: -0.2)
        manager.didScroll(progress: -0.3)

        XCTAssertEqual(delegate.calls, [
            .isScrolling(from: selectedVc, to: previousVc, progress: -0.2),
            .isScrolling(from: selectedVc, to: previousVc, progress: -0.3),
        ])
    }

    func testFinishedScrollingForward() {
        let viewController0 = UIViewController()
        let viewController1 = UIViewController()
        let viewController2 = UIViewController()
        let viewController3 = UIViewController()

        dataSource.viewControllerBefore = { _ in viewController0 }
        dataSource.viewControllerAfter = { _ in viewController2 }
        manager.viewDidAppear(false)
        manager.select(viewController: viewController1)
        dataSource.viewControllerAfter = { _ in viewController3 }

        manager.willBeginDragging()
        manager.didScroll(progress: 0.1)
        delegate.calls = []
        manager.didScroll(progress: 1.0)

        XCTAssertEqual(delegate.calls, [
            .isScrolling(from: viewController1, to: viewController2, progress: 1.0),
            .didFinishScrolling(from: viewController1, to: viewController2, success: true),
            .removeViewController(viewController0),
            .addViewController(viewController3),
            .layoutViews([viewController1, viewController2, viewController3]),
            .endAppearanceTransition(viewController1),
            .endAppearanceTransition(viewController2),
        ])
    }

    func testFinishedScrollingForwardNextNil() {
        let viewController0 = UIViewController()
        let viewController1 = UIViewController()
        let viewController2 = UIViewController()

        dataSource.viewControllerBefore = { _ in viewController0 }
        dataSource.viewControllerAfter = { _ in viewController2 }
        manager.viewDidAppear(false)
        manager.select(viewController: viewController1)

        dataSource.viewControllerAfter = { _ in nil }

        manager.willBeginDragging()
        manager.didScroll(progress: 0.1)
        delegate.calls = []
        manager.didScroll(progress: 1.0)

        XCTAssertEqual(delegate.calls, [
            .isScrolling(from: viewController1, to: viewController2, progress: 1.0),
            .didFinishScrolling(from: viewController1, to: viewController2, success: true),
            .removeViewController(viewController0),
            .layoutViews([viewController1, viewController2]),
            .endAppearanceTransition(viewController1),
            .endAppearanceTransition(viewController2),
        ])
    }

    func testFinishedScrollingReverse() {
        let viewController0 = UIViewController()
        let viewController1 = UIViewController()
        let viewController2 = UIViewController()
        let viewController3 = UIViewController()

        dataSource.viewControllerBefore = { _ in viewController1 }
        dataSource.viewControllerAfter = { _ in viewController3 }
        manager.viewDidAppear(false)
        manager.select(viewController: viewController2)

        dataSource.viewControllerBefore = { _ in viewController0 }

        manager.willBeginDragging()
        manager.didScroll(progress: -0.1)
        delegate.calls = []
        manager.didScroll(progress: -1.0)

        XCTAssertEqual(delegate.calls, [
            .isScrolling(from: viewController2, to: viewController1, progress: -1.0),
            .didFinishScrolling(from: viewController2, to: viewController1, success: true),
            .removeViewController(viewController3),
            .addViewController(viewController0),
            .layoutViews([viewController0, viewController1, viewController2]),
            .endAppearanceTransition(viewController2),
            .endAppearanceTransition(viewController1),
        ])
    }

    func testFinishedScrollingReversePreviousNil() {
        let viewController1 = UIViewController()
        let viewController2 = UIViewController()
        let viewController3 = UIViewController()

        dataSource.viewControllerBefore = { _ in viewController1 }
        dataSource.viewControllerAfter = { _ in viewController3 }
        manager.viewDidAppear(false)
        manager.select(viewController: viewController2)

        dataSource.viewControllerBefore = { _ in nil }

        manager.willBeginDragging()
        manager.didScroll(progress: -0.1)
        delegate.calls = []
        manager.didScroll(progress: -1.0)

        XCTAssertEqual(delegate.calls, [
            .isScrolling(from: viewController2, to: viewController1, progress: -1.0),
            .didFinishScrolling(from: viewController2, to: viewController1, success: true),
            .removeViewController(viewController3),
            .layoutViews([viewController1, viewController2]),
            .endAppearanceTransition(viewController2),
            .endAppearanceTransition(viewController1),
        ])
    }

    func testDidScrollAfterDraggingEnded() {
        let viewController0 = UIViewController()
        let viewController1 = UIViewController()
        let viewController2 = UIViewController()
        let viewController3 = UIViewController()

        dataSource.viewControllerBefore = { _ in viewController0 }
        dataSource.viewControllerAfter = { _ in viewController2 }
        manager.viewDidAppear(false)
        manager.select(viewController: viewController1)

        dataSource.viewControllerAfter = { _ in viewController3 }

        manager.willBeginDragging()
        manager.didScroll(progress: 0.1)
        delegate.calls = []
        manager.willEndDragging()
        manager.willBeginDragging()
        manager.willEndDragging()
        manager.didScroll(progress: 0.2)
        manager.didScroll(progress: 0.3)

        // Expect that it continues to trigger .isScrolling events for the
        // correct view controllers.
        XCTAssertEqual(delegate.calls, [
            .isScrolling(from: viewController1, to: viewController2, progress: 0.2),
            .isScrolling(from: viewController1, to: viewController2, progress: 0.3),
        ])
    }

    func testFinishedScrollingOvershooting() {
        let viewController0 = UIViewController()
        let viewController1 = UIViewController()
        let viewController2 = UIViewController()
        let viewController3 = UIViewController()

        dataSource.viewControllerBefore = { _ in viewController0 }
        dataSource.viewControllerAfter = { _ in viewController2 }
        manager.viewDidAppear(false)
        manager.select(viewController: viewController1)

        dataSource.viewControllerAfter = { _ in viewController3 }

        manager.willBeginDragging()
        manager.didScroll(progress: 0.1)
        manager.didScroll(progress: 1.0)
        delegate.calls = []
        manager.didScroll(progress: 0.0)
        manager.didScroll(progress: 0.01)
        manager.didScroll(progress: -0.01)

        // Expect that it triggers .isScrolling events for scroll events
        // when overshooting, but does not trigger appearance transitions
        // for the next upcoming view (viewController3).
        XCTAssertEqual(delegate.calls, [
            .isScrolling(from: viewController2, to: viewController3, progress: 0.0),
            .isScrolling(from: viewController2, to: viewController3, progress: 0.01),
            .isScrolling(from: viewController2, to: viewController3, progress: -0.01),
        ])
    }

    func testCancelScrollForward() {
        let viewController1 = UIViewController()
        let viewController2 = UIViewController()
        let viewController3 = UIViewController()

        dataSource.viewControllerBefore = { _ in viewController1 }
        dataSource.viewControllerAfter = { _ in viewController3 }
        manager.viewDidAppear(false)
        manager.select(viewController: viewController2)

        manager.willBeginDragging()
        manager.didScroll(progress: 0.1)
        delegate.calls = []
        manager.didScroll(progress: 0)

        XCTAssertEqual(delegate.calls, [
            .isScrolling(from: viewController2, to: viewController3, progress: 0.0),
            .beginAppearanceTransition(true, viewController2, true),
            .beginAppearanceTransition(false, viewController3, true),
            .endAppearanceTransition(viewController2),
            .endAppearanceTransition(viewController3),
            .didFinishScrolling(from: viewController2, to: viewController3, success: false),
        ])
    }

    func testCancelScrollReverse() {
        let viewController1 = UIViewController()
        let viewController2 = UIViewController()
        let viewController3 = UIViewController()

        dataSource.viewControllerBefore = { _ in viewController1 }
        dataSource.viewControllerAfter = { _ in viewController3 }
        manager.viewDidAppear(false)
        manager.select(viewController: viewController2)

        manager.willBeginDragging()
        manager.didScroll(progress: -0.1)
        delegate.calls = []
        manager.didScroll(progress: 0)

        XCTAssertEqual(delegate.calls, [
            .isScrolling(from: viewController2, to: viewController1, progress: 0.0),
            .beginAppearanceTransition(true, viewController2, true),
            .beginAppearanceTransition(false, viewController1, true),
            .endAppearanceTransition(viewController2),
            .endAppearanceTransition(viewController1),
            .didFinishScrolling(from: viewController2, to: viewController1, success: false),
        ])
    }

    func testCancelScrollForwardThenSwipeForwardAgain() {
        let viewController1 = UIViewController()
        let viewController2 = UIViewController()
        let viewController3 = UIViewController()

        dataSource.viewControllerBefore = { _ in viewController1 }
        dataSource.viewControllerAfter = { _ in viewController3 }
        manager.viewDidAppear(false)
        manager.select(viewController: viewController2)

        manager.willBeginDragging()
        manager.didScroll(progress: 0.1)
        manager.didScroll(progress: 0)
        delegate.calls = []
        manager.willEndDragging()
        manager.willBeginDragging()
        manager.willEndDragging()
        manager.didScroll(progress: 0.1)

        XCTAssertEqual(delegate.calls, [
            .isScrolling(from: viewController2, to: viewController3, progress: 0.1),
            .willScroll(from: viewController2, to: viewController3),
            .beginAppearanceTransition(true, viewController3, true),
            .beginAppearanceTransition(false, viewController2, true),
        ])
    }

    func testCancelScrollReverseThenSwipeReverseAgain() {
        let viewController1 = UIViewController()
        let viewController2 = UIViewController()
        let viewController3 = UIViewController()

        dataSource.viewControllerBefore = { _ in viewController1 }
        dataSource.viewControllerAfter = { _ in viewController3 }
        manager.viewDidAppear(false)
        manager.select(viewController: viewController2)

        manager.willBeginDragging()
        manager.didScroll(progress: -0.1)
        manager.didScroll(progress: 0)
        delegate.calls = []
        manager.willEndDragging()
        manager.willBeginDragging()
        manager.willEndDragging()
        manager.didScroll(progress: -0.1)

        XCTAssertEqual(delegate.calls, [
            .isScrolling(from: viewController2, to: viewController1, progress: -0.1),
            .willScroll(from: viewController2, to: viewController1),
            .beginAppearanceTransition(true, viewController1, true),
            .beginAppearanceTransition(false, viewController2, true),
        ])
    }

    func testCancelScrollForwardThenSwipeReverse() {
        let viewController1 = UIViewController()
        let viewController2 = UIViewController()
        let viewController3 = UIViewController()

        dataSource.viewControllerBefore = { _ in viewController1 }
        dataSource.viewControllerAfter = { _ in viewController3 }
        manager.viewDidAppear(false)
        manager.select(viewController: viewController2)

        manager.willBeginDragging()
        manager.didScroll(progress: 0.1)
        delegate.calls = []
        manager.willEndDragging()
        manager.willBeginDragging()
        manager.willEndDragging()
        manager.didScroll(progress: -0.1)

        XCTAssertEqual(delegate.calls, [
            .beginAppearanceTransition(true, viewController2, true),
            .beginAppearanceTransition(false, viewController3, true),
            .endAppearanceTransition(viewController2),
            .endAppearanceTransition(viewController3),
            .didFinishScrolling(from: viewController2, to: viewController3, success: false),
            .isScrolling(from: viewController2, to: viewController1, progress: -0.1),
            .willScroll(from: viewController2, to: viewController1),
            .beginAppearanceTransition(true, viewController1, true),
            .beginAppearanceTransition(false, viewController2, true),
        ])
    }

    func testCancelScrollReverseThenSwipeForward() {
        let viewController1 = UIViewController()
        let viewController2 = UIViewController()
        let viewController3 = UIViewController()

        dataSource.viewControllerBefore = { _ in viewController1 }
        dataSource.viewControllerAfter = { _ in viewController3 }
        manager.viewDidAppear(false)
        manager.select(viewController: viewController2)

        manager.willBeginDragging()
        manager.didScroll(progress: -0.1)
        delegate.calls = []
        manager.willEndDragging()
        manager.willBeginDragging()
        manager.willEndDragging()
        manager.didScroll(progress: 0.1)

        XCTAssertEqual(delegate.calls, [
            .beginAppearanceTransition(true, viewController2, true),
            .beginAppearanceTransition(false, viewController1, true),
            .endAppearanceTransition(viewController2),
            .endAppearanceTransition(viewController1),
            .didFinishScrolling(from: viewController2, to: viewController1, success: false),
            .isScrolling(from: viewController2, to: viewController3, progress: 0.1),
            .willScroll(from: viewController2, to: viewController3),
            .beginAppearanceTransition(true, viewController3, true),
            .beginAppearanceTransition(false, viewController2, true),
        ])
    }

    func testStartedScrollingBeforeCurrentSwipeReloaded() {
        let viewController1 = UIViewController()
        let viewController2 = UIViewController()
        let viewController3 = UIViewController()
        let viewController4 = UIViewController()

        dataSource.viewControllerBefore = { _ in viewController1 }
        dataSource.viewControllerAfter = { _ in viewController3 }
        manager.viewDidAppear(false)
        manager.select(viewController: viewController2)
        dataSource.viewControllerAfter = { _ in viewController4 }

        manager.willBeginDragging()
        manager.didScroll(progress: 0.1)
        manager.willEndDragging()
        manager.willBeginDragging()
        manager.didScroll(progress: 1)
        delegate.calls = []
        manager.willEndDragging()
        manager.didScroll(progress: 0.1)

        XCTAssertEqual(delegate.calls, [
            .isScrolling(from: viewController3, to: viewController4, progress: 0.1),
            .willScroll(from: viewController3, to: viewController4),
            .beginAppearanceTransition(true, viewController4, true),
            .beginAppearanceTransition(false, viewController3, true),
        ])
    }

    // MARK: - Removing

    func testRemoveAll() {
        let previousVc = UIViewController()
        let selectedVc = UIViewController()
        let nextVc = UIViewController()

        dataSource.viewControllerBefore = { _ in previousVc }
        dataSource.viewControllerAfter = { _ in nextVc }
        manager.viewDidAppear(false)
        manager.select(viewController: selectedVc)

        delegate.calls = []

        manager.removeAll()

        // Expects that it removes all view controller and starts
        // appearance transitions without animations.
        XCTAssertEqual(delegate.calls, [
            .beginAppearanceTransition(false, selectedVc, false),
            .removeViewController(selectedVc),
            .removeViewController(previousVc),
            .removeViewController(nextVc),
            .layoutViews([]),
            .endAppearanceTransition(selectedVc),
        ])
    }

    // MARK: - View Appearance

    func testViewAppeared() {
        let viewController = UIViewController()
        manager.select(viewController: viewController)
        delegate.calls = []
        manager.viewWillAppear(false)
        manager.viewDidAppear(false)

        XCTAssertEqual(delegate.calls, [
            .beginAppearanceTransition(true, viewController, false),
            .layoutViews([viewController]),
            .endAppearanceTransition(viewController),
        ])
    }

    func testViewAppearedAnimated() {
        let viewController = UIViewController()
        manager.select(viewController: viewController)
        delegate.calls = []
        manager.viewWillAppear(true)
        manager.viewDidAppear(true)

        XCTAssertEqual(delegate.calls, [
            .beginAppearanceTransition(true, viewController, true),
            .layoutViews([viewController]),
            .endAppearanceTransition(viewController),
        ])
    }

    func testViewDisappeared() {
        let viewController = UIViewController()
        manager.select(viewController: viewController)
        delegate.calls = []
        manager.viewWillDisappear(false)
        manager.viewDidDisappear(false)

        XCTAssertEqual(delegate.calls, [
            .beginAppearanceTransition(false, viewController, false),
            .endAppearanceTransition(viewController),
        ])
    }

    func testViewDidDisappearAnimated() {
        let viewController = UIViewController()
        manager.select(viewController: viewController)
        delegate.calls = []
        manager.viewWillDisappear(true)
        manager.viewDidDisappear(true)

        XCTAssertEqual(delegate.calls, [
            .beginAppearanceTransition(false, viewController, true),
            .endAppearanceTransition(viewController),
        ])
    }

    func testSelectBeforeViewAppeared() {
        let viewController = UIViewController()
        manager.select(viewController: viewController)

        // Expect that the appearance transitions methods are not called
        // for the selected view controller.
        XCTAssertEqual(delegate.calls, [
            .addViewController(viewController),
            .layoutViews([viewController]),
        ])
    }

    func testSelectWhenAppearing() {
        let viewController = UIViewController()
        manager.viewWillAppear(true)
        manager.select(viewController: viewController, animated: false)
        manager.viewDidAppear(true)

        // Expect that it begins appearance transitions with the same
        // animated flag as viewWillAppear.
        XCTAssertEqual(delegate.calls, [
            .beginAppearanceTransition(true, viewController, true),
            .addViewController(viewController),
            .layoutViews([viewController]),
            .endAppearanceTransition(viewController),
        ])
    }

    func testSelectWhenDisappearing() {
        let viewController = UIViewController()
        manager.viewWillAppear(true)
        manager.viewDidAppear(true)
        manager.viewWillDisappear(true)
        manager.select(viewController: viewController, animated: false)
        manager.viewDidDisappear(true)

        // Expect that it begins appearance transitions with the same
        // animated flag as viewWillDisappear.
        XCTAssertEqual(delegate.calls, [
            .beginAppearanceTransition(false, viewController, true),
            .addViewController(viewController),
            .layoutViews([viewController]),
            .endAppearanceTransition(viewController),
        ])
    }

    func testSelectWhenDisappeared() {
        let viewController = UIViewController()
        manager.viewWillAppear(true)
        manager.viewDidAppear(true)
        manager.viewWillDisappear(true)
        manager.viewDidDisappear(true)
        manager.select(viewController: viewController, animated: false)

        XCTAssertEqual(delegate.calls, [
            .addViewController(viewController),
            .layoutViews([viewController]),
        ])
    }
}

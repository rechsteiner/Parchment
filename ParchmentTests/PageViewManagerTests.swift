import Foundation
import Testing
@testable import Parchment

@MainActor
final class PageViewManagerTests {
    private var dataSource: MockPageViewManagerDataSource
    private var delegate: MockPageViewManagerDelegate
    private var manager: PageViewManager

    init() {
        dataSource = MockPageViewManagerDataSource()
        delegate = MockPageViewManagerDelegate()
        manager = PageViewManager()
        manager.dataSource = dataSource
        manager.delegate = delegate
    }

    // MARK: - Selection

    @Test func selectWhenEmpty() {
        let previousVc = UIViewController()
        let selectedVc = UIViewController()
        let nextVc = UIViewController()

        dataSource.viewControllerBefore = { _ in previousVc }
        dataSource.viewControllerAfter = { _ in nextVc }

        manager.viewDidAppear(false)
        manager.select(viewController: selectedVc, animated: true)

        #expect(delegate.calls == [
            .beginAppearanceTransition(true, selectedVc, true),
            .addViewController(previousVc),
            .addViewController(selectedVc),
            .addViewController(nextVc),
            .layoutViews([previousVc, selectedVc, nextVc]),
            .endAppearanceTransition(selectedVc),
        ])
    }

    @Test func selectAllNewViewControllersForwardAnimated() {
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

        #expect(delegate.calls == [
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

    @Test func cancelSelectAllNewViewControllersForwardAnimated() {
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

        #expect(delegate.calls == [
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

    @Test func selectAllNewViewControllersReverseAnimated() {
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

        #expect(delegate.calls == [
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

    @Test func cancelSelectAllNewViewControllersReverseAnimated() {
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

        #expect(delegate.calls == [
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

    @Test func selectAllNewViewControllersWithoutAnimation() {
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

        #expect(delegate.calls == [
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

    @Test func selectShiftOneForwardWithoutAnimation() {
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

        #expect(delegate.calls == [
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

    @Test func selectShiftOneReverseWithoutAnimation() {
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

        #expect(delegate.calls == [
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

    @Test func selectNextAnimated() {
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
            Issue.record("Expected this to not be called")
            return nil
        }

        manager.selectNext(animated: true)
        manager.didScroll(progress: 0.1)

        // Assert that the willScroll event is triggered which means the
        // initialDirection state was reset.
        #expect(delegate.calls == [
            .scrollForward,
            .isScrolling(from: viewController1, to: viewController2, progress: 0.1),
            .willScroll(from: viewController1, to: viewController2),
            .beginAppearanceTransition(true, viewController2, true),
            .beginAppearanceTransition(false, viewController1, true),
        ])
    }

    @Test func selectNextWithoutAnimation() {
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
            Issue.record("Expected this to not be called")
            return nil
        }

        manager.selectNext(animated: false)

        // Expect that it moves the view controllers immediately instead
        // of triggered the .scrollForward event.
        #expect(delegate.calls == [
            .beginAppearanceTransition(false, viewController1, false),
            .beginAppearanceTransition(true, viewController2, false),
            .removeViewController(viewController0),
            .addViewController(viewController3),
            .layoutViews([viewController1, viewController2, viewController3]),
            .endAppearanceTransition(viewController1),
            .endAppearanceTransition(viewController2),
        ])
    }

    @Test func selectPreviousAnimated() {
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
            Issue.record("Expected this to not be called")
            return nil
        }

        manager.selectPrevious(animated: true)
        manager.didScroll(progress: -0.1)

        // Expect that the willScroll event is triggered which means the
        // initialDirection state was reset.
        #expect(delegate.calls == [
            .scrollReverse,
            .isScrolling(from: viewController1, to: viewController0, progress: -0.1),
            .willScroll(from: viewController1, to: viewController0),
            .beginAppearanceTransition(true, viewController0, true),
            .beginAppearanceTransition(false, viewController1, true),
        ])
    }

    @Test func selectPreviousWithoutAnimation() {
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
            Issue.record("Expected this to not be called")
            return nil
        }

        manager.selectPrevious(animated: false)

        // Expect that it moves the view controllers immediately instead
        // of triggered the .scrollForward event.
        #expect(delegate.calls == [
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

    @Test func startedScrollingForward() {
        let selectedVc = UIViewController()
        let nextVc = UIViewController()

        dataSource.viewControllerAfter = { _ in nextVc }
        manager.viewDidAppear(false)
        manager.select(viewController: selectedVc)
        delegate.calls = []

        manager.willBeginDragging()
        manager.didScroll(progress: 0.1)

        #expect(delegate.calls == [
            .isScrolling(from: selectedVc, to: nextVc, progress: 0.1),
            .willScroll(from: selectedVc, to: nextVc),
            .beginAppearanceTransition(true, nextVc, true),
            .beginAppearanceTransition(false, selectedVc, true),
        ])
    }

    @Test func startedScrollingForwardNextNil() {
        let selectedVc = UIViewController()

        manager.viewDidAppear(false)
        manager.select(viewController: selectedVc)
        delegate.calls = []

        manager.willBeginDragging()
        manager.didScroll(progress: 0.1)

        #expect(delegate.calls == [
            .isScrolling(from: selectedVc, to: nil, progress: 0.1),
        ])
    }

    @Test func startedScrollingReverse() {
        let selectedVc = UIViewController()
        let previousVc = UIViewController()

        dataSource.viewControllerBefore = { _ in previousVc }
        manager.viewDidAppear(false)
        manager.select(viewController: selectedVc)
        delegate.calls = []

        manager.willBeginDragging()
        manager.didScroll(progress: -0.1)

        #expect(delegate.calls == [
            .isScrolling(from: selectedVc, to: previousVc, progress: -0.1),
            .willScroll(from: selectedVc, to: previousVc),
            .beginAppearanceTransition(true, previousVc, true),
            .beginAppearanceTransition(false, selectedVc, true),
        ])
    }

    @Test func startedScrollingReversePreviousNil() {
        let selectedVc = UIViewController()

        manager.viewDidAppear(false)
        manager.select(viewController: selectedVc)
        delegate.calls = []

        manager.willBeginDragging()
        manager.didScroll(progress: -0.1)

        #expect(delegate.calls == [
            .isScrolling(from: selectedVc, to: nil, progress: -0.1),
        ])
    }

    @Test func isScrollingForward() {
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

        #expect(delegate.calls == [
            .isScrolling(from: selectedVc, to: nextVc, progress: 0.2),
            .isScrolling(from: selectedVc, to: nextVc, progress: 0.3),
        ])
    }

    @Test func isScrollingReverse() {
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

        #expect(delegate.calls == [
            .isScrolling(from: selectedVc, to: previousVc, progress: -0.2),
            .isScrolling(from: selectedVc, to: previousVc, progress: -0.3),
        ])
    }

    @Test func finishedScrollingForward() {
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

        #expect(delegate.calls == [
            .isScrolling(from: viewController1, to: viewController2, progress: 1.0),
            .didFinishScrolling(from: viewController1, to: viewController2, success: true),
            .removeViewController(viewController0),
            .addViewController(viewController3),
            .layoutViews([viewController1, viewController2, viewController3]),
            .endAppearanceTransition(viewController1),
            .endAppearanceTransition(viewController2),
        ])
    }

    @Test func finishedScrollingForwardNextNil() {
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

        #expect(delegate.calls == [
            .isScrolling(from: viewController1, to: viewController2, progress: 1.0),
            .didFinishScrolling(from: viewController1, to: viewController2, success: true),
            .removeViewController(viewController0),
            .layoutViews([viewController1, viewController2]),
            .endAppearanceTransition(viewController1),
            .endAppearanceTransition(viewController2),
        ])
    }

    @Test func finishedScrollingReverse() {
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

        #expect(delegate.calls == [
            .isScrolling(from: viewController2, to: viewController1, progress: -1.0),
            .didFinishScrolling(from: viewController2, to: viewController1, success: true),
            .removeViewController(viewController3),
            .addViewController(viewController0),
            .layoutViews([viewController0, viewController1, viewController2]),
            .endAppearanceTransition(viewController2),
            .endAppearanceTransition(viewController1),
        ])
    }

    @Test func finishedScrollingReversePreviousNil() {
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

        #expect(delegate.calls == [
            .isScrolling(from: viewController2, to: viewController1, progress: -1.0),
            .didFinishScrolling(from: viewController2, to: viewController1, success: true),
            .removeViewController(viewController3),
            .layoutViews([viewController1, viewController2]),
            .endAppearanceTransition(viewController2),
            .endAppearanceTransition(viewController1),
        ])
    }

    @Test func didScrollAfterDraggingEnded() {
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
        #expect(delegate.calls == [
            .isScrolling(from: viewController1, to: viewController2, progress: 0.2),
            .isScrolling(from: viewController1, to: viewController2, progress: 0.3),
        ])
    }

    @Test func finishedScrollingOvershooting() {
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
        #expect(delegate.calls == [
            .isScrolling(from: viewController2, to: viewController3, progress: 0.0),
            .isScrolling(from: viewController2, to: viewController3, progress: 0.01),
            .isScrolling(from: viewController2, to: viewController3, progress: -0.01),
        ])
    }

    @Test func cancelScrollForward() {
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

        #expect(delegate.calls == [
            .isScrolling(from: viewController2, to: viewController3, progress: 0.0),
            .beginAppearanceTransition(true, viewController2, true),
            .beginAppearanceTransition(false, viewController3, true),
            .endAppearanceTransition(viewController2),
            .endAppearanceTransition(viewController3),
            .didFinishScrolling(from: viewController2, to: viewController3, success: false),
        ])
    }

    @Test func cancelScrollReverse() {
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

        #expect(delegate.calls == [
            .isScrolling(from: viewController2, to: viewController1, progress: 0.0),
            .beginAppearanceTransition(true, viewController2, true),
            .beginAppearanceTransition(false, viewController1, true),
            .endAppearanceTransition(viewController2),
            .endAppearanceTransition(viewController1),
            .didFinishScrolling(from: viewController2, to: viewController1, success: false),
        ])
    }

    @Test func cancelScrollForwardThenSwipeForwardAgain() {
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

        #expect(delegate.calls == [
            .isScrolling(from: viewController2, to: viewController3, progress: 0.1),
            .willScroll(from: viewController2, to: viewController3),
            .beginAppearanceTransition(true, viewController3, true),
            .beginAppearanceTransition(false, viewController2, true),
        ])
    }

    @Test func cancelScrollReverseThenSwipeReverseAgain() {
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

        #expect(delegate.calls == [
            .isScrolling(from: viewController2, to: viewController1, progress: -0.1),
            .willScroll(from: viewController2, to: viewController1),
            .beginAppearanceTransition(true, viewController1, true),
            .beginAppearanceTransition(false, viewController2, true),
        ])
    }

    @Test func cancelScrollForwardThenSwipeReverse() {
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

        #expect(delegate.calls == [
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

    @Test func cancelScrollReverseThenSwipeForward() {
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

        #expect(delegate.calls == [
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

    @Test func startedScrollingBeforeCurrentSwipeReloaded() {
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

        #expect(delegate.calls == [
            .isScrolling(from: viewController3, to: viewController4, progress: 0.1),
            .willScroll(from: viewController3, to: viewController4),
            .beginAppearanceTransition(true, viewController4, true),
            .beginAppearanceTransition(false, viewController3, true),
        ])
    }

    // MARK: - Removing

    @Test func removeAll() {
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
        #expect(delegate.calls == [
            .beginAppearanceTransition(false, selectedVc, false),
            .removeViewController(selectedVc),
            .removeViewController(previousVc),
            .removeViewController(nextVc),
            .layoutViews([]),
            .endAppearanceTransition(selectedVc),
        ])
    }

    // MARK: - View Appearance

    @Test func viewAppeared() {
        let viewController = UIViewController()
        manager.select(viewController: viewController)
        delegate.calls = []
        manager.viewWillAppear(false)
        manager.viewDidAppear(false)

        #expect(delegate.calls == [
            .beginAppearanceTransition(true, viewController, false),
            .layoutViews([viewController]),
            .endAppearanceTransition(viewController),
        ])
    }

    @Test func viewAppearedAnimated() {
        let viewController = UIViewController()
        manager.select(viewController: viewController)
        delegate.calls = []
        manager.viewWillAppear(true)
        manager.viewDidAppear(true)

        #expect(delegate.calls == [
            .beginAppearanceTransition(true, viewController, true),
            .layoutViews([viewController]),
            .endAppearanceTransition(viewController),
        ])
    }

    @Test func viewDisappeared() {
        let viewController = UIViewController()
        manager.select(viewController: viewController)
        delegate.calls = []
        manager.viewWillDisappear(false)
        manager.viewDidDisappear(false)

        #expect(delegate.calls == [
            .beginAppearanceTransition(false, viewController, false),
            .endAppearanceTransition(viewController),
        ])
    }

    @Test func viewDidDisappearAnimated() {
        let viewController = UIViewController()
        manager.select(viewController: viewController)
        delegate.calls = []
        manager.viewWillDisappear(true)
        manager.viewDidDisappear(true)

        #expect(delegate.calls == [
            .beginAppearanceTransition(false, viewController, true),
            .endAppearanceTransition(viewController),
        ])
    }

    @Test func selectBeforeViewAppeared() {
        let viewController = UIViewController()
        manager.select(viewController: viewController)

        // Expect that the appearance transitions methods are not called
        // for the selected view controller.
        #expect(delegate.calls == [
            .addViewController(viewController),
            .layoutViews([viewController]),
        ])
    }

    @Test func selectWhenAppearing() {
        let viewController = UIViewController()
        manager.viewWillAppear(true)
        manager.select(viewController: viewController, animated: false)
        manager.viewDidAppear(true)

        // Expect that it begins appearance transitions with the same
        // animated flag as viewWillAppear.
        #expect(delegate.calls == [
            .beginAppearanceTransition(true, viewController, true),
            .addViewController(viewController),
            .layoutViews([viewController]),
            .endAppearanceTransition(viewController),
        ])
    }

    @Test func selectWhenDisappearing() {
        let viewController = UIViewController()
        manager.viewWillAppear(true)
        manager.viewDidAppear(true)
        manager.viewWillDisappear(true)
        manager.select(viewController: viewController, animated: false)
        manager.viewDidDisappear(true)

        // Expect that it begins appearance transitions with the same
        // animated flag as viewWillDisappear.
        #expect(delegate.calls == [
            .beginAppearanceTransition(false, viewController, true),
            .addViewController(viewController),
            .layoutViews([viewController]),
            .endAppearanceTransition(viewController),
        ])
    }

    @Test func selectWhenDisappeared() {
        let viewController = UIViewController()
        manager.viewWillAppear(true)
        manager.viewDidAppear(true)
        manager.viewWillDisappear(true)
        manager.viewDidDisappear(true)
        manager.select(viewController: viewController, animated: false)

        #expect(delegate.calls == [
            .addViewController(viewController),
            .layoutViews([viewController]),
        ])
    }
}

import UIKit

@MainActor
final class PageViewManager {
    weak var dataSource: PageViewManagerDataSource?
    weak var delegate: PageViewManagerDelegate?

    private(set) weak var previousViewController: UIViewController?
    private(set) weak var selectedViewController: UIViewController?
    private(set) weak var nextViewController: UIViewController?

    var state: PageViewState {
        if previousViewController == nil, nextViewController == nil, selectedViewController == nil {
            return .empty
        } else if previousViewController == nil, nextViewController == nil {
            return .single
        } else if nextViewController == nil {
            return .last
        } else if previousViewController == nil {
            return .first
        } else {
            return .center
        }
    }

    // MARK: - Private Properties

    private enum AppearanceState {
        case appearing(animated: Bool)
        case disappearing(animated: Bool)
        case disappeared
        case appeared
    }

    private var appearanceState: AppearanceState = .disappeared
    private var didReload: Bool = false
    private var didSelect: Bool = false
    private var initialDirection: PageViewDirection = .none

    // MARK: - Public Methods

    func select(
        viewController: UIViewController,
        direction: PageViewDirection = .none,
        animated: Bool = false
    ) {
        if state == .empty || animated == false {
            selectViewController(viewController, animated: animated)
            return
        } else {
            resetState()
            didSelect = true

            switch direction {
            case .forward, .none:
                if let nextViewController = nextViewController {
                    delegate?.removeViewController(nextViewController)
                }
                delegate?.addViewController(viewController)
                nextViewController = viewController
                layoutsViews()
                delegate?.scrollForward()
            case .reverse:
                if let previousViewController = previousViewController {
                    delegate?.removeViewController(previousViewController)
                }
                delegate?.addViewController(viewController)
                previousViewController = viewController
                layoutsViews()
                delegate?.scrollReverse()
            }
        }
    }

    func selectNext(animated: Bool) {
        if animated {
            resetState()
            delegate?.scrollForward()
        } else if let nextViewController = nextViewController,
            let selectedViewController = selectedViewController {
            beginAppearanceTransition(false, for: selectedViewController, animated: animated)
            beginAppearanceTransition(true, for: nextViewController, animated: animated)

            let newNextViewController = dataSource?.viewControllerAfter(nextViewController)

            if let previousViewController = previousViewController {
                delegate?.removeViewController(previousViewController)
            }

            if let newNextViewController = newNextViewController {
                delegate?.addViewController(newNextViewController)
            }

            previousViewController = selectedViewController
            self.selectedViewController = nextViewController
            self.nextViewController = newNextViewController

            layoutsViews()

            endAppearanceTransition(for: selectedViewController)
            endAppearanceTransition(for: nextViewController)
        }
    }

    func selectPrevious(animated: Bool) {
        if animated {
            resetState()
            delegate?.scrollReverse()
        } else if let previousViewController = previousViewController,
            let selectedViewController = selectedViewController {
            beginAppearanceTransition(false, for: selectedViewController, animated: animated)
            beginAppearanceTransition(true, for: previousViewController, animated: animated)

            let newPreviousViewController = dataSource?.viewControllerBefore(previousViewController)

            if let nextViewController = nextViewController {
                delegate?.removeViewController(nextViewController)
            }

            if let newPreviousViewController = newPreviousViewController {
                delegate?.addViewController(newPreviousViewController)
            }

            self.previousViewController = newPreviousViewController
            self.selectedViewController = previousViewController
            nextViewController = selectedViewController

            layoutsViews()

            endAppearanceTransition(for: selectedViewController)
            endAppearanceTransition(for: previousViewController)
        }
    }

    func removeAll() {
        let oldSelectedViewController = selectedViewController

        if let selectedViewController = oldSelectedViewController {
            beginAppearanceTransition(false, for: selectedViewController, animated: false)
            delegate?.removeViewController(selectedViewController)
        }
        if let previousViewController = previousViewController {
            delegate?.removeViewController(previousViewController)
        }
        if let nextViewController = nextViewController {
            delegate?.removeViewController(nextViewController)
        }
        previousViewController = nil
        selectedViewController = nil
        nextViewController = nil
        layoutsViews()

        if let oldSelectedViewController = oldSelectedViewController {
            endAppearanceTransition(for: oldSelectedViewController)
        }
    }

    func viewDidLayoutSubviews() {
        layoutsViews(keepContentOffset: false)
    }

    func viewWillAppear(_ animated: Bool) {
        appearanceState = .appearing(animated: animated)
        if let selectedViewController = selectedViewController {
            delegate?.beginAppearanceTransition(
                isAppearing: true,
                viewController: selectedViewController,
                animated: animated
            )
        }

        switch state {
        case .center, .first, .last, .single:
            layoutsViews(keepContentOffset: false)
        case .empty:
            break
        }
    }

    func viewDidAppear(_: Bool) {
        appearanceState = .appeared
        if let selectedViewController = selectedViewController {
            delegate?.endAppearanceTransition(viewController: selectedViewController)
        }
    }

    func viewWillDisappear(_ animated: Bool) {
        appearanceState = .disappearing(animated: animated)
        if let selectedViewController = selectedViewController {
            delegate?.beginAppearanceTransition(
                isAppearing: false,
                viewController: selectedViewController,
                animated: animated
            )
        }
    }

    func viewDidDisappear(_: Bool) {
        appearanceState = .disappeared
        if let selectedViewController = selectedViewController {
            delegate?.endAppearanceTransition(viewController: selectedViewController)
        }
    }

    func willBeginDragging() {
        resetState()
    }

    func willEndDragging() {
        resetState()
    }

    func viewWillTransitionSize() {
        layoutsViews(keepContentOffset: false)
    }

    func didScroll(progress: CGFloat) {
        let currentDirection = PageViewDirection(progress: progress)

        // MARK: Begin scrolling

        if initialDirection == .none {
            switch currentDirection {
            case .forward:
                initialDirection = .forward
                onScroll(progress: progress)
                willScrollForward()
            case .reverse:
                initialDirection = .reverse
                onScroll(progress: progress)
                willScrollReverse()
            case .none:
                onScroll(progress: progress)
            }
        } else {
            // Check if the transition changed direction in the middle of
            // the transactions.
            if didReload == false {
                switch (currentDirection, initialDirection) {
                case (.reverse, .forward):
                    initialDirection = .reverse
                    cancelScrollForward()
                    onScroll(progress: progress)
                    willScrollReverse()
                case (.forward, .reverse):
                    initialDirection = .forward
                    cancelScrollReverse()
                    onScroll(progress: progress)
                    willScrollForward()
                default:
                    onScroll(progress: progress)
                }
            } else {
                onScroll(progress: progress)
            }
        }

        // MARK: Finished scrolling

        if didReload == false {
            if progress >= 1 {
                didReload = true
                didScrollForward()
            } else if progress <= -1 {
                didReload = true
                didScrollReverse()
            } else if progress == 0 {
                switch initialDirection {
                case .forward:
                    didReload = true
                    cancelScrollForward()
                case .reverse:
                    didReload = true
                    cancelScrollReverse()
                case .none:
                    break
                }
            }
        }
    }

    // MARK: - Private Methods

    private func selectViewController(_ viewController: UIViewController, animated: Bool) {
        let oldSelectedViewController = selectedViewController
        let newPreviousViewController = dataSource?.viewControllerBefore(viewController)
        let newNextViewController = dataSource?.viewControllerAfter(viewController)

        if let oldSelectedViewController = oldSelectedViewController {
            beginAppearanceTransition(false, for: oldSelectedViewController, animated: animated)
        }

        if viewController !== selectedViewController {
            beginAppearanceTransition(true, for: viewController, animated: animated)
        }

        if let oldPreviosViewController = previousViewController {
            if oldPreviosViewController !== viewController,
                oldPreviosViewController !== newPreviousViewController,
                oldPreviosViewController !== newNextViewController {
                delegate?.removeViewController(oldPreviosViewController)
            }
        }

        if let oldSelectedViewController = selectedViewController {
            if oldSelectedViewController !== newPreviousViewController,
                oldSelectedViewController !== newNextViewController {
                delegate?.removeViewController(oldSelectedViewController)
            }
        }

        if let oldNextViewController = nextViewController {
            if oldNextViewController !== viewController,
                oldNextViewController !== newPreviousViewController,
                oldNextViewController !== newNextViewController {
                delegate?.removeViewController(oldNextViewController)
            }
        }

        if let newPreviousViewController = newPreviousViewController {
            if newPreviousViewController !== selectedViewController,
                newPreviousViewController !== previousViewController,
                newPreviousViewController !== nextViewController {
                delegate?.addViewController(newPreviousViewController)
            }
        }

        if viewController !== nextViewController,
            viewController !== previousViewController {
            delegate?.addViewController(viewController)
        }

        if let newNextViewController = newNextViewController {
            if newNextViewController !== selectedViewController,
                newNextViewController !== previousViewController,
                newNextViewController !== nextViewController {
                delegate?.addViewController(newNextViewController)
            }
        }

        previousViewController = newPreviousViewController
        selectedViewController = viewController
        nextViewController = newNextViewController

        layoutsViews()

        if let oldSelectedViewController = oldSelectedViewController {
            endAppearanceTransition(for: oldSelectedViewController)
        }

        if viewController !== oldSelectedViewController {
            endAppearanceTransition(for: viewController)
        }
    }

    private func resetState() {
        if didReload {
            initialDirection = .none
        }
        didReload = false
    }

    private func onScroll(progress: CGFloat) {
        switch initialDirection {
        case .forward:
            if let selectedViewController = selectedViewController {
                delegate?.isScrolling(
                    from: selectedViewController,
                    to: nextViewController,
                    progress: progress
                )
            }
        case .reverse:
            if let selectedViewController = selectedViewController {
                delegate?.isScrolling(
                    from: selectedViewController,
                    to: previousViewController,
                    progress: progress
                )
            }
        case .none:
            break
        }
    }

    private func cancelScrollForward() {
        guard let selectedViewController = selectedViewController else { return }
        let oldNextViewController = nextViewController

        if let nextViewController = oldNextViewController {
            beginAppearanceTransition(true, for: selectedViewController, animated: true)
            beginAppearanceTransition(false, for: nextViewController, animated: true)
        }

        if didSelect {
            let newNextViewController = dataSource?.viewControllerAfter(selectedViewController)
            if let oldNextViewController = oldNextViewController {
                delegate?.removeViewController(oldNextViewController)
            }
            if let newNextViewController = newNextViewController {
                delegate?.addViewController(newNextViewController)
            }
            nextViewController = newNextViewController
            didSelect = false
            layoutsViews()
        }

        if let oldNextViewController = oldNextViewController {
            endAppearanceTransition(for: selectedViewController)
            endAppearanceTransition(for: oldNextViewController)
            delegate?.didFinishScrolling(
                from: selectedViewController,
                to: oldNextViewController,
                transitionSuccessful: false
            )
        }
    }

    private func cancelScrollReverse() {
        guard let selectedViewController = selectedViewController else { return }
        let oldPreviousViewController = previousViewController

        if let previousViewController = oldPreviousViewController {
            beginAppearanceTransition(true, for: selectedViewController, animated: true)
            beginAppearanceTransition(false, for: previousViewController, animated: true)
        }

        if didSelect {
            let newPreviousViewController = dataSource?.viewControllerBefore(selectedViewController)
            if let oldPreviousViewController = oldPreviousViewController {
                delegate?.removeViewController(oldPreviousViewController)
            }
            if let newPreviousViewController = newPreviousViewController {
                delegate?.addViewController(newPreviousViewController)
            }
            previousViewController = newPreviousViewController
            didSelect = false
            layoutsViews()
        }

        if let oldPreviousViewController = oldPreviousViewController {
            endAppearanceTransition(for: selectedViewController)
            endAppearanceTransition(for: oldPreviousViewController)
            delegate?.didFinishScrolling(
                from: selectedViewController,
                to: oldPreviousViewController,
                transitionSuccessful: false
            )
        }
    }

    private func willScrollForward() {
        if let selectedViewController = selectedViewController,
            let nextViewController = nextViewController {
            delegate?.willScroll(from: selectedViewController, to: nextViewController)
            beginAppearanceTransition(true, for: nextViewController, animated: true)
            beginAppearanceTransition(false, for: selectedViewController, animated: true)
        }
    }

    private func willScrollReverse() {
        if let selectedViewController = selectedViewController,
            let previousViewController = previousViewController {
            delegate?.willScroll(from: selectedViewController, to: previousViewController)
            beginAppearanceTransition(true, for: previousViewController, animated: true)
            beginAppearanceTransition(false, for: selectedViewController, animated: true)
        }
    }

    private func didScrollForward() {
        guard
            let oldSelectedViewController = selectedViewController,
            let oldNextViewController = nextViewController else { return }

        delegate?.didFinishScrolling(
            from: oldSelectedViewController,
            to: oldNextViewController,
            transitionSuccessful: true
        )

        let newNextViewController = dataSource?.viewControllerAfter(oldNextViewController)

        if let oldPreviousViewController = previousViewController {
            if oldPreviousViewController !== newNextViewController {
                delegate?.removeViewController(oldPreviousViewController)
            }
        }

        if let newNextViewController = newNextViewController {
            if newNextViewController !== previousViewController {
                delegate?.addViewController(newNextViewController)
            }
        }

        if didSelect {
            let newPreviousViewController = dataSource?.viewControllerBefore(oldNextViewController)
            if let oldSelectedViewController = selectedViewController {
                delegate?.removeViewController(oldSelectedViewController)
            }
            if let newPreviousViewController = newPreviousViewController {
                delegate?.addViewController(newPreviousViewController)
            }
            previousViewController = newPreviousViewController
            didSelect = false
        } else {
            previousViewController = oldSelectedViewController
        }

        selectedViewController = oldNextViewController
        nextViewController = newNextViewController

        layoutsViews()

        endAppearanceTransition(for: oldSelectedViewController)
        endAppearanceTransition(for: oldNextViewController)
    }

    private func didScrollReverse() {
        guard
            let oldSelectedViewController = selectedViewController,
            let oldPreviousViewController = previousViewController else { return }

        delegate?.didFinishScrolling(
            from: oldSelectedViewController,
            to: oldPreviousViewController,
            transitionSuccessful: true
        )

        let newPreviousViewController = dataSource?.viewControllerBefore(oldPreviousViewController)

        if let oldNextViewController = nextViewController {
            if oldNextViewController !== newPreviousViewController {
                delegate?.removeViewController(oldNextViewController)
            }
        }

        if let newPreviousViewController = newPreviousViewController {
            if newPreviousViewController !== nextViewController {
                delegate?.addViewController(newPreviousViewController)
            }
        }

        if didSelect {
            let newNextViewController = dataSource?.viewControllerAfter(oldPreviousViewController)
            if let oldSelectedViewController = selectedViewController {
                delegate?.removeViewController(oldSelectedViewController)
            }
            if let newNextViewController = newNextViewController {
                delegate?.addViewController(newNextViewController)
            }
            nextViewController = newNextViewController
            didSelect = false
        } else {
            nextViewController = oldSelectedViewController
        }

        previousViewController = newPreviousViewController
        selectedViewController = oldPreviousViewController

        layoutsViews()

        endAppearanceTransition(for: oldSelectedViewController)
        endAppearanceTransition(for: oldPreviousViewController)
    }

    private func layoutsViews(keepContentOffset: Bool = true) {
        var viewControllers: [UIViewController] = []

        if let previousViewController = previousViewController {
            viewControllers.append(previousViewController)
        }
        if let selectedViewController = selectedViewController {
            viewControllers.append(selectedViewController)
        }
        if let nextViewController = nextViewController {
            viewControllers.append(nextViewController)
        }

        delegate?.layoutViews(for: viewControllers, keepContentOffset: keepContentOffset)
    }

    private func beginAppearanceTransition(
        _ isAppearing: Bool,
        for viewController: UIViewController,
        animated: Bool
    ) {
        switch appearanceState {
        case .appeared:
            delegate?.beginAppearanceTransition(
                isAppearing: isAppearing,
                viewController: viewController,
                animated: animated
            )
        case let .appearing(animated):
            // Override the given animated flag with the animated flag of
            // the parent views appearance transition.
            delegate?.beginAppearanceTransition(
                isAppearing: isAppearing,
                viewController: viewController,
                animated: animated
            )
        case let .disappearing(animated):
            // When the parent view is about to disappear we always set
            // isAppearing to false.
            delegate?.beginAppearanceTransition(
                isAppearing: false,
                viewController: viewController,
                animated: animated
            )
        default:
            break
        }
    }

    private func endAppearanceTransition(for viewController: UIViewController) {
        guard case .appeared = appearanceState else { return }
        delegate?.endAppearanceTransition(viewController: viewController)
    }
}

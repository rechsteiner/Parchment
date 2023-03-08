import UIKit

/// PageViewController is a replacement for `UIPageViewController`
/// using `UIScrollView`. It provides detailed delegate methods, which
/// is the main issue with `UIPageViewController`.
public final class PageViewController: UIViewController {
    // MARK: Public Properties

    public weak var dataSource: PageViewControllerDataSource?
    public weak var delegate: PageViewControllerDelegate?

    public override var shouldAutomaticallyForwardAppearanceMethods: Bool {
        return false
    }

    /// The view controller before the selected view controller.
    public var beforeViewController: UIViewController? {
        return manager.previousViewController
    }

    /// The currently selected view controller. Can be `nil` if no view
    /// controller is selected.
    public var selectedViewController: UIViewController? {
        return manager.selectedViewController
    }

    /// The view controller after the selected view controller.
    private var afterViewController: UIViewController? {
        return manager.nextViewController
    }

    /// The underlying scroll view where the page view controllers are
    /// added. Changing the properties on this scroll view might cause
    /// undefined behaviour.
    public private(set) lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.isPagingEnabled = true
        scrollView.autoresizingMask = [
            .flexibleTopMargin,
            .flexibleRightMargin,
            .flexibleBottomMargin,
            .flexibleLeftMargin,
        ]
        scrollView.scrollsToTop = false
        scrollView.bounces = true
        scrollView.translatesAutoresizingMaskIntoConstraints = true
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.showsVerticalScrollIndicator = false
        return scrollView
    }()

    public var options: PagingOptions {
        didSet {
            switch options.contentNavigationOrientation {
            case .vertical:
                scrollView.alwaysBounceHorizontal = false
                scrollView.alwaysBounceVertical = true
            case .horizontal:
                scrollView.alwaysBounceHorizontal = true
                scrollView.alwaysBounceVertical = false
            }
        }
    }

    // MARK: Private Properties

    private let manager = PageViewManager()

    /// The size of a single page.
    private var pageSize: CGFloat {
        switch options.contentNavigationOrientation {
        case .vertical:
            return view.bounds.height
        case .horizontal:
            return view.bounds.width
        }
    }

    /// The size of all the pages in the scroll view.
    private var contentSize: CGSize {
        switch options.contentNavigationOrientation {
        case .horizontal:
            return CGSize(
                width: CGFloat(manager.state.count) * view.bounds.width,
                height: view.bounds.height
            )
        case .vertical:
            return CGSize(
                width: view.bounds.width,
                height: CGFloat(manager.state.count) * view.bounds.height
            )
        }
    }

    /// The content offset of the scroll view, adjusted for the current
    /// navigation orientation.
    private var contentOffset: CGFloat {
        get {
            switch options.contentNavigationOrientation {
            case .horizontal:
                return scrollView.contentOffset.x
            case .vertical:
                return scrollView.contentOffset.y
            }
        }
        set {
            scrollView.contentOffset = point(newValue)
        }
    }

    private var isRightToLeft: Bool {
        switch options.contentNavigationOrientation {
        case .vertical:
            return false
        case .horizontal:
            if UIView.userInterfaceLayoutDirection(for: view.semanticContentAttribute) == .rightToLeft {
                return true
            } else {
                return false
            }
        }
    }

    public init(options: PagingOptions = PagingOptions()) {
        self.options = options
        super.init(nibName: nil, bundle: nil)
        manager.delegate = self
        manager.dataSource = self
    }

    public required init?(coder: NSCoder) {
        options = PagingOptions()
        super.init(coder: coder)
        manager.delegate = self
        manager.dataSource = self
    }

    public override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(scrollView)
        scrollView.delegate = self
        scrollView.contentInsetAdjustmentBehavior = .never
    }

    public override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        scrollView.frame = view.bounds
        manager.viewWillLayoutSubviews()
    }

    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        manager.viewWillAppear(animated)
    }

    public override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        manager.viewDidAppear(animated)
    }

    public override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        manager.viewWillDisappear(animated)
    }

    public override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        manager.viewDidDisappear(animated)
    }

    public override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        coordinator.animate(alongsideTransition: { _ in
            self.manager.viewWillTransitionSize()
        })
    }

    // MARK: Public Methods

    public func selectViewController(_ viewController: UIViewController, direction: PageViewDirection, animated: Bool = true) {
        manager.select(viewController: viewController, direction: direction, animated: animated)
    }

    public func selectNext(animated: Bool) {
        manager.selectNext(animated: animated)
    }

    public func selectPrevious(animated: Bool) {
        manager.selectPrevious(animated: animated)
    }

    public func removeAll() {
        manager.removeAll()
    }

    // MARK: Private Methods

    private func setContentOffset(_ value: CGFloat, animated: Bool) {
        scrollView.setContentOffset(point(value), animated: animated)
    }

    private func point(_ value: CGFloat) -> CGPoint {
        switch options.contentNavigationOrientation {
        case .horizontal:
            return CGPoint(x: value, y: 0)
        case .vertical:
            return CGPoint(x: 0, y: value)
        }
    }
}

// MARK: - UIScrollViewDelegate

extension PageViewController: UIScrollViewDelegate {
    public func scrollViewWillBeginDragging(_: UIScrollView) {
        manager.willBeginDragging()
    }

    public func scrollViewWillEndDragging(_: UIScrollView, withVelocity _: CGPoint, targetContentOffset _: UnsafeMutablePointer<CGPoint>) {
        manager.willEndDragging()
    }

    public func scrollViewDidScroll(_: UIScrollView) {
        let distance = pageSize
        var progress: CGFloat

        if isRightToLeft {
            switch manager.state {
            case .last, .empty, .single:
                progress = -(contentOffset / distance)
            case .center, .first:
                progress = -((contentOffset - distance) / distance)
            }
        } else {
            switch manager.state {
            case .first, .empty, .single:
                progress = contentOffset / distance
            case .center, .last:
                progress = (contentOffset - distance) / distance
            }
        }

        manager.didScroll(progress: progress)
    }
}

// MARK: - PageViewManagerDataSource

extension PageViewController: PageViewManagerDataSource {
    func viewControllerAfter(_ viewController: UIViewController) -> UIViewController? {
        return dataSource?.pageViewController(self, viewControllerAfterViewController: viewController)
    }

    func viewControllerBefore(_ viewController: UIViewController) -> UIViewController? {
        return dataSource?.pageViewController(self, viewControllerBeforeViewController: viewController)
    }
}

// MARK: - PageViewManagerDelegate

extension PageViewController: PageViewManagerDelegate {
    func scrollForward() {
        if isRightToLeft {
            switch manager.state {
            case .first, .center:
                setContentOffset(.zero, animated: true)
            case .single, .empty, .last:
                break
            }
        } else {
            switch manager.state {
            case .first:
                setContentOffset(pageSize, animated: true)
            case .center:
                setContentOffset(pageSize * 2, animated: true)
            case .single, .empty, .last:
                break
            }
        }
    }

    func scrollReverse() {
        if isRightToLeft {
            switch manager.state {
            case .last:
                setContentOffset(pageSize, animated: true)
            case .center:
                setContentOffset(pageSize * 2, animated: true)
            case .single, .empty, .first:
                break
            }
        } else {
            switch manager.state {
            case .last, .center:
                scrollView.setContentOffset(.zero, animated: true)
            case .single, .empty, .first:
                break
            }
        }
    }

    func layoutViews(for viewControllers: [UIViewController], keepContentOffset: Bool) {
        let viewControllers = isRightToLeft ? viewControllers.reversed() : viewControllers

        // Need to trigger a layout here to ensure that the scroll view
        // bounds is updated before we use its frame for calculations.
        view.layoutIfNeeded()

        for (index, viewController) in viewControllers.enumerated() {
            switch options.contentNavigationOrientation {
            case .horizontal:
                viewController.view.frame = CGRect(
                    x: CGFloat(index) * scrollView.bounds.width,
                    y: 0,
                    width: scrollView.bounds.width,
                    height: scrollView.bounds.height
                )
            case .vertical:
                viewController.view.frame = CGRect(
                    x: 0,
                    y: CGFloat(index) * scrollView.bounds.height,
                    width: scrollView.bounds.width,
                    height: scrollView.bounds.height
                )
            }
        }

        // When updating the content offset we need to account for the
        // current content offset as well. This ensures that the selected
        // page is fully centered when swiping so fast that you get the
        // bounce effect in the scroll view.
        var diff: CGFloat = 0
        if keepContentOffset {
            if contentOffset > pageSize * 2 {
                diff = contentOffset - pageSize * 2
            } else if contentOffset > pageSize, contentOffset < pageSize * 2 {
                diff = contentOffset - pageSize
            } else if contentOffset < pageSize, contentOffset < 0 {
                diff = contentOffset
            }
        }

        // Need to set content size before updating content offset. If not
        // the views will be misplaced when overshooting.
        scrollView.contentSize = contentSize

        if isRightToLeft {
            switch manager.state {
            case .first, .center:
                contentOffset = pageSize + diff
            case .single, .empty, .last:
                contentOffset = diff
            }
        } else {
            switch manager.state {
            case .first, .single, .empty:
                contentOffset = diff
            case .last, .center:
                contentOffset = pageSize + diff
            }
        }
    }

    func addViewController(_ viewController: UIViewController) {
        viewController.willMove(toParent: self)
        addChild(viewController)
        scrollView.addSubview(viewController.view)
        viewController.didMove(toParent: self)
    }

    func removeViewController(_ viewController: UIViewController) {
        viewController.willMove(toParent: nil)
        viewController.removeFromParent()
        viewController.view.removeFromSuperview()
        viewController.didMove(toParent: nil)
    }

    func beginAppearanceTransition(isAppearing: Bool, viewController: UIViewController, animated: Bool) {
        viewController.beginAppearanceTransition(isAppearing, animated: animated)
    }

    func endAppearanceTransition(viewController: UIViewController) {
        viewController.endAppearanceTransition()
    }

    func willScroll(
        from selectedViewController: UIViewController,
        to destinationViewController: UIViewController
    ) {
        delegate?.pageViewController(
            self,
            willStartScrollingFrom: selectedViewController,
            destinationViewController: destinationViewController
        )
    }

    func didFinishScrolling(
        from selectedViewController: UIViewController,
        to destinationViewController: UIViewController,
        transitionSuccessful: Bool
    ) {
        delegate?.pageViewController(
            self,
            didFinishScrollingFrom: selectedViewController,
            destinationViewController: destinationViewController,
            transitionSuccessful: transitionSuccessful
        )
    }

    func isScrolling(
        from selectedViewController: UIViewController,
        to destinationViewController: UIViewController?,
        progress: CGFloat
    ) {
        delegate?.pageViewController(
            self,
            isScrollingFrom: selectedViewController,
            destinationViewController: destinationViewController,
            progress: progress
        )
    }
}

import UIKit

/// A view controller that lets you to page between views while
/// showing menu items that scrolls along with the content.
///
/// The data source object is responsible for actually generating the
/// `PagingItem` as well as allocating the view controller that
/// corresponds to each item. See `PagingViewControllerDataSource`.
///
/// After providing a data source you need to call
/// `select(pagingItem:animated:)` to set the initial view controller.
/// You can also use the same method to programmatically navigate to
/// other view controllers.
open class PagingViewController:
    UIViewController,
    UICollectionViewDelegate,
    PageViewControllerDataSource,
    PageViewControllerDelegate {
    // MARK: Public Properties

    /// The size for each of the menu items. _Default:
    /// .sizeToFit(minWidth: 150, height: 40)_
    public var menuItemSize: PagingMenuItemSize {
        get { return options.menuItemSize }
        set { options.menuItemSize = newValue }
    }

    /// Determine the spacing between the menu items. _Default: 0_
    public var menuItemSpacing: CGFloat {
        get { return options.menuItemSpacing }
        set { options.menuItemSpacing = newValue }
    }

    /// Determine the horizontal constraints of menu item label. _Default: 20_
    public var menuItemLabelSpacing: CGFloat {
        get { return options.menuItemLabelSpacing }
        set { options.menuItemLabelSpacing = newValue }
    }

    /// Determine the insets at around all the menu items. _Default:
    /// UIEdgeInsets.zero_
    public var menuInsets: UIEdgeInsets {
        get { return options.menuInsets }
        set { options.menuInsets = newValue }
    }

    /// Determine whether the menu items should be centered when all the
    /// items can fit within the bounds of the view. _Default: .left_
    public var menuHorizontalAlignment: PagingMenuHorizontalAlignment {
        get { return options.menuHorizontalAlignment }
        set { options.menuHorizontalAlignment = newValue }
    }

    /// Determine the position of the menu relative to the content.
    /// _Default: .top_
    public var menuPosition: PagingMenuPosition {
        get { return options.menuPosition }
        set { options.menuPosition = newValue }
    }

    /// Determine the transition behaviour of menu items while scrolling
    /// the content. _Default: .scrollAlongside_
    public var menuTransition: PagingMenuTransition {
        get { return options.menuTransition }
        set { options.menuTransition = newValue }
    }

    /// Determine how users can interact with the menu items.
    /// _Default: .scrolling_
    public var menuInteraction: PagingMenuInteraction {
        get { return options.menuInteraction }
        set { options.menuInteraction = newValue }
    }

    /// The class type for collection view layout. Override this if you
    /// want to use your own subclass of the layout. Setting this
    /// property will initialize the new layout type and update the
    /// collection view.
    /// _Default: PagingCollectionViewLayout.self_
    public var menuLayoutClass: PagingCollectionViewLayout.Type {
        get { return options.menuLayoutClass }
        set { options.menuLayoutClass = newValue }
    }

    /// Determine how the selected menu item should be aligned when it
    /// is selected. Effectivly the same as the
    /// `UICollectionViewScrollPosition`. _Default: .preferCentered_
    public var selectedScrollPosition: PagingSelectedScrollPosition {
        get { return options.selectedScrollPosition }
        set { options.selectedScrollPosition = newValue }
    }

    /// Add an indicator view to the selected menu item. The indicator
    /// width will be equal to the selected menu items width. Insets
    /// only apply horizontally. _Default: .visible_
    public var indicatorOptions: PagingIndicatorOptions {
        get { return options.indicatorOptions }
        set { options.indicatorOptions = newValue }
    }

    /// The class type for the indicator view. Override this if you want
    /// your use your own subclass of PagingIndicatorView. _Default:
    /// PagingIndicatorView.self_
    public var indicatorClass: PagingIndicatorView.Type {
        get { return options.indicatorClass }
        set { options.indicatorClass = newValue }
    }

    /// Determine the color of the indicator view.
    public var indicatorColor: UIColor {
        get { return options.indicatorColor }
        set { options.indicatorColor = newValue }
    }

    /// Add a border at the bottom of the menu items. The border will be
    /// as wide as all the menu items. Insets only apply horizontally.
    /// _Default: .visible_
    public var borderOptions: PagingBorderOptions {
        get { return options.borderOptions }
        set { options.borderOptions = newValue }
    }

    /// The class type for the border view. Override this if you want
    /// your use your own subclass of PagingBorderView. _Default:
    /// PagingBorderView.self_
    public var borderClass: PagingBorderView.Type {
        get { return options.borderClass }
        set { options.borderClass = newValue }
    }

    /// Determine the color of the border view.
    public var borderColor: UIColor {
        get { return options.borderColor }
        set { options.borderColor = newValue }
    }

    /// Updates the content inset for the menu items based on the
    /// .safeAreaInsets property. _Default: true_
    public var includeSafeAreaInsets: Bool {
        get { return options.includeSafeAreaInsets }
        set { options.includeSafeAreaInsets = newValue }
    }

    /// The font used for title label on the menu items.
    public var font: UIFont {
        get { return options.font }
        set { options.font = newValue }
    }

    /// The font used for the currently selected menu item.
    public var selectedFont: UIFont {
        get { return options.selectedFont }
        set { options.selectedFont = newValue }
    }

    /// The color of the title label on the menu items.
    public var textColor: UIColor {
        get { return options.textColor }
        set { options.textColor = newValue }
    }

    /// The text color for the currently selected menu item.
    public var selectedTextColor: UIColor {
        get { return options.selectedTextColor }
        set { options.selectedTextColor = newValue }
    }

    /// The background color for the menu items.
    public var backgroundColor: UIColor {
        get { return options.backgroundColor }
        set { options.backgroundColor = newValue }
    }

    /// The background color for the selected menu item.
    public var selectedBackgroundColor: UIColor {
        get { return options.selectedBackgroundColor }
        set { options.selectedBackgroundColor = newValue }
    }

    /// The background color for the view behind the menu items.
    public var menuBackgroundColor: UIColor {
        get { return options.menuBackgroundColor }
        set { options.menuBackgroundColor = newValue }
    }

    /// The scroll navigation orientation of the content in the page
    /// view controller. _Default: .horizontal_
    public var contentNavigationOrientation: PagingNavigationOrientation {
        get { return options.contentNavigationOrientation }
        set { options.contentNavigationOrientation = newValue }
    }

    /// Determine how users can interact with the page view controller.
    /// _Default: .scrolling_
    public var contentInteraction: PagingContentInteraction {
      get { return options.contentInteraction }
      set { 
        options.contentInteraction = newValue
        configureContentInteraction()
      }
    }

    /// The current state of the menu items. Indicates whether an item
    /// is currently selected or is scrolling to another item. Can be
    /// used to get the distance and progress of any ongoing transition.
    public var state: PagingState {
        return pagingController.state
    }

    /// The `PagingItem`'s that are currently visible in the collection
    /// view. The items in this array are not necessarily the same as
    /// the `visibleCells` property on `UICollectionView`.
    public var visibleItems: PagingItems {
        return pagingController.visibleItems
    }

    /// The data source is responsible for providing the `PagingItem`s
    /// that are displayed in the menu. The `PagingItem` protocol is
    /// used to generate menu items for all the view controllers,
    /// without having to actually allocate them before they are needed.
    /// Use this property when you have a fixed amount of view
    /// controllers. If you need to support infinitely large data
    /// sources, use the infiniteDataSource property instead.
    public weak var dataSource: PagingViewControllerDataSource? {
        didSet {
            configureDataSource()
        }
    }

    /// A data source that can be used when you need to support
    /// infinitely large data source by returning the `PagingItem`
    /// before or after a given `PagingItem`. The `PagingItem` protocol
    /// is used to generate menu items for all the view controllers,
    /// without having to actually allocate them before they are needed.
    public weak var infiniteDataSource: PagingViewControllerInfiniteDataSource?

    /// Use this delegate to get notified when the user is scrolling or
    /// when an item is selected.
    public weak var delegate: PagingViewControllerDelegate?

    /// Use this delegate if you want to manually control the width of
    /// your menu items. Self-sizing cells is not supported at the
    /// moment, so you have to use this if you have a custom cell that
    /// you want to size based on its content.
    public weak var sizeDelegate: PagingViewControllerSizeDelegate? {
        didSet {
            pagingController.sizeDelegate = self
        }
    }

    /// A custom collection view layout that lays out all the menu items
    /// horizontally. You can customize the behavior of the layout by
    /// setting the customization properties on `PagingViewController`.
    /// You can also use your own subclass of the layout by defining the
    /// `menuLayoutClass` property.
    public private(set) var collectionViewLayout: PagingCollectionViewLayout

    /// Used to display the menu items that scrolls along with the
    /// content. Using a collection view means you can create custom
    /// cells that display pretty much anything. By default, scrolling
    /// is enabled in the collection view.
    public let collectionView: UICollectionView

    /// Used to display the view controllers that you are paging between.
    public let pageViewController: PageViewController

    /// An instance that stores all the customization so that it's
    /// easier to share between other classes.
    public private(set) var options: PagingOptions {
        didSet {
            if options.menuLayoutClass != oldValue.menuLayoutClass {
                let layout = createLayout(layout: options.menuLayoutClass.self)
                collectionViewLayout = layout
                collectionViewLayout.options = options
                collectionView.setCollectionViewLayout(layout, animated: false)
            } else {
                collectionViewLayout.options = options
            }

            pageViewController.options = options
            pagingController.options = options
            pagingView.options = options
        }
    }

    // MARK: Private Properties

    private let pagingController: PagingController
    private var didLayoutSubviews: Bool = false

    private var pagingView: PagingView {
        return view as! PagingView
    }

    private enum DataSourceReference {
        case `static`(PagingStaticDataSource)
        case finite(PagingFiniteDataSource)
        case none
    }

    /// Used to keep a strong reference to the internal data sources.
    private var dataSourceReference: DataSourceReference = .none

    // MARK: Initializers

    /// Creates an instance of `PagingViewController`. You need to call
    /// `select(pagingItem:animated:)` in order to set the initial view
    /// controller before any items become visible.
    ///
    /// - Parameter options: An object with configuration options. These
    /// parameters are also available directly on `PagingViewController`.
    public init(options: PagingOptions = PagingOptions()) {
        self.options = options
        pagingController = PagingController(options: options)
        pageViewController = PageViewController(options: options)
        collectionViewLayout = createLayout(layout: options.menuLayoutClass.self)
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: collectionViewLayout)
        super.init(nibName: nil, bundle: nil)
        collectionView.delegate = self
        collectionViewLayout.options = options
        configurePagingController()

        // Register default cell
        register(PagingTitleCell.self, for: PagingIndexItem.self)
    }

    /// Creates an instance of `PagingViewController`. The first view
    /// controller will be selected by default.
    ///
    /// - Parameters:
    ///   - options: An object with configuration options. These
    ///   parameters are also available directly on `PagingViewController`.
    ///   - viewControllers: An array of view controllers that you want
    /// to display. The title of the view controllers will be used to
    /// generate the menu items.
    public convenience init(
        options: PagingOptions = PagingOptions(),
        viewControllers: [UIViewController]
    ) {
        self.init(options: options)
        configureDataSource(for: viewControllers)
    }

    /// Creates an instance of `PagingViewController`.
    ///
    /// - Parameter coder: An unarchiver object.
    public required init?(coder: NSCoder) {
        options = PagingOptions()
        pagingController = PagingController(options: options)
        pageViewController = PageViewController(options: options)
        collectionViewLayout = createLayout(layout: options.menuLayoutClass.self)
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: collectionViewLayout)
        super.init(coder: coder)
        collectionView.delegate = self
        configurePagingController()
    }

    // MARK: Public Methods

    /// Reload the data for the menu items. This method will not reload
    /// the view controllers.
    open func reloadMenu() {
        var updatedItems: [PagingItem] = []

        switch dataSourceReference {
        case let .static(dataSource):
            dataSource.reloadItems()
            updatedItems = dataSource.items
        case let .finite(dataSource):
            dataSource.items = itemsForFiniteDataSource()
            updatedItems = dataSource.items
        default:
            break
        }

        if let previouslySelected = state.currentPagingItem,
            let pagingItem = updatedItems.first(where: { $0.isEqual(to: previouslySelected) }) {
            pagingController.reloadMenu(around: pagingItem)
        } else if let firstItem = updatedItems.first {
            pagingController.reloadMenu(around: firstItem)
        } else {
            pagingController.removeAll()
        }
    }

    /// Reload data for all the menu items. This will keep the
    /// previously selected item if it's still part of the updated data.
    /// If not, it will select the first item in the list. This method
    /// will not work when using PagingViewControllerInfiniteDataSource
    /// as we then need to know what the initial item should be. You
    /// should use the reloadData(around:) method in that case.
    open func reloadData() {
        var updatedItems: [PagingItem] = []

        switch dataSourceReference {
        case let .static(dataSource):
            dataSource.reloadItems()
            updatedItems = dataSource.items
        case let .finite(dataSource):
            dataSource.items = itemsForFiniteDataSource()
            updatedItems = dataSource.items
        default:
            break
        }

        if let previouslySelected = state.currentPagingItem,
            let pagingItem = updatedItems.first(where: { $0.isEqual(to: previouslySelected) }) {
            pagingController.reloadData(around: pagingItem)
        } else if let firstItem = updatedItems.first {
            pagingController.reloadData(around: firstItem)
        } else {
            pagingController.removeAll()
        }
    }

    /// Reload data around given paging item. This will set the given
    /// paging item as selected and generate new items around it. This
    /// will also reload the view controllers displayed in the page view
    /// controller. You need to use this method to reload data when
    /// using PagingViewControllerInfiniteDataSource as we need to know
    /// the initial item.
    ///
    /// - Parameter pagingItem: The `PagingItem` that will be selected
    /// after the data reloads.
    open func reloadData(around pagingItem: PagingItem) {
        switch dataSourceReference {
        case let .static(dataSource):
            dataSource.reloadItems()
        case let .finite(dataSource):
            dataSource.items = itemsForFiniteDataSource()
        default:
            break
        }
        pagingController.reloadData(around: pagingItem)
    }

    /// Selects a given paging item. This need to be called after you
    /// initilize the `PagingViewController` to set the initial
    /// `PagingItem`. This can be called both before and after the view
    /// has been loaded. You can also use this to programmatically
    /// navigate to another `PagingItem`.
    ///
    /// - Parameter pagingItem: The `PagingItem` to be displayed.
    /// - Parameter animated: A boolean value that indicates whether
    /// the transtion should be animated. Default is false.
    open func select(pagingItem: PagingItem, animated: Bool = false) {
        pagingController.select(pagingItem: pagingItem, animated: animated)
    }

    /// Selects the paging item at a given index. This can be called
    /// both before and after the view has been loaded.
    ///
    /// - Parameter index: The index of the `PagingItem` to be displayed.
    /// - Parameter animated: A boolean value that indicates whether
    /// the transtion should be animated. Default is false.
    open func select(index: Int, animated: Bool = false) {
        switch dataSourceReference {
        case let .static(dataSource):
            let pagingItem = dataSource.items[index]
            pagingController.select(pagingItem: pagingItem, animated: animated)
        case let .finite(dataSource):
            let pagingItem = dataSource.items[index]
            pagingController.select(pagingItem: pagingItem, animated: animated)
        case .none:
            fatalError("select(index:animated:): You need to set the dataSource property to use this method")
        }
    }

    open override func loadView() {
        view = PagingView(
            options: options,
            collectionView: collectionView,
            pageView: pageViewController.view
        )
    }

    open override func viewDidLoad() {
        super.viewDidLoad()

        addChild(pageViewController)
        pagingView.configure()
        pageViewController.didMove(toParent: self)

        pageViewController.delegate = self
        pageViewController.dataSource = self
        configureContentInteraction()
    }

    open override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        // We need generate the menu items when the view appears for the
        // first time. Doing it in viewWillAppear does not work as the
        // safeAreaInsets will not be updated yet.
        if didLayoutSubviews == false {
            didLayoutSubviews = true
            pagingController.viewAppeared()
        }
    }

    open override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        coordinator.animate(alongsideTransition: { _ in
            self.pagingController.transitionSize()
    }, completion: nil)
    }

    /// Register cell class for paging cell
    /// - Parameter cellClass: paging cell's class
    /// - Parameter pagingItemType: paging item type for specifying cell identifier
    public func register(_ cellClass: AnyClass?, for pagingItemType: PagingItem.Type) {
        collectionView.register(cellClass, forCellWithReuseIdentifier: String(describing: pagingItemType))
    }

    /// Register nib for paging cell
    /// - Parameter nib: paging cell's nib
    /// - Parameter pagingItemType: paging item type for specifying cell identifier
    public func register(_ nib: UINib?, for pagingItemType: PagingItem.Type) {
        collectionView.register(nib, forCellWithReuseIdentifier: String(describing: pagingItemType))
    }

    // MARK: Private Methods

    private func configurePagingController() {
        pagingController.collectionView = collectionView
        pagingController.collectionViewLayout = collectionViewLayout
        pagingController.dataSource = self
        pagingController.delegate = self
        pagingController.options = options
    }

    private func itemsForFiniteDataSource() -> [PagingItem] {
        let numberOfItems = dataSource?.numberOfViewControllers(in: self) ?? 0
        var items: [PagingItem] = []

        for index in 0 ..< numberOfItems {
            if let item = dataSource?.pagingViewController(self, pagingItemAt: index) {
                items.append(item)
            }
        }

        return items
    }

    private func configureDataSource() {
        let dataSource = PagingFiniteDataSource()
        dataSource.items = itemsForFiniteDataSource()
        dataSource.viewControllerForIndex = { [unowned self] in
            self.dataSource?.pagingViewController(self, viewControllerAt: $0)
        }

        dataSourceReference = .finite(dataSource)
        infiniteDataSource = dataSource

        if let firstItem = dataSource.items.first {
            pagingController.select(pagingItem: firstItem, animated: false)
        }
    }

    private func configureDataSource(for viewControllers: [UIViewController]) {
        let dataSource = PagingStaticDataSource(viewControllers: viewControllers)
        dataSourceReference = .static(dataSource)
        infiniteDataSource = dataSource
        if let pagingItem = dataSource.items.first {
            pagingController.select(pagingItem: pagingItem, animated: false)
        }
    }

    private func configureContentInteraction() {
        switch contentInteraction {
        case .scrolling:
            pageViewController.scrollView.isScrollEnabled = true
        case .none:
            pageViewController.scrollView.isScrollEnabled = false
        }
    }

    // MARK: UIScrollViewDelegate

    open func scrollViewDidScroll(_: UIScrollView) {
        pagingController.menuScrolled()
    }

    open func scrollViewWillBeginDragging(_: UIScrollView) {
        return
    }

    open func scrollViewWillEndDragging(_: UIScrollView, withVelocity _: CGPoint, targetContentOffset _: UnsafeMutablePointer<CGPoint>) {
        return
    }

    open func scrollViewDidEndDragging(_: UIScrollView, willDecelerate _: Bool) {
        return
    }

    open func scrollViewDidEndScrollingAnimation(_: UIScrollView) {
        return
    }

    open func scrollViewWillBeginDecelerating(_: UIScrollView) {
        return
    }

    open func scrollViewDidEndDecelerating(_: UIScrollView) {
        return
    }

    // MARK: UICollectionViewDelegate

    open func collectionView(_: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let pagingItem = pagingController.visibleItems.pagingItem(for: indexPath)

        guard let currentPagingItem = state.currentPagingItem else { return }
        delegate?.pagingViewController(self, didSelectItem: pagingItem, didSelectPagingCellAt: indexPath.row, currentItem: currentPagingItem)
        
        pagingController.select(indexPath: indexPath, animated: true)
    }

    open func collectionView(_: UICollectionView, targetContentOffsetForProposedContentOffset proposedContentOffset: CGPoint) -> CGPoint {
        return proposedContentOffset
    }

    open func collectionView(_: UICollectionView, didUnhighlightItemAt _: IndexPath) {
        return
    }

    open func collectionView(_: UICollectionView, didHighlightItemAt _: IndexPath) {
        return
    }

    open func collectionView(_: UICollectionView, didDeselectItemAt _: IndexPath) {
        return
    }

    open func collectionView(_: UICollectionView, willDisplay _: UICollectionViewCell, forItemAt _: IndexPath) {
        return
    }

    open func collectionView(_: UICollectionView, didEndDisplaying _: UICollectionViewCell, forItemAt _: IndexPath) {
        return
    }

    // MARK: PageViewControllerDataSource

    open func pageViewController(_: PageViewController, viewControllerBeforeViewController _: UIViewController) -> UIViewController? {
        guard
            let dataSource = infiniteDataSource,
            let currentPagingItem = state.currentPagingItem,
            let pagingItem = dataSource.pagingViewController(self, itemBefore: currentPagingItem) else { return nil }

        return dataSource.pagingViewController(self, viewControllerFor: pagingItem)
    }

    open func pageViewController(_: PageViewController, viewControllerAfterViewController _: UIViewController) -> UIViewController? {
        guard
            let dataSource = infiniteDataSource,
            let currentPagingItem = state.currentPagingItem,
            let pagingItem = dataSource.pagingViewController(self, itemAfter: currentPagingItem) else { return nil }

        return dataSource.pagingViewController(self, viewControllerFor: pagingItem)
    }

    // MARK: PageViewControllerDelegate

    open func pageViewController(_: PageViewController, isScrollingFrom startingViewController: UIViewController, destinationViewController: UIViewController?, progress: CGFloat) {
        guard let currentPagingItem = state.currentPagingItem else { return }

        pagingController.contentScrolled(progress: progress)
        delegate?.pagingViewController(
            self,
            isScrollingFromItem: currentPagingItem,
            toItem: state.upcomingPagingItem,
            startingViewController: startingViewController,
            destinationViewController: destinationViewController,
            progress: progress
        )
    }

    open func pageViewController(_: PageViewController, willStartScrollingFrom startingViewController: UIViewController, destinationViewController: UIViewController) {
        if let upcomingPagingItem = state.upcomingPagingItem {
            delegate?.pagingViewController(
                self,
                willScrollToItem: upcomingPagingItem,
                startingViewController: startingViewController,
                destinationViewController: destinationViewController
            )
        }
    }

    open func pageViewController(_: PageViewController, didFinishScrollingFrom startingViewController: UIViewController, destinationViewController: UIViewController, transitionSuccessful: Bool) {
        if transitionSuccessful {
            pagingController.contentFinishedScrolling()
        }

        if let currentPagingItem = state.currentPagingItem {
            delegate?.pagingViewController(
                self,
                didScrollToItem: currentPagingItem,
                startingViewController: startingViewController,
                destinationViewController: destinationViewController,
                transitionSuccessful: transitionSuccessful
            )
        }
    }
}

extension PagingViewController: PagingMenuDataSource {
    public func pagingItemBefore(pagingItem: PagingItem) -> PagingItem? {
        return infiniteDataSource?.pagingViewController(self, itemBefore: pagingItem)
    }

    public func pagingItemAfter(pagingItem: PagingItem) -> PagingItem? {
        return infiniteDataSource?.pagingViewController(self, itemAfter: pagingItem)
    }
}

extension PagingViewController: PagingControllerSizeDelegate {
    func width(for pagingItem: PagingItem, isSelected: Bool) -> CGFloat {
        return sizeDelegate?.pagingViewController(self, widthForPagingItem: pagingItem, isSelected: isSelected) ?? 0
    }
}

extension PagingViewController: PagingMenuDelegate {
    public func selectContent(pagingItem: PagingItem, direction: PagingDirection, animated: Bool) {
        guard let dataSource = infiniteDataSource else { return }

        switch direction {
        case .forward(true):
            pageViewController.selectNext(animated: animated)

        case .reverse(true):
            pageViewController.selectPrevious(animated: animated)

        default:
            let viewController = dataSource.pagingViewController(self, viewControllerFor: pagingItem)
            pageViewController.selectViewController(
                viewController,
                direction: PageViewDirection(from: direction),
                animated: animated
            )
        }
    }

    public func removeContent() {
        pageViewController.removeAll()
    }
}

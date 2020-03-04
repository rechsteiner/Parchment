import UIKit

open class PagingMenuView: UIView {
  
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
  open override var backgroundColor: UIColor? {
    didSet {
      if let backgroundColor = backgroundColor {
        options.backgroundColor = backgroundColor
      }
    }
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
  
  public weak var delegate: PagingMenuDelegate? {
    didSet {
      pagingController.delegate = delegate
    }
  }
  
  public weak var dataSource: PagingMenuDataSource? {
    didSet {
      pagingController.dataSource = dataSource
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
  
  /// A custom collection view layout that lays out all the menu items
  /// horizontally. You can customize the behavior of the layout by
  /// setting the customization properties on `PagingViewController`.
  /// You can also use your own subclass of the layout by defining the
  /// `menuLayoutClass` property.
  public private(set) lazy var collectionViewLayout: PagingCollectionViewLayout = {
    return createLayout(layout: options.menuLayoutClass.self)
  }()
  
  /// Used to display the menu items that scrolls along with the
  /// content. Using a collection view means you can create custom
  /// cells that display pretty much anything. By default, scrolling
  /// is enabled in the collection view.
  public lazy var collectionView: UICollectionView = {
    return UICollectionView(frame: .zero, collectionViewLayout: collectionViewLayout)
  }()
  
  /// An instance that stores all the customization so that it's
  /// easier to share between other classes.
  public private(set) var options = PagingOptions() {
    didSet {
      if options.menuLayoutClass != oldValue.menuLayoutClass {
        let layout = createLayout(layout: options.menuLayoutClass.self)
        collectionViewLayout = layout
        collectionViewLayout.options = options
        collectionView.setCollectionViewLayout(layout, animated: false)
      }
      else {
        collectionViewLayout.options = options
      }
      
      pagingController.options = options
    }
  }
  
  // MARK: Private Properties
  
  private lazy var pagingController = PagingController(options: options)
  
  // MARK: Initializers
  
  /// Creates an instance of `PagingViewController`. You need to call
  /// `select(pagingItem:animated:)` in order to set the initial view
  /// controller before any items become visible.
  public override init(frame: CGRect) {
    super.init(frame: frame)
    configure()
  }
  
  required public init?(coder: NSCoder) {
    super.init(coder: coder)
    configure()
  }
  
  // TODO: Figure out how we can remove this method.
  open func viewAppeared() {
    pagingController.viewAppeared()
  }
  
  open func transitionSize() {
    pagingController.transitionSize()
  }
  
  open func contentScrolled(progress: CGFloat) {
    pagingController.contentScrolled(progress: progress)
  }
  
  open func contentFinishedScrolling() {
    pagingController.contentFinishedScrolling()
  }
  
  /// Reload data around given paging item. This will set the given
  /// paging item as selected and generate new items around it.
  ///
  /// - Parameter pagingItem: The `PagingItem` that will be selected
  /// after the data reloads.
  open func reload(around pagingItem: PagingItem) {
    pagingController.reloadMenu(around: pagingItem)
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
  
  // MARK: Private Methods
  
  private func configure() {
    collectionView.backgroundColor = options.menuBackgroundColor
    collectionView.delegate = self
    addSubview(collectionView)
    constrainToEdges(collectionView)
    
    pagingController.collectionView = collectionView
    pagingController.collectionViewLayout = collectionViewLayout
  }
  
}

extension PagingMenuView: UICollectionViewDelegate {
  
  public func scrollViewDidScroll(_ scrollView: UIScrollView) {
    pagingController.menuScrolled()
  }
  
  public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    pagingController.select(indexPath: indexPath, animated: true)
  }
  
}

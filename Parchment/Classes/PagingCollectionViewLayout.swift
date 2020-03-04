import UIKit

/// A custom `UICollectionViewLayout` subclass responsible for
/// defining the layout for all the `PagingItem` cells. You can
/// subclass this type if you need further customization outside what
/// is provided by customization properties on `PagingViewController`.
///
/// To create your own `PagingViewControllerLayout` you need to
/// override the `menuLayoutClass` property on `PagingViewController`.
/// Then you can override the methods you normally would to update the
/// layout attributes for each cell.
///
/// The layout has two decoration views; one for the border at the
/// bottom and one for the view that indicates the currently selected
/// `PagingItem`. You can customize their layout attributes by
/// updating the `indicatorLayoutAttributes` and
/// `borderLayoutAttributes` properties.
open class PagingCollectionViewLayout: UICollectionViewLayout, PagingLayout {
  
  // MARK: Public Properties
  
  /// An instance that stores all the customization that is applied
  /// to the `PagingViewController`.
  public var options = PagingOptions() {
    didSet {
      optionsChanged(oldValue: oldValue)
    }
  }
  
  /// The current state of the menu items. Indicates whether an item
  /// is currently selected or is scrolling to another item. Can be
  /// used to get the distance and progress of any ongoing transition.
  public var state: PagingState = .empty
  
  /// The `PagingItem`'s that are currently visible in the collection
  /// view. The items in this array are not necessarily the same as
  /// the `visibleCells` property on `UICollectionView`.
  public var visibleItems = PagingItems(items: [])
  
  /// A dictionary containing all the layout attributes for a given
  /// `IndexPath`. This will be generated in the `prepare()` call when
  /// the layout is invalidated with the correct invalidation context.
  public private(set) var layoutAttributes: [IndexPath: PagingCellLayoutAttributes] = [:]
  
  /// The layout attributes for the selected item indicator. This is
  /// updated whenever the layout is invalidated.
  public private(set) var indicatorLayoutAttributes: PagingIndicatorLayoutAttributes?
  
  /// The layout attributes for the bottom border view. This is
  /// updated whenever the layout is invalidated.
  public private(set) var borderLayoutAttributes: PagingBorderLayoutAttributes?
  
  /// The `InvalidatedState` is used to represent what to invalidate
  /// in a collection view layout based on the invalidation context.
  public var invalidationState: InvalidationState = .everything
  
  open override var collectionViewContentSize: CGSize {
    return contentSize
  }
  
  override open class var layoutAttributesClass: AnyClass {
    return PagingCellLayoutAttributes.self
  }
  
  // MARK: Initializers
  
  public override required init() {
    super.init()
    configure()
  }
  
  public required init?(coder: NSCoder) {
    super.init(coder: coder)
    configure()
  }
  
  // MARK: Internal Properties
  
  internal var sizeCache: PagingSizeCache?
  
  // MARK: Private Properties
  
  private var view: UICollectionView {
    return collectionView!
  }
  
  private var range: Range<Int> {
    return 0..<view.numberOfItems(inSection: 0)
  }
  
  private var adjustedMenuInsets: UIEdgeInsets {
    return UIEdgeInsets(
      top: options.menuInsets.top,
      left: options.menuInsets.left + safeAreaInsets.left,
      bottom: options.menuInsets.bottom,
      right: options.menuInsets.right + safeAreaInsets.right)
  }
  
  private var safeAreaInsets: UIEdgeInsets {
    if options.includeSafeAreaInsets, #available(iOS 11.0, *) {
      return view.safeAreaInsets
    } else {
      return .zero
    }
  }
  
  private(set) var contentInsets: UIEdgeInsets = .zero
  private var contentSize: CGSize = .zero
  private let PagingIndicatorKind = "PagingIndicatorKind"
  private let PagingBorderKind = "PagingBorderKind"
  
  // MARK: Public Methods
  
  open override func prepare() {
    super.prepare()
    
    switch invalidationState {
    case .everything:
      layoutAttributes = [:]
      borderLayoutAttributes = nil
      indicatorLayoutAttributes = nil
      createLayoutAttributes()
      createDecorationLayoutAttributes()
    case .sizes:
      layoutAttributes = [:]
      createLayoutAttributes()
    case .nothing:
      break
    }
    
    updateBorderLayoutAttributes()
    updateIndicatorLayoutAttributes()
    
    invalidationState = .nothing
  }
  
  open override func invalidateLayout() {
    super.invalidateLayout()
    invalidationState = .everything
  }
  
  override open func invalidateLayout(with context: UICollectionViewLayoutInvalidationContext) {
    super.invalidateLayout(with: context)
    invalidationState = invalidationState + InvalidationState(context)
  }
  
  override open func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
    guard let layoutAttributes = self.layoutAttributes[indexPath] else { return nil }
    layoutAttributes.progress = progressForItem(at: layoutAttributes.indexPath)
    return layoutAttributes
  }
  
  open override func layoutAttributesForDecorationView(ofKind elementKind: String, at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
    switch (elementKind) {
    case PagingIndicatorKind:
      return indicatorLayoutAttributes
    case PagingBorderKind:
      return borderLayoutAttributes
    default:
      return super.layoutAttributesForDecorationView(ofKind: elementKind, at: indexPath)
    }
  }
  
  override open func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
    var layoutAttributes: [UICollectionViewLayoutAttributes] = Array(self.layoutAttributes.values)
    
    for attributes in layoutAttributes {
      if let pagingAttributes = attributes as? PagingCellLayoutAttributes {
        pagingAttributes.progress = progressForItem(at: attributes.indexPath)
      }
    }
    
    let indicatorAttributes = layoutAttributesForDecorationView(
      ofKind: PagingIndicatorKind,
      at: IndexPath(item: 0, section: 0))
    
    let borderAttributes = layoutAttributesForDecorationView(
      ofKind: PagingBorderKind,
      at: IndexPath(item: 1, section: 0))
    
    if let indicatorAttributes = indicatorAttributes {
      layoutAttributes.append(indicatorAttributes)
    }
    
    if let borderAttributes = borderAttributes {
      layoutAttributes.append(borderAttributes)
    }
    
    return layoutAttributes
  }

  // MARK: Private Methods
  
  private func optionsChanged(oldValue: PagingOptions) {
    var shouldInvalidateLayout: Bool = false
    
    if options.borderClass != oldValue.borderClass {
      registerBorderClass()
      shouldInvalidateLayout = true
    }
    
    if options.indicatorClass != oldValue.indicatorClass {
      registerIndicatorClass()
      shouldInvalidateLayout = true
    }
    
    if options.borderColor != oldValue.borderColor {
      shouldInvalidateLayout = true
    }
    
    if options.indicatorColor != oldValue.indicatorColor {
      shouldInvalidateLayout = true
    }
    
    if shouldInvalidateLayout {
      invalidateLayout()
    }
  }
  
  private func configure() {
    registerBorderClass()
    registerIndicatorClass()
  }
  
  private func registerIndicatorClass() {
    register(options.indicatorClass, forDecorationViewOfKind: PagingIndicatorKind)
  }
  
  private func registerBorderClass() {
    register(options.borderClass, forDecorationViewOfKind: PagingBorderKind)
  }
  
  private func createLayoutAttributes() {
    guard let sizeCache = sizeCache else { return }
    
    var layoutAttributes: [IndexPath: PagingCellLayoutAttributes] = [:]
    var previousFrame: CGRect = .zero
    previousFrame.origin.x = adjustedMenuInsets.left - options.menuItemSpacing
    
    for index in 0..<self.view.numberOfItems(inSection: 0) {
      
      let indexPath = IndexPath(item: index, section: 0)
      let attributes = PagingCellLayoutAttributes(forCellWith: indexPath)
      let x = previousFrame.maxX + options.menuItemSpacing
      let y = adjustedMenuInsets.top
      
      if sizeCache.implementsWidthDelegate {
        let pagingItem = visibleItems.pagingItem(for: indexPath)
        var width = sizeCache.itemWidth(for: pagingItem)
        let selectedWidth = sizeCache.itemWidthSelected(for: pagingItem)
        
        if let currentPagingItem = state.currentPagingItem, currentPagingItem.isEqual(to: pagingItem) {
          width = tween(from: selectedWidth, to: width, progress: abs(state.progress))
        } else if let upcomingPagingItem = state.upcomingPagingItem, upcomingPagingItem.isEqual(to: pagingItem) {
          width = tween(from: width, to: selectedWidth, progress: abs(state.progress))
        }
        
        attributes.frame = CGRect(x: x, y: y, width: width, height: options.menuItemSize.height)
      } else {
        switch (options.menuItemSize) {
        case let .fixed(width, height):
          attributes.frame = CGRect(x: x, y: y, width: width, height: height)
        case let .sizeToFit(minWidth, height):
          attributes.frame = CGRect(x: x, y: y, width: minWidth, height: height)
        }
      }
      
      previousFrame = attributes.frame
      layoutAttributes[indexPath] = attributes
    }
    
    // When the menu items all can fit inside the bounds we need to
    // reposition the items based on the current options
    if previousFrame.maxX - adjustedMenuInsets.left < view.bounds.width {
      
      switch (options.menuItemSize) {
      case let .sizeToFit(_, height) where sizeCache.implementsWidthDelegate == false:
        let insets = adjustedMenuInsets.left + adjustedMenuInsets.right
        let spacing = (options.menuItemSpacing * CGFloat(range.upperBound - 1))
        let width = (view.bounds.width - insets - spacing) / CGFloat(range.upperBound)
        previousFrame = .zero
        previousFrame.origin.x = adjustedMenuInsets.left - options.menuItemSpacing
        
        for attributes in layoutAttributes.values.sorted(by: { $0.indexPath < $1.indexPath }) {
          let x = previousFrame.maxX + options.menuItemSpacing
          let y = adjustedMenuInsets.top
          attributes.frame = CGRect(x: x, y: y, width: width, height: height)
          previousFrame = attributes.frame
        }
        
      // When using sizeToFit the content will always be as wide as
      // the bounds so there is not possible to center the items. In
      // all the other cases we want to center them if the menu
      // alignment is set to .center
      default:
        if case .center = options.menuHorizontalAlignment {
          
          // Subtract the menu insets as they should not have an effect on
          // whether or not we should center the items.
          let offset = (view.bounds.width - previousFrame.maxX - adjustedMenuInsets.left) / 2
          for attributes in layoutAttributes.values {
            attributes.frame = attributes.frame.offsetBy(dx: offset, dy: 0)
          }
        }
      }
    }
    
    if case .center = options.selectedScrollPosition {
      let attributes = layoutAttributes.values.sorted(by: { $0.indexPath < $1.indexPath })
      
      if let first = attributes.first, let last = attributes.last {
        let insetLeft = (view.bounds.width / 2) - (first.bounds.width / 2)
        let insetRight = (view.bounds.width / 2) - (last.bounds.width / 2)
        
        for attributes in layoutAttributes.values {
          attributes.frame = attributes.frame.offsetBy(dx: insetLeft, dy: 0)
        }
        
        contentInsets = UIEdgeInsets(
          top: 0,
          left: insetLeft + adjustedMenuInsets.left,
          bottom: 0,
          right: insetRight + adjustedMenuInsets.right)
        
        contentSize = CGSize(
          width: previousFrame.maxX + insetLeft + insetRight + adjustedMenuInsets.right,
          height: view.bounds.height)
      }
      
    } else {
      contentInsets = adjustedMenuInsets
      contentSize = CGSize(
        width: previousFrame.maxX + adjustedMenuInsets.right,
        height: view.bounds.height)
    }
    
    
    self.layoutAttributes = layoutAttributes
  }
  
  private func createDecorationLayoutAttributes() {
    if case .visible = options.indicatorOptions {
      indicatorLayoutAttributes = PagingIndicatorLayoutAttributes(
        forDecorationViewOfKind: PagingIndicatorKind,
        with: IndexPath(item: 0, section: 0))
    }
    
    if case .visible = options.borderOptions {
      borderLayoutAttributes = PagingBorderLayoutAttributes(
        forDecorationViewOfKind: PagingBorderKind,
        with: IndexPath(item: 1, section: 0))
    }
  }
  
  private func updateBorderLayoutAttributes() {
    borderLayoutAttributes?.configure(options)
    borderLayoutAttributes?.update(
      contentSize: collectionViewContentSize,
      bounds: collectionView?.bounds ?? .zero,
      safeAreaInsets: safeAreaInsets)
  }
  
  private func updateIndicatorLayoutAttributes() {
    guard let currentPagingItem = state.currentPagingItem else { return }
    indicatorLayoutAttributes?.configure(options)
    
    let currentIndexPath = visibleItems.indexPath(for: currentPagingItem)
    let upcomingIndexPath = upcomingIndexPathForIndexPath(currentIndexPath)
    
    if let upcomingIndexPath = upcomingIndexPath {
      let progress = abs(state.progress)
      let to = PagingIndicatorMetric(
        frame: indicatorFrameForIndex(upcomingIndexPath.item),
        insets: indicatorInsetsForIndex(upcomingIndexPath.item),
        spacing: indicatorSpacingForIndex(upcomingIndexPath.item))
      
      if let currentIndexPath = currentIndexPath {
        let from = PagingIndicatorMetric(
          frame: indicatorFrameForIndex(currentIndexPath.item),
          insets: indicatorInsetsForIndex(currentIndexPath.item),
          spacing: indicatorSpacingForIndex(currentIndexPath.item))
        
        indicatorLayoutAttributes?.update(from: from, to: to, progress: progress)
      } else if let from = indicatorMetricForFirstItem() {
        indicatorLayoutAttributes?.update(from: from, to: to, progress: progress)
      } else if let from = indicatorMetricForLastItem() {
        indicatorLayoutAttributes?.update(from: from, to: to, progress: progress)
      }
    } else if let metric = indicatorMetricForFirstItem() {
      indicatorLayoutAttributes?.update(to: metric)
    } else if let metric = indicatorMetricForLastItem() {
      indicatorLayoutAttributes?.update(to: metric)
    }
  }
  
  private func indicatorMetricForFirstItem() -> PagingIndicatorMetric? {
    guard let currentPagingItem = state.currentPagingItem else { return nil }
    if let first = visibleItems.items.first {
      if currentPagingItem.isBefore(item: first) {
        return PagingIndicatorMetric(
          frame: indicatorFrameForIndex(-1),
          insets: indicatorInsetsForIndex(-1),
          spacing: indicatorSpacingForIndex(-1))
      }
    }
    return nil
  }
  
  private func indicatorMetricForLastItem() -> PagingIndicatorMetric? {
    guard let currentPagingItem = state.currentPagingItem else { return nil }
    if let last = visibleItems.items.last {
      if last.isBefore(item: currentPagingItem) {
        return PagingIndicatorMetric(
          frame: indicatorFrameForIndex(visibleItems.items.count),
          insets: indicatorInsetsForIndex(visibleItems.items.count),
          spacing: indicatorSpacingForIndex(visibleItems.items.count))
      }
    }
    return nil
  }
  
  private func progressForItem(at indexPath: IndexPath) -> CGFloat {
    guard let currentPagingItem = state.currentPagingItem else { return 0 }
    
    let currentIndexPath = visibleItems.indexPath(for: currentPagingItem)
    
    if let currentIndexPath = currentIndexPath {
      if indexPath.item == currentIndexPath.item {
        return 1 - abs(state.progress)
      }
    }
    
    if let upcomingIndexPath = upcomingIndexPathForIndexPath(currentIndexPath) {
      if indexPath.item == upcomingIndexPath.item {
        return abs(state.progress)
      }
    }
    
    return 0
  }
  
  private func upcomingIndexPathForIndexPath(_ indexPath: IndexPath?) -> IndexPath? {
    if let upcomingPagingItem = state.upcomingPagingItem, let upcomingIndexPath = visibleItems.indexPath(for: upcomingPagingItem) {
      return upcomingIndexPath
    } else if let indexPath = indexPath {
      if indexPath.item == range.lowerBound {
        return IndexPath(item: indexPath.item - 1, section: 0)
      } else if indexPath.item == range.upperBound - 1 {
        return IndexPath(item: indexPath.item + 1, section: 0)
      }
    }
    return indexPath
  }
    
  private func indicatorSpacingForIndex(_ index: Int) -> UIEdgeInsets {
    if case let .visible(_, _, insets, _) = options.indicatorOptions {
      return insets
    }
    return UIEdgeInsets.zero
  }
  
  private func indicatorInsetsForIndex(_ index: Int) -> PagingIndicatorMetric.Inset {
    if case let .visible(_, _, _, insets) = options.indicatorOptions {
      if index == 0 && range.upperBound == 1 {
        return .both(insets.left, insets.right)
      } else if index == range.lowerBound {
        return .left(insets.left)
      } else if index >= range.upperBound - 1 {
        return .right(insets.right)
      }
    }
    return .none
  }
  
  private func indicatorFrameForIndex(_ index: Int) -> CGRect {
    if index < range.lowerBound {
      let frame = frameForIndex(0)
      return frame.offsetBy(dx: -frame.width, dy: 0)
    } else if index > range.upperBound - 1 {
      let frame = frameForIndex(visibleItems.items.count - 1)
      return frame.offsetBy(dx: frame.width, dy: 0)
    }
    
    return frameForIndex(index)
  }
  
  private func frameForIndex(_ index: Int) -> CGRect {
    guard
      let sizeCache = sizeCache,
      let attributes = layoutAttributes[IndexPath(item: index, section: 0)] else { return .zero }
    
    var frame = CGRect(
      x: attributes.center.x - attributes.bounds.midX,
      y: attributes.center.y - attributes.bounds.midY,
      width: attributes.bounds.width,
      height: attributes.bounds.height)
    if sizeCache.implementsWidthDelegate {
      let indexPath = IndexPath(item: index, section: 0)
      let pagingItem = visibleItems.pagingItem(for: indexPath)

      if let upcomingPagingItem = state.upcomingPagingItem, let currentPagingItem = state.currentPagingItem {
        if upcomingPagingItem.isEqual(to: pagingItem) || currentPagingItem.isEqual(to: pagingItem)  {
          frame.size.width = sizeCache.itemWidthSelected(for: pagingItem)
        }
      }
    }

    return frame
  }
}

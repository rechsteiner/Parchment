import UIKit

open class PagingCollectionViewLayout<T: PagingItem>: UICollectionViewFlowLayout where T: Equatable {
  
  var state: PagingState<T>?
  var dataStructure: PagingDataStructure<T>
  
  fileprivate let options: PagingOptions
  fileprivate let indicatorLayoutAttributes: PagingIndicatorLayoutAttributes
  fileprivate let borderLayoutAttributes: PagingBorderLayoutAttributes
  
  fileprivate var range: Range<Int> {
    guard let collectionView = collectionView else { return Range(0...0) }
    return 0..<(collectionView.numberOfItems(inSection: 0) - 1)
  }
  
  init(options: PagingOptions, dataStructure: PagingDataStructure<T>) {
    
    self.options = options
    self.dataStructure = dataStructure
    
    indicatorLayoutAttributes = PagingIndicatorLayoutAttributes(
      forDecorationViewOfKind: PagingIndicatorView.reuseIdentifier,
      with: IndexPath(item: 0, section: 0))
    
    borderLayoutAttributes = PagingBorderLayoutAttributes(
      forDecorationViewOfKind: PagingBorderView.reuseIdentifier,
      with: IndexPath(item: 1, section: 0))
    
    super.init()
    
    configure()
  }
  
  public required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  fileprivate func configure() {
    sectionInset = options.menuInsets
    minimumLineSpacing = options.menuItemSpacing
    minimumInteritemSpacing = 0
    scrollDirection = .horizontal
    registerDecorationView(PagingIndicatorView.self)
    registerDecorationView(PagingBorderView.self)
    indicatorLayoutAttributes.configure(options)
    borderLayoutAttributes.configure(options)
  }
  
  override open class var layoutAttributesClass: AnyClass {
    return PagingCellLayoutAttributes.self
  }
  
  open override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
    return true
  }
  
  open override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
    guard let layoutAttributes = super.layoutAttributesForItem(at: indexPath)?.copy() as? PagingCellLayoutAttributes else { return nil }
    layoutAttributes.progress = progressForItem(at: indexPath)
    return layoutAttributes
  }
  
  open override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
    guard let attributes = super.layoutAttributesForElements(in: rect) else { return nil }
  
    var layoutAttributes = [UICollectionViewLayoutAttributes]()
    for attribute in attributes {
      if let attribute = attribute.copy() as? PagingCellLayoutAttributes {
        attribute.progress = progressForItem(at: attribute.indexPath)
        layoutAttributes.append(attribute)
      }
    }
    
    let indicatorAttributes = layoutAttributesForDecorationView(ofKind: PagingIndicatorView.reuseIdentifier,
      at: IndexPath(item: 0, section: 0))
    
    let borderAttributes = layoutAttributesForDecorationView(ofKind: PagingBorderView.reuseIdentifier,
      at: IndexPath(item: 1, section: 0))
    
    if let indicatorAttributes = indicatorAttributes, let borderAttributes = borderAttributes {
      layoutAttributes.append(indicatorAttributes)
      layoutAttributes.append(borderAttributes)
    }
    
    return layoutAttributes
  }
  
  open override func layoutAttributesForDecorationView(ofKind elementKind: String, at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
    guard
      let state = state,
      let currentIndexPath = dataStructure.indexPathForPagingItem(state.currentPagingItem) else { return nil }
    
    let upcomingIndexPath = upcomingIndexPathForIndexPath(currentIndexPath)
    
    if elementKind == PagingIndicatorView.reuseIdentifier {
      
      let from = PagingIndicatorMetric(
        frame: indicatorFrameForIndex(currentIndexPath.item),
        insets: indicatorInsetsForIndex(currentIndexPath.item),
        spacing: indicatorSpacingForIndex(currentIndexPath.item))
      
      let to = PagingIndicatorMetric(
        frame: indicatorFrameForIndex(upcomingIndexPath.item),
        insets: indicatorInsetsForIndex(upcomingIndexPath.item),
        spacing: indicatorSpacingForIndex(upcomingIndexPath.item))
      
      indicatorLayoutAttributes.update(from: from, to: to, progress: fabs(state.progress))
      return indicatorLayoutAttributes
    }
    
    if elementKind == PagingBorderView.reuseIdentifier {
      borderLayoutAttributes.update(
        contentSize: collectionViewContentSize,
        bounds: collectionView?.bounds ?? .zero)
      return borderLayoutAttributes
    }
    
    return super.layoutAttributesForDecorationView(ofKind: elementKind, at: indexPath)
  }
  
  // MARK: Private
  
  fileprivate func progressForItem(at indexPath: IndexPath) -> CGFloat {
    guard
      let state = state,
      let currentIndexPath = dataStructure.indexPathForPagingItem(state.currentPagingItem) else { return 0 }
    
    let upcomingIndexPath = upcomingIndexPathForIndexPath(currentIndexPath)
    switch indexPath.item {
    case currentIndexPath.item:
      return 1 - fabs(state.progress)
    case upcomingIndexPath.item:
      return fabs(state.progress)
    default:
      return 0
    }
  }
  
  fileprivate func upcomingIndexPathForIndexPath(_ indexPath: IndexPath) -> IndexPath {
    guard
      let state = state else { return indexPath }
    
    if let upcomingPagingItem = state.upcomingPagingItem, let upcomingIndexPath = dataStructure.indexPathForPagingItem(upcomingPagingItem) {
      return upcomingIndexPath
    } else if indexPath.item == range.lowerBound {
      return IndexPath(item: indexPath.item - 1, section: 0)
    } else if indexPath.item == range.upperBound {
      return IndexPath(item: indexPath.item + 1, section: 0)
    }
    return indexPath
  }
    
  fileprivate func indicatorSpacingForIndex(_ index: Int) -> UIEdgeInsets {
    if case let .visible(_, _, insets, _) = options.indicatorOptions {
        return insets
    }
    return UIEdgeInsets.zero
  }
  
  fileprivate func indicatorInsetsForIndex(_ index: Int) -> PagingIndicatorMetric.Inset {
    if case let .visible(_, _, _, insets) = options.indicatorOptions {
      if index == range.lowerBound {
        return .left(insets.left)
      } else if index >= range.upperBound {
        return .right(insets.right)
      }
    }
    return .none
  }
  
  fileprivate func indicatorFrameForIndex(_ index: Int) -> CGRect {
    guard
      let state = state,
      let currentIndexPath = dataStructure.indexPathForPagingItem(state.currentPagingItem) else { return .zero }
    
    if index < range.lowerBound {
      let frame = frameForIndex(currentIndexPath.item)
      return frame.offsetBy(dx: -frame.width, dy: 0)
    } else if index > range.upperBound {
      let frame = frameForIndex(currentIndexPath.item)
      return frame.offsetBy(dx: frame.width, dy: 0)
    } else {
      return frameForIndex(index)
    }
  }
  
  fileprivate func frameForIndex(_ index: Int) -> CGRect {
    let currentIndexPath = IndexPath(item: index, section: 0)
    let layoutAttributes = layoutAttributesForItem(at: currentIndexPath)!
    return layoutAttributes.frame
  }
  
}

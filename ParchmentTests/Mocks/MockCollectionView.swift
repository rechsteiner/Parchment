import UIKit
@testable import Parchment

final class MockCollectionView: CollectionView, Mock {
  
  enum Action: Equatable {
    case contentOffset(CGPoint)
    case reloadData
    case layoutIfNeeded
    case setContentOffset(
      contentOffset: CGPoint,
      animated: Bool
    )
    case selectItem(
      indexPath: IndexPath?,
      animated: Bool,
      scrollPosition: UICollectionView.ScrollPosition
    )
  }
  
  var visibleItems: (() -> Int)!
  
  weak var collectionViewLayout: MockCollectionViewLayout!
  
  var calls: [MockCall] = []
  var indexPathsForVisibleItems: [IndexPath] = []
  var isDragging: Bool = false
  var window: UIWindow? = nil
  var superview: UIView? = nil
  var bounds: CGRect = .zero
  var contentSize: CGSize = .zero
  var contentInset: UIEdgeInsets = .zero
  var showsHorizontalScrollIndicator: Bool = false
  var dataSource: UICollectionViewDataSource? = nil
  var isScrollEnabled: Bool = false
  var alwaysBounceHorizontal: Bool = false
  
  private var _contentInsetAdjustmentBehavior: Any?
  @available(iOS 11.0, *)
  var contentInsetAdjustmentBehavior: UIScrollView.ContentInsetAdjustmentBehavior {
    get {
      if _contentInsetAdjustmentBehavior == nil {
        return .never
      }
      return _contentInsetAdjustmentBehavior as! UIScrollView.ContentInsetAdjustmentBehavior
    }
    set {
      _contentInsetAdjustmentBehavior = newValue
    }
  }
  
  var contentOffset: CGPoint = .zero {
    didSet {
      calls.append(MockCall(
        datetime: Date(),
        action: .collectionView(.contentOffset(contentOffset))
      ))
    }
  }
  
  func reloadData() {
    calls.append(MockCall(
      datetime: Date(),
      action: .collectionView(.reloadData)
    ))
    
    let items = visibleItems()
    let range = 0..<items
    let indexPaths = range.map { IndexPath(item: $0, section: 0) }
    
    contentSize = CGSize(
      width: PagingControllerSpec.ItemSize * CGFloat(items),
      height: PagingControllerSpec.ItemSize
    )
    indexPathsForVisibleItems = indexPaths
    
    var layoutAttributes: [IndexPath: PagingCellLayoutAttributes] = [:]
    
    for indexPath in indexPaths {
      let attributes = PagingCellLayoutAttributes(forCellWith: indexPath)
      attributes.frame = CGRect(
        x: PagingControllerSpec.ItemSize * CGFloat(indexPath.item),
        y: 0,
        width: PagingControllerSpec.ItemSize,
        height: PagingControllerSpec.ItemSize
      )
      layoutAttributes[indexPath] = attributes
    }
    
    collectionViewLayout.layoutAttributes = layoutAttributes
  }
  
  func layoutIfNeeded() {
    calls.append(MockCall(
      datetime: Date(),
      action: .collectionView(.layoutIfNeeded)
    ))
  }
  
  func setContentOffset(_ contentOffset: CGPoint, animated: Bool) {
    calls.append(MockCall(
      datetime: Date(),
      action: .collectionView(.setContentOffset(
        contentOffset: contentOffset,
        animated: animated
      ))
    ))
  }
  
  func selectItem(at indexPath: IndexPath?, animated: Bool, scrollPosition: UICollectionView.ScrollPosition) {
    calls.append(MockCall(
      datetime: Date(),
      action: .collectionView(.selectItem(
        indexPath: indexPath,
        animated: animated,
        scrollPosition: scrollPosition
      ))
    ))
    if let indexPath = indexPath {
      contentOffset = CGPoint(
        x: CGFloat(indexPath.item) * PagingControllerSpec.ItemSize,
        y: 0
      )
    }
  }
  
  func register(_ cellClass: AnyClass?, forCellWithReuseIdentifier: String) {
    return
  }
  
  func register(_ nib: UINib?, forCellWithReuseIdentifier: String) {
    return
  }
  
  func addGestureRecognizer(_ recognizer: UIGestureRecognizer) {
    return
  }
  
  func removeGestureRecognizer(_ recognizer: UIGestureRecognizer) {
    return
  }
  
}


import UIKit

protocol CollectionViewLayout: class {
  var state: PagingState { get set }
  var visibleItems: PagingItems { get set }
  var sizeCache: PagingSizeCache? { get set }
  var contentInsets: UIEdgeInsets { get }
  var layoutAttributes: [IndexPath: PagingCellLayoutAttributes] { get }
  func prepare()
  func invalidateLayout()
  func invalidateLayout(with context: UICollectionViewLayoutInvalidationContext)
}

extension PagingCollectionViewLayout: CollectionViewLayout {}

protocol CollectionView: class {
  var indexPathsForVisibleItems: [IndexPath] { get }
  var isDragging: Bool { get }
  var window: UIWindow? { get }
  var superview: UIView? { get }
  var bounds: CGRect { get }
  var contentOffset: CGPoint { get set }
  var contentSize: CGSize { get }
  var contentInset: UIEdgeInsets { get }
  var showsHorizontalScrollIndicator: Bool { get set }
  var dataSource: UICollectionViewDataSource? { get set }
  var isScrollEnabled: Bool { get set }
  var alwaysBounceHorizontal: Bool { get set }
  
  @available(iOS 11.0, *)
  var contentInsetAdjustmentBehavior: UIScrollView.ContentInsetAdjustmentBehavior { get set }
  
  func register(_ cellClass: AnyClass?, forCellWithReuseIdentifier: String)
  func register(_ nib: UINib?, forCellWithReuseIdentifier: String)
  func addGestureRecognizer(_ recognizer: UIGestureRecognizer)
  func removeGestureRecognizer(_ recognizer: UIGestureRecognizer)
  func reloadData()
  func layoutIfNeeded()
  func setContentOffset(_ contentOffset: CGPoint, animated: Bool)
  func selectItem(at indexPath: IndexPath?, animated: Bool, scrollPosition: UICollectionView.ScrollPosition)
}

extension UICollectionView: CollectionView {}

enum Edge {
  case left, right, top, bottom
}

extension CollectionView {
  
  func near(edge: Edge, clearance: CGFloat = 0) -> Bool {
    switch edge {
    case .left:
      return contentOffset.x + contentInset.left - clearance <= 0
    case .right:
      return (contentOffset.x + bounds.width + clearance) >= contentSize.width
    case .top:
      return contentOffset.y + contentInset.top - clearance <= 0
    case .bottom:
      return (contentOffset.y + bounds.height + clearance) >= contentSize.height
    }
  }
  
}

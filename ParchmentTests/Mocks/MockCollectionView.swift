@testable import Parchment
import UIKit

@MainActor
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
        case indexPathForItem(point: CGPoint)
    }

    var visibleItems: (() -> Int)!

    weak var collectionViewLayout: MockCollectionViewLayout!

    var calls: [MockCall] = []
    var indexPathsForVisibleItems: [IndexPath] = []
    var isDragging: Bool = false
    var window: UIWindow?
    var superview: UIView?
    var bounds: CGRect = .zero
    var contentSize: CGSize = .zero
    var contentInset: UIEdgeInsets = .zero
    var showsHorizontalScrollIndicator: Bool = false
    var dataSource: UICollectionViewDataSource?
    var isScrollEnabled: Bool = false
    var alwaysBounceHorizontal: Bool = false

    private var _contentInsetAdjustmentBehavior: Any?
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
                action: .collectionView(.contentOffset(contentOffset))
            ))
        }
    }

    func reloadData() {
        calls.append(MockCall(action: .collectionView(.reloadData)))

        let items = visibleItems()
        let range = 0 ..< items
        let indexPaths = range.map { IndexPath(item: $0, section: 0) }

        contentSize = CGSize(
            width: PagingControllerTests.ItemSize * CGFloat(items),
            height: PagingControllerTests.ItemSize
        )
        indexPathsForVisibleItems = indexPaths

        var layoutAttributes: [IndexPath: PagingCellLayoutAttributes] = [:]

        for indexPath in indexPaths {
            let attributes = PagingCellLayoutAttributes(forCellWith: indexPath)
            attributes.frame = CGRect(
                x: PagingControllerTests.ItemSize * CGFloat(indexPath.item),
                y: 0,
                width: PagingControllerTests.ItemSize,
                height: PagingControllerTests.ItemSize
            )
            layoutAttributes[indexPath] = attributes
        }

        collectionViewLayout.layoutAttributes = layoutAttributes
    }

    func layoutIfNeeded() {
        calls.append(MockCall(action: .collectionView(.layoutIfNeeded)))
    }

    func setContentOffset(_ contentOffset: CGPoint, animated: Bool) {
        calls.append(MockCall(
            action: .collectionView(.setContentOffset(
                contentOffset: contentOffset,
                animated: animated
            ))
        ))
    }

    func selectItem(at indexPath: IndexPath?, animated: Bool, scrollPosition: UICollectionView.ScrollPosition) {
        calls.append(MockCall(
            action: .collectionView(.selectItem(
                indexPath: indexPath,
                animated: animated,
                scrollPosition: scrollPosition
            ))
        ))
        if let indexPath = indexPath {
            contentOffset = CGPoint(
                x: CGFloat(indexPath.item) * PagingControllerTests.ItemSize,
                y: 0
            )
        }
    }

    func indexPathForItem(at point: CGPoint) -> IndexPath? {
        calls.append(MockCall(
            action: .collectionView(.indexPathForItem(point: point))
        ))
        return nil
    }

    func register(_: AnyClass?, forCellWithReuseIdentifier _: String) {
        return
    }

    func register(_: UINib?, forCellWithReuseIdentifier _: String) {
        return
    }

    func addGestureRecognizer(_: UIGestureRecognizer) {
        return
    }

    func removeGestureRecognizer(_: UIGestureRecognizer) {
        return
    }
}

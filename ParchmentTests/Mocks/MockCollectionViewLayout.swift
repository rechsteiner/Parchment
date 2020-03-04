import UIKit
@testable import Parchment

final class MockCollectionViewLayout: CollectionViewLayout, Mock {
  
  enum Action: Equatable {
    case prepare
    case invalidateLayout
    case invalidateLayoutWithContext(invalidateSizes: Bool)
  }
  
  var calls: [MockCall] = []
  var contentInsets: UIEdgeInsets = .zero
  var layoutAttributes: [IndexPath: PagingCellLayoutAttributes] = [:]
  var state: PagingState = .empty
  var visibleItems = PagingItems(items: [])
  var sizeCache: PagingSizeCache?
  
  func prepare() {
    calls.append(MockCall(
      datetime: Date(),
      action: .collectionViewLayout(.prepare)
    ))
  }
  
  func invalidateLayout() {
    calls.append(MockCall(
      datetime: Date(),
      action: .collectionViewLayout(.invalidateLayout)
    ))
  }
  
  func invalidateLayout(with context: UICollectionViewLayoutInvalidationContext) {
    let context = context as! PagingInvalidationContext
    calls.append(MockCall(
      datetime: Date(),
      action: .collectionViewLayout(.invalidateLayoutWithContext(
        invalidateSizes: context.invalidateSizes
      ))
    ))
  }
  
}

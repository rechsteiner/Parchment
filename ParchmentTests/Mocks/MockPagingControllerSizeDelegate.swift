import Foundation
@testable import Parchment

final class MockPagingControllerSizeDelegate: PagingControllerSizeDelegate {
  
  var pagingItemWidth: (() -> CGFloat?)?
  
  func width(for pagingItem: PagingItem, isSelected: Bool) -> CGFloat {
    return pagingItemWidth?() ?? 0
  }
  
}

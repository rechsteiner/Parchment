import Foundation

struct PagingIndicatorMetric {
  
  enum Inset {
    case left(CGFloat)
    case right(CGFloat)
    case none
  }
  
  let frame: CGRect
  let insets: Inset
  let indicatorOffset: CGFloat
  
  var x: CGFloat {
    switch insets {
    case let .left(inset):
      return frame.origin.x + max(inset, indicatorOffset)
    default:
      return frame.origin.x + indicatorOffset
    }
  }
  
  var width: CGFloat {
    switch insets {
    case let .left(inset):
      return frame.size.width - max(inset, indicatorOffset) - indicatorOffset
    case let .right(inset):
      return frame.size.width - max(inset, indicatorOffset) - indicatorOffset
    case .none:
      return frame.size.width - 2 * indicatorOffset
    }
  }
  
}

import Foundation

public enum PagingDirection: Equatable {
  case reverse(sibling: Bool)
  case forward(sibling: Bool)
  case none
}

extension PagingDirection {
  
  var pageViewControllerNavigationDirection: EMPageViewControllerNavigationDirection {
    switch self {
    case .forward, .none:
      return .forward
    case .reverse:
      return .reverse
    }
  }
  
}

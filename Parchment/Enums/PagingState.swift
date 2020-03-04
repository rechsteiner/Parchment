import Foundation
import UIKit

/// The current state of the menu items. Indicates whether an item
/// is currently selected or is scrolling to another item. Can be
/// used to get the distance and progress of any ongoing transition.
public enum PagingState: Equatable {
  case empty
  case selected(pagingItem: PagingItem)
  case scrolling(
    pagingItem: PagingItem,
    upcomingPagingItem: PagingItem?,
    progress: CGFloat,
    initialContentOffset: CGPoint,
    distance: CGFloat)
}

public extension PagingState {
  
  var currentPagingItem: PagingItem? {
    switch self {
    case .empty:
      return nil
    case let .scrolling(pagingItem, _, _, _, _):
      return pagingItem
    case let .selected(pagingItem):
      return pagingItem
    }
  }
  
  var upcomingPagingItem: PagingItem? {
    switch self {
    case .empty:
      return nil
    case let .scrolling(_, upcomingPagingItem, _, _, _):
      return upcomingPagingItem
    case .selected:
      return nil
    }
  }
  
  var progress: CGFloat {
    switch self {
    case let .scrolling(_, _, progress, _, _):
      return progress
    case .selected, .empty:
      return 0
    }
  }
  
  var distance: CGFloat {
    switch self {
    case let .scrolling(_, _, _, _, distance):
      return distance
    case .selected, .empty:
      return 0
    }
  }
  
  var visuallySelectedPagingItem: PagingItem? {
    if abs(progress) > 0.5 {
      return upcomingPagingItem ?? currentPagingItem
    } else {
      return currentPagingItem
    }
  }
  
}

public func ==(lhs: PagingState, rhs: PagingState) -> Bool {
  switch (lhs, rhs) {
  case
    (let .scrolling(lhsCurrent, lhsUpcoming, lhsProgress, lhsOffset, lhsDistance),
     let .scrolling(rhsCurrent, rhsUpcoming, rhsProgress, rhsOffset, rhsDistance)):
    if lhsCurrent.isEqual(to: rhsCurrent) &&
      lhsProgress == rhsProgress &&
      lhsOffset == rhsOffset &&
      lhsDistance == rhsDistance {
      if let lhsUpcoming = lhsUpcoming, let rhsUpcoming = rhsUpcoming, lhsUpcoming.isEqual(to: rhsUpcoming) {
        return true
      } else if lhsUpcoming == nil && rhsUpcoming == nil {
        return true
      }
    }
    return false
  case (let .selected(a), let .selected(b)) where a.isEqual(to: b):
    return true
  case (.empty, .empty):
    return true
  default:
    return false
  }
}

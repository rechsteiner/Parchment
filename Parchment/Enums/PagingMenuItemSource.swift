import Foundation
import UIKit

public enum PagingMenuItemSource {
	case `class`(type: PagingCell.Type)
	case nib(nib: UINib)
}

extension PagingMenuItemSource: Equatable {
  public static func == (lhs: PagingMenuItemSource, rhs: PagingMenuItemSource) -> Bool {
    switch (lhs, rhs) {
    case let (.class(lhsType), .class(rhsType)):
      return lhsType == rhsType
      
    case let (.nib(lhsNib), .nib(rhsNib)):
      return lhsNib === rhsNib
      
    default:
      return false
    }
  }
}

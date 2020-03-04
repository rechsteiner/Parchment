import UIKit

/// An implementation of the `PagingItem` protocol that stores the
/// index and title of a given item. The index property is needed to
/// make the `PagingItem` comparable.
public struct PagingIndexItem: PagingItem, Hashable, Comparable {
  
  /// The index of the `PagingItem` instance
  public let index: Int
  
  /// The title used in the menu cells.
  public let title: String
  
  /// Creates an instance of `PagingIndexItem`
  ///
  /// Parameter index: The index of the `PagingItem`.
  /// Parameter title: The title used in the menu cells.
  public init(index: Int, title: String) {
    self.index = index
    self.title = title
  }
  
  public static func <(lhs: PagingIndexItem, rhs: PagingIndexItem) -> Bool {
    return lhs.index < rhs.index
  }
}

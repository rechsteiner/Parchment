import Foundation

/// A data structure used to hold an array of `PagingItem`'s, with
/// methods for getting the index path for a given `PagingItem` and
/// vice versa.
public struct PagingItems {
  
  /// A sorted array of the currently visible `PagingItem`'s.
  public let items: [PagingItem]
  
  let hasItemsBefore: Bool
  let hasItemsAfter: Bool
  private var cachedItems: [Int: PagingItem]
  
  init(items: [PagingItem], hasItemsBefore: Bool = false, hasItemsAfter: Bool = false) {
    self.items = items
    self.hasItemsBefore = hasItemsBefore
    self.hasItemsAfter = hasItemsAfter
    self.cachedItems = [:]
    
    for item in items {
      cachedItems[item.identifier] = item
    }
  }
  
  /// The `IndexPath` for a given `PagingItem`. Returns nil if the
  /// `PagingItem` is not in the `items` array.
  ///
  /// - Parameter pagingItem: A `PagingItem` instance
  /// - Returns: The `IndexPath` for the given `PagingItem`
  public func indexPath(for pagingItem: PagingItem) -> IndexPath? {
    guard let index = items.firstIndex(where: { $0.isEqual(to: pagingItem) }) else { return nil }
    return IndexPath(item: index, section: 0)
  }
  
  /// The `PagingItem` for a given `IndexPath`. This method will crash
  /// if you pass in an `IndexPath` that is currently not visible in
  /// the collection view.
  ///
  /// - Parameter indexPath: An `IndexPath` that is currently visible
  /// - Returns: The `PagingItem` for the given `IndexPath`
  public func pagingItem(for indexPath: IndexPath) -> PagingItem {
    return items[indexPath.item]
  }
  
  /// The direction from a given `PagingItem` to another `PagingItem`.
  /// If the `PagingItem`'s are equal the direction will be .none.
  ///
  /// - Parameter from: The current `PagingItem`
  /// - Parameter to: The `PagingItem` being scrolled towards
  /// - Returns: The `PagingDirection` for a given `PagingItem`
  public func direction(from: PagingItem, to: PagingItem) -> PagingDirection {
    if contains(from) == false {
      return .none
    } else if from.isBefore(item: to) {
      return .forward(sibling: isSibling(from: from, to: to))
    } else if to.isBefore(item: from) {
      return .reverse(sibling: isSibling(from: from, to: to))
    }
    return .none
  }
  
  func isSibling(from: PagingItem, to: PagingItem) -> Bool {
    guard
      let fromIndex = items.firstIndex(where : { $0.isEqual(to: from) }),
      let toIndex = items.firstIndex(where: { $0.isEqual(to: to) })
      else { return false }
    
    if fromIndex == toIndex - 1 {
      return true
    } else if fromIndex - 1 == toIndex {
      return true
    } else {
      return false
    }
  }
  
  func contains(_ pagingItem: PagingItem) -> Bool {
    return cachedItems[pagingItem.identifier] != nil ? true : false
  }
  
  func union(_ newItems: [PagingItem]) -> [PagingItem] {
    let old = Set(items.map { AnyPagingItem(base: $0) })
    let new = Set(newItems.map { AnyPagingItem(base: $0) })
    return Array(old.union(new))
      .map({ $0.base })
      .sorted(by: { $0.isBefore(item: $1) })
  }
}

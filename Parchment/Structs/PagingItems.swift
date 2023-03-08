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
        cachedItems = [:]

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
        guard let index = itemIndexNearCenter(for: pagingItem) else { return nil }
        return IndexPath(item: index, section: 0)
    }

    /// The `IndexPath` for a given `PagingItem`. Returns nil if the
    /// `PagingItem` is not in the `items` array.
    ///
    /// - Parameter pagingItem: A `PagingItem` instance
    /// - Parameter basePagingItem: Select the instance nearest to `basePagingItem`.
    /// - Returns: The `IndexPath` for the given `PagingItem`
    public func indexPath(for pagingItem: PagingItem, nearest basePagingItem: PagingItem) -> IndexPath? {
        guard
            let baseItemIndex = itemIndexNearCenter(for: basePagingItem),
            let index = itemIndex(for: pagingItem, nearestTo: CGFloat(baseItemIndex))
        else { return nil }

        return IndexPath(item: index, section: 0)
    }

    /// The `PagingItem` for a given `IndexPath`. This method will crash
    /// if you pass in an `IndexPath` that is currently not visible in
    /// the collection view.
    ///
    /// - Parameter indexPath: An `IndexPath` that is currently visible
    /// - Returns: The `PagingItem` for the given `IndexPath`
    public func pagingItem(for indexPath: IndexPath) -> PagingItem {
        items[indexPath.item]
    }

    /// The direction from a given `PagingItem` to another `PagingItem`.
    /// If the `PagingItem`'s are equal the direction will be .none.
    ///
    /// - Parameter from: The current `PagingItem`
    /// - Parameter to: The `PagingItem` being scrolled towards
    /// - Returns: The `PagingDirection` for a given `PagingItem`
    public func direction(from: PagingItem, to: PagingItem) -> PagingDirection {
        if isBefore(from, to) {
            return .forward(sibling: isSibling(from: from, to: to))
        } else if isBefore(to, from) {
            return .reverse(sibling: isSibling(from: from, to: to))
        }
        return .none
    }

    func isBefore(_ lhs: PagingItem, _ rhs: PagingItem) -> Bool {
        guard
            let lhsIndex = itemIndexNearCenter(for: lhs),
            let rhsIndex = itemIndex(for: rhs, nearestTo: CGFloat(lhsIndex))
        else { return lhs.isBefore(item: rhs) }

        return lhsIndex < rhsIndex
    }

    func isSibling(from: PagingItem, to: PagingItem) -> Bool {
        guard
            let fromIndex = itemIndexNearCenter(for: from),
            let toIndex = itemIndex(for: to, nearestTo: CGFloat(fromIndex))
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
        cachedItems.keys.contains(pagingItem.identifier)
    }

    func itemIndexNearCenter(for pagingItem: PagingItem) -> Int? {
        let centerOfIndex = CGFloat(items.count - 1) / 2.0
        return itemIndex(for: pagingItem, nearestTo: centerOfIndex)
    }

    func itemIndex(for pagingItem: PagingItem, nearestTo index: CGFloat) -> Int? {
        items.enumerated()
            .filter { pagingItem.isEqual(to: $1) }
            .reduce(into: (CGFloat.greatestFiniteMagnitude, nil) as (diff: CGFloat, index: Int?)) { result, element in
                let diff = abs(index - CGFloat(element.offset))
                if diff < result.diff {
                    result = (diff, element.offset)
                }
            }
            .index
    }
}

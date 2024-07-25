import Foundation
@testable import Parchment

@MainActor
func createDistance(
    bounds: CGRect = .zero,
    contentSize: CGSize? = nil,
    currentItem: Item,
    currentItemBounds: CGRect?,
    upcomingItem: Item,
    upcomingItemBounds: CGRect,
    sizeCache: PagingSizeCache,
    selectedScrollPosition: PagingSelectedScrollPosition,
    navigationOrientation: PagingNavigationOrientation
) -> PagingDistance {
    let collectionView = MockCollectionView()
    collectionView.contentOffset = bounds.origin
    collectionView.bounds = bounds

    if let contentSize = contentSize {
        collectionView.contentSize = contentSize
    } else if let currentItemBounds = currentItemBounds {
        let contentFrame = currentItemBounds.union(upcomingItemBounds)
        collectionView.contentSize = contentFrame.size
    } else {
        collectionView.contentSize = upcomingItemBounds.size
    }

    let visibleItems = PagingItems(items: [currentItem, upcomingItem])
    var layoutAttributes: [IndexPath: PagingCellLayoutAttributes] = [:]

    if let currentItemBounds = currentItemBounds {
        let currentIndexPath = visibleItems.indexPath(for: currentItem)!
        let currentAttributes = PagingCellLayoutAttributes(forCellWith: currentIndexPath)
        currentAttributes.frame = currentItemBounds
        layoutAttributes[currentIndexPath] = currentAttributes
    }

    let upcomingIndexPath = visibleItems.indexPath(for: upcomingItem)!
    let upcomingAttributes = PagingCellLayoutAttributes(forCellWith: upcomingIndexPath)
    upcomingAttributes.frame = upcomingItemBounds
    layoutAttributes[upcomingIndexPath] = upcomingAttributes

    return PagingDistance(
        view: collectionView,
        currentPagingItem: currentItem,
        upcomingPagingItem: upcomingItem,
        visibleItems: visibleItems,
        sizeCache: sizeCache,
        selectedScrollPosition: selectedScrollPosition,
        layoutAttributes: layoutAttributes,
        navigationOrientation: navigationOrientation
    )!
}

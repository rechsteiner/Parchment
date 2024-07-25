import Foundation
import UIKit

@MainActor
struct PagingDistance {
    private let view: CollectionView
    private let hasItemsBefore: Bool
    private let hasItemsAfter: Bool
    private let fromItem: PagingItem
    private let fromAttributes: PagingCellLayoutAttributes?
    private let toItem: PagingItem
    private let toAttributes: PagingCellLayoutAttributes
    private let selectedScrollPosition: PagingSelectedScrollPosition
    private let sizeCache: PagingSizeCache
    private let navigationOrientation: PagingNavigationOrientation

    private var fromSize: CGFloat {
        guard let attributes = fromAttributes else { return 0 }
        switch navigationOrientation {
        case .vertical:
            return attributes.bounds.height
        case .horizontal:
            return attributes.bounds.width
        }
    }

    private var fromCenter: CGFloat {
        guard let attributes = fromAttributes else { return 0 }
        switch navigationOrientation {
        case .vertical:
            return attributes.center.y
        case .horizontal:
            return attributes.center.x
        }
    }

    private var toSize: CGFloat {
        switch navigationOrientation {
        case .vertical:
            return toAttributes.bounds.height
        case .horizontal:
            return toAttributes.bounds.width
        }
    }

    private var toCenter: CGFloat {
        switch navigationOrientation {
        case .vertical:
            return toAttributes.center.y
        case .horizontal:
            return toAttributes.center.x
        }
    }

    private var contentOffset: CGFloat {
        switch navigationOrientation {
        case .vertical:
            return view.contentOffset.y
        case .horizontal:
            return view.contentOffset.x
        }
    }

    private var contentSize: CGFloat {
        switch navigationOrientation {
        case .vertical:
            return view.contentSize.height
        case .horizontal:
            return view.contentSize.width
        }
    }

    private var viewSize: CGFloat {
        switch navigationOrientation {
        case .vertical:
            return view.bounds.height
        case .horizontal:
            return view.bounds.width
        }
    }

    private var viewCenter: CGFloat {
        switch navigationOrientation {
        case .vertical:
            return view.bounds.midY
        case .horizontal:
            return view.bounds.midX
        }
    }

    init?(
        view: CollectionView,
        currentPagingItem: PagingItem,
        upcomingPagingItem: PagingItem,
        visibleItems: PagingItems,
        sizeCache: PagingSizeCache,
        selectedScrollPosition: PagingSelectedScrollPosition,
        layoutAttributes: [IndexPath: PagingCellLayoutAttributes],
        navigationOrientation: PagingNavigationOrientation
    ) {
        guard
            let upcomingIndexPath = visibleItems.indexPath(for: upcomingPagingItem),
            let upcomingAttributes = layoutAttributes[upcomingIndexPath] else {
            // When there is no upcomingIndexPath or any layout attributes
            // for that item we have no way to determine the distance.
            return nil
        }

        self.view = view
        hasItemsBefore = visibleItems.hasItemsBefore
        hasItemsAfter = visibleItems.hasItemsAfter
        fromItem = currentPagingItem
        toItem = upcomingPagingItem
        toAttributes = upcomingAttributes
        self.selectedScrollPosition = selectedScrollPosition
        self.sizeCache = sizeCache
        self.navigationOrientation = navigationOrientation

        if let currentIndexPath = visibleItems.indexPath(for: currentPagingItem),
            let fromAttributes = layoutAttributes[currentIndexPath] {
            self.fromAttributes = fromAttributes
        } else {
            fromAttributes = nil
        }
    }

    /// In order to get the menu items to scroll alongside the content
    /// we create a transition struct to keep track of the initial
    /// content offset and the distance to the upcoming item so that we
    /// can update the content offset as the user is swiping.
    func calculate() -> CGFloat {
        var distance: CGFloat = 0

        switch selectedScrollPosition {
        case .left:
            distance = distanceLeft()
        case .right:
            distance = distanceRight()
        case .preferCentered, .center:
            distance = distanceCentered()
        }

        // Update the distance to account for cases where the user has
        // scrolled all the way over to the other edge.
        if view.near(edge: .left, clearance: -distance), distance < 0, hasItemsBefore == false {
            distance = -(contentOffset + view.contentInset.left)
        } else if view.near(edge: .right, clearance: distance), distance > 0, hasItemsAfter == false {
            let originalDistance = distance
            distance = contentSize - (contentOffset + viewSize)

            if sizeCache.implementsSizeDelegate {
                let toWidth = sizeCache.itemWidthSelected(for: toItem)
                distance += toWidth - toSize

                if let _ = fromAttributes {
                    let fromWidth = sizeCache.itemSize(for: fromItem)
                    distance -= fromSize - fromWidth
                }

                // If the selected cells grows so much that it will move
                // beyond the center of the view, we want to update the
                // distance after all.
                if selectedScrollPosition == .preferCentered {
                    let center = viewCenter
                    let centerAfterTransition = toCenter - distance
                    if centerAfterTransition < center {
                        distance = originalDistance
                    }
                }
            }
        }

        return distance
    }

    private func distanceLeft() -> CGFloat {
        // Need to use the combination of center and size as the frame
        // property will be affected by things like transforms etc.
        let currentPosition = toCenter - (toSize / 2)
        var distance = currentPosition - contentOffset

        // When scrolling forwards, subtract the difference between the
        // current width and the new selected width. If we're scrolling
        // backwards or the current item is scrolled out of view the
        // difference doesn't matter as the change in frame of the current
        // item won't have any affect on the position of the upcoming item.
        if sizeCache.implementsSizeDelegate {
            if let _ = fromAttributes {
                if fromItem.isBefore(item: toItem) {
                    let fromWidth = sizeCache.itemSize(for: fromItem)
                    let fromDiff = fromSize - fromWidth
                    distance -= fromDiff
                }
            }
        }
        return distance
    }

    private func distanceRight() -> CGFloat {
        // Need to use the combination of center and size as the frame
        // property will be affected by things like transforms etc.
        let currentPosition = toCenter + (toSize / 2)
        let width = contentOffset + viewSize
        var distance = currentPosition - width

        if sizeCache.implementsSizeDelegate {
            let toWidth = sizeCache.itemWidthSelected(for: toItem)

            // If we have layout attributes for the current item it means
            // the item is visible and will affect the on the position of
            // the upcoming item when we change its frame. We therefore need
            // to subtract the difference of the size.
            if let _ = fromAttributes {
                if toItem.isBefore(item: fromItem) {
                    let toDiff = toWidth - toSize
                    distance += toDiff
                } else {
                    let fromWidth = sizeCache.itemSize(for: fromItem)
                    let fromDiff = fromSize - fromWidth
                    let toDiff = toWidth - toSize
                    distance -= fromDiff
                    distance += toDiff
                }
            } else {
                // If we don't have any attributes for the current item it
                // means we have scrolled it out of view before selecting the
                // upcoming item. We need to append the difference between the
                // selected and none-selected with of the upcoming item.
                distance += toWidth - toSize
            }
        }

        return distance
    }

    private func distanceCentered() -> CGFloat {
        var distance = toCenter - viewCenter

        if let _ = fromAttributes {
            let distanceToCenter = viewCenter - fromCenter
            let distanceBetweenCells = toCenter - fromCenter
            distance = distanceBetweenCells - distanceToCenter

            if sizeCache.implementsSizeDelegate {
                let toWidth = sizeCache.itemWidthSelected(for: toItem)
                let fromWidth = sizeCache.itemSize(for: fromItem)

                if toItem.isBefore(item: fromItem) {
                    distance = -(toSize + (fromCenter - (toCenter + (toSize / 2))) - (toWidth / 2)) - distanceToCenter
                } else {
                    let toDiff = (toWidth - toSize) / 2
                    distance = fromWidth + (toCenter - (fromCenter + (fromSize / 2))) + toDiff - (fromSize / 2) - distanceToCenter
                }
            }
        } else if sizeCache.implementsSizeDelegate {
            let toWidth = sizeCache.itemWidthSelected(for: toItem)
            let toDiff = toWidth - toSize
            distance += toDiff / 2
        }

        return distance
    }
}

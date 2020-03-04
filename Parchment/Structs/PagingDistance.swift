import Foundation
import UIKit

struct PagingDistance {
  
  let view: CollectionView
  let currentPagingItem: PagingItem
  let upcomingPagingItem: PagingItem
  let visibleItems: PagingItems
  let sizeCache: PagingSizeCache
  let selectedScrollPosition: PagingSelectedScrollPosition
  let layoutAttributes: [IndexPath: PagingCellLayoutAttributes]
  
  /// In order to get the menu items to scroll alongside the content
  /// we create a transition struct to keep track of the initial
  /// content offset and the distance to the upcoming item so that we
  /// can update the content offset as the user is swiping.
  func calculate() -> CGFloat {
    guard
      let upcomingIndexPath = visibleItems.indexPath(for: upcomingPagingItem),
      let to = layoutAttributes[upcomingIndexPath] else {
        
        // When there is no upcomingIndexPath or any layout attributes
        // for that item we have no way to determine the distance.
        return 0
    }
    
    var distance: CGFloat = 0
    
    switch (selectedScrollPosition) {
    case .left:
      distance = distanceLeft()
    case .right:
      distance = distanceRight()
    case .preferCentered, .center:
      distance = distanceCentered()
    }
    
    // Update the distance to account for cases where the user has
    // scrolled all the way over to the other edge.
    if view.near(edge: .left, clearance: -distance) && distance < 0 && visibleItems.hasItemsBefore == false {
      distance = -(view.contentOffset.x + view.contentInset.left)
    } else if view.near(edge: .right, clearance: distance) && distance > 0 &&
      visibleItems.hasItemsAfter == false {
      
      let originalDistance = distance
      distance = view.contentSize.width - (view.contentOffset.x + view.bounds.width)
      
      if sizeCache.implementsWidthDelegate {
        let toWidth = sizeCache.itemWidthSelected(for: upcomingPagingItem)
        distance += toWidth - to.bounds.width
        
        if let currentIndexPath = visibleItems.indexPath(for: currentPagingItem),
          let from = layoutAttributes[currentIndexPath] {
          let fromWidth = sizeCache.itemWidth(for: currentPagingItem)
          distance -= from.bounds.width - fromWidth
        }
        
        // If the selected cells grows so much that it will move
        // beyond the center of the view, we want to update the
        // distance after all.
        if selectedScrollPosition == .preferCentered {
          let center = view.bounds.midX
          let centerAfterTransition = to.center.x - distance
          if centerAfterTransition < center {
            distance = originalDistance
          }
        }
      }
    }
    
    return distance
  }
  
  private func distanceLeft() -> CGFloat {
    guard
      let upcomingIndexPath = visibleItems.indexPath(for: upcomingPagingItem),
      let to = layoutAttributes[upcomingIndexPath] else { return 0 }
    
    var distance = to.center.x - (to.bounds.width / 2) - view.contentOffset.x
    
    if sizeCache.implementsWidthDelegate {
      if let currentIndexPath = visibleItems.indexPath(for: currentPagingItem),
        let from = layoutAttributes[currentIndexPath] {
        if currentPagingItem.isBefore(item: upcomingPagingItem) {
          let fromWidth = sizeCache.itemWidth(for: currentPagingItem)
          let fromDiff = from.bounds.width - fromWidth
          distance -= fromDiff
        }
      }
    }
    return distance
  }
  
  private func distanceRight() -> CGFloat {
    guard
      let upcomingIndexPath = visibleItems.indexPath(for: upcomingPagingItem),
      let to = layoutAttributes[upcomingIndexPath] else { return 0 }
    
    let toWidth = sizeCache.itemWidthSelected(for: upcomingPagingItem)
    let currentPosition = to.center.x + (to.bounds.width / 2)
    let width = view.contentOffset.x + view.bounds.width
    var distance = currentPosition - width
    
    if sizeCache.implementsWidthDelegate {
      if let currentIndexPath = visibleItems.indexPath(for: currentPagingItem),
        let from = layoutAttributes[currentIndexPath] {
        if upcomingPagingItem.isBefore(item: currentPagingItem) {
          let toDiff = toWidth - to.bounds.width
          distance += toDiff
        } else {
          let fromWidth = sizeCache.itemWidth(for: currentPagingItem)
          let fromDiff = from.bounds.width - fromWidth
          let toDiff = toWidth - to.bounds.width
          distance -= fromDiff
          distance += toDiff
        }
      } else {
        distance += toWidth - to.bounds.width
      }
    }
    
    return distance
  }
  
  private func distanceCentered() -> CGFloat {
    guard
      let upcomingIndexPath = visibleItems.indexPath(for: upcomingPagingItem),
      let to = layoutAttributes[upcomingIndexPath] else { return 0 }
    
    let toWidth = sizeCache.itemWidthSelected(for: upcomingPagingItem)
    var distance = to.center.x - view.bounds.midX
    
    if let currentIndexPath = visibleItems.indexPath(for: currentPagingItem),
      let from = layoutAttributes[currentIndexPath] {
      
      let distanceToCenter = view.bounds.midX - from.center.x
      let distanceBetweenCells = to.center.x - from.center.x
      distance = distanceBetweenCells - distanceToCenter
      
      if sizeCache.implementsWidthDelegate {
        let fromWidth = sizeCache.itemWidth(for: currentPagingItem)
        
        if upcomingPagingItem.isBefore(item: currentPagingItem) {
          distance = -(to.bounds.width + (from.center.x - (to.center.x + (to.bounds.width / 2))) - (toWidth / 2)) - distanceToCenter
        } else {
          let toDiff = (toWidth - to.bounds.width) / 2
          distance = fromWidth + (to.center.x - (from.center.x + (from.bounds.width / 2))) + toDiff - (from.bounds.width / 2) - distanceToCenter
        }
      }
    } else if sizeCache.implementsWidthDelegate {
      let toDiff = toWidth - to.bounds.width
      distance += toDiff / 2
    }
    
    return distance
  }
}

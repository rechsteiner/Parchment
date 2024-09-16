import Foundation
import Testing
@testable import Parchment

struct PagingDataTests {
    private let visibleItems: PagingItems

    init() {
        visibleItems = PagingItems(items: [
            Item(index: 0),
            Item(index: 1),
            Item(index: 2),
        ])
    }

    @Test func indexPathForPagingItemFound() {
        let indexPath = visibleItems.indexPath(for: Item(index: 0))!
        #expect(indexPath.item == 0)
    }

    @Test func indexPathForPagingItemMissing() {
        let indexPath = visibleItems.indexPath(for: Item(index: -1))
        #expect(indexPath == nil)
    }

    @Test func pagingItemForIndexPath() {
        let indexPath = IndexPath(item: 0, section: 0)
        let pagingItem = visibleItems.pagingItem(for: indexPath) as! Item
        #expect(pagingItem == Item(index: 0))
    }

    @Test func directionForIndexPathForward() {
        let currentPagingItem = Item(index: 0)
        let upcomingPagingItem = Item(index: 1)
        let direction = visibleItems.direction(from: currentPagingItem, to: upcomingPagingItem)
        #expect(direction == PagingDirection.forward(sibling: true))
    }

    @Test func directionForIndexPathReverse() {
        let currentPagingItem = Item(index: 1)
        let upcomingPagingItem = Item(index: 0)
        let direction = visibleItems.direction(from: currentPagingItem, to: upcomingPagingItem)
        #expect(direction == PagingDirection.reverse(sibling: true))
    }
}

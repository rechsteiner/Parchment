import Foundation
import Testing
@testable import Parchment

struct PagingDiffTests {
    @Test func detectsAddedItemsBeforeCenter() {
        let from = PagingItems(items: [Item(index: 1)])
        let to = PagingItems(items: [Item(index: 0), Item(index: 1)])
        let diff = PagingDiff(from: from, to: to)
        let added = diff.added()
        let removed = diff.removed()

        #expect(added.count == 1)
        #expect(added[0] == IndexPath(item: 0, section: 0))
        #expect(removed == [])
    }

    @Test func ignoresAddedItemsAfterCenter() {
        let from = PagingItems(items: [Item(index: 0)])
        let to = PagingItems(items: [Item(index: 0), Item(index: 1)])
        let diff = PagingDiff(from: from, to: to)

        #expect(diff.added() == [])
        #expect(diff.removed() == [])
    }

    @Test func ignoresRemovedItemsAfterCenter() {
        let from = PagingItems(items: [Item(index: 0), Item(index: 1)])
        let to = PagingItems(items: [Item(index: 0)])
        let diff = PagingDiff(from: from, to: to)

        #expect(diff.removed() == [])
        #expect(diff.added() == [])
    }

    @Test func detectsRemovedItemsBeforeCenter() {
        let from = PagingItems(items: [Item(index: 0), Item(index: 1)])
        let to = PagingItems(items: [Item(index: 1)])
        let diff = PagingDiff(from: from, to: to)
        let removed = diff.removed()
        let added = diff.added()

        #expect(added == [])
        #expect(removed.count == 1)
        #expect(removed[0] == IndexPath(item: 0, section: 0))
    }

    // TODO: Reduce these tests to a minimal test case and update
    // the descriptions.
    @Test func scenario1() {
        let from = PagingItems(items: [
            Item(index: 16),
            Item(index: 17),
            Item(index: 18),
            Item(index: 19),
            Item(index: 20),
            Item(index: 21),
            Item(index: 22),
            Item(index: 23),
            Item(index: 24),
            Item(index: 25),
            Item(index: 26),
            Item(index: 27),
            Item(index: 28),
            Item(index: 29),
            Item(index: 30),
        ])

        let to = PagingItems(items: [
            Item(index: 9),
            Item(index: 10),
            Item(index: 11),
            Item(index: 12),
            Item(index: 13),
            Item(index: 14),
            Item(index: 15),
            Item(index: 16),
            Item(index: 17),
            Item(index: 18),
            Item(index: 19),
            Item(index: 20),
            Item(index: 21),
            Item(index: 22),
            Item(index: 23),
        ])

        let diff = PagingDiff(from: from, to: to)
        let added = diff.added()
        let removed = diff.removed()

        #expect(removed == [])
        #expect(added.count == 7)
        #expect(added[0] == IndexPath(item: 0, section: 0))
        #expect(added[1] == IndexPath(item: 1, section: 0))
        #expect(added[2] == IndexPath(item: 2, section: 0))
        #expect(added[3] == IndexPath(item: 3, section: 0))
        #expect(added[4] == IndexPath(item: 4, section: 0))
        #expect(added[5] == IndexPath(item: 5, section: 0))
        #expect(added[6] == IndexPath(item: 6, section: 0))
    }

    @Test func scenario2() {
        let from = PagingItems(items: [
            Item(index: 0),
            Item(index: 1),
            Item(index: 2),
            Item(index: 3),
            Item(index: 4),
            Item(index: 5),
            Item(index: 6),
            Item(index: 7),
            Item(index: 8),
        ])

        let to = PagingItems(items: [
            Item(index: 4),
            Item(index: 5),
            Item(index: 6),
            Item(index: 7),
            Item(index: 8),
            Item(index: 9),
            Item(index: 10),
            Item(index: 11),
            Item(index: 12),
        ])

        let diff = PagingDiff(from: from, to: to)
        let removed = diff.removed()

        #expect(removed.count == 4)
        #expect(removed[0] == IndexPath(item: 0, section: 0))
        #expect(removed[1] == IndexPath(item: 1, section: 0))
        #expect(removed[2] == IndexPath(item: 2, section: 0))
        #expect(removed[3] == IndexPath(item: 3, section: 0))
    }

    @Test func scenario3() {
        let from = PagingItems(items: [
            Item(index: 1),
            Item(index: 2),
            Item(index: 10),
            Item(index: 11),
        ])

        let to = PagingItems(items: [
            Item(index: 2),
            Item(index: 3),
        ])

        let diff = PagingDiff(from: from, to: to)
        let added = diff.added()
        let removed = diff.removed()

        #expect(added == [])
        #expect(removed.count == 1)
        #expect(removed[0] == IndexPath(item: 0, section: 0))
    }
}

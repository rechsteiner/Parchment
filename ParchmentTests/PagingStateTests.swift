import Foundation
import Testing
@testable import Parchment

struct PagingStateTests {
    @Test func selected() {
        let state: PagingState = .selected(pagingItem: Item(index: 0))

        #expect(state.currentPagingItem as? Item? == Item(index: 0))
        #expect(state.upcomingPagingItem == nil)
        #expect(state.progress == 0)
        #expect(state.visuallySelectedPagingItem as? Item? == Item(index: 0))
    }

    @Test func scrollingCurrentPagingItem() {
        let state: PagingState = .scrolling(
            pagingItem: Item(index: 0),
            upcomingPagingItem: Item(index: 1),
            progress: 0,
            initialContentOffset: .zero,
            distance: 0
        )

        #expect(state.currentPagingItem as? Item? == Item(index: 0))
    }

    @Test func progress() {
        let state: PagingState = .scrolling(
            pagingItem: Item(index: 0),
            upcomingPagingItem: Item(index: 1),
            progress: 0.5,
            initialContentOffset: .zero,
            distance: 0
        )

        #expect(state.progress == 0.5)
    }

    @Test func upcomingPagingItem() {
        let state: PagingState = .scrolling(
            pagingItem: Item(index: 0),
            upcomingPagingItem: Item(index: 1),
            progress: 0,
            initialContentOffset: .zero,
            distance: 0
        )

        #expect(state.upcomingPagingItem as? Item? == Item(index: 1))
    }

    @Test func upcomingPagingItemNil() {
        let state: PagingState = .scrolling(
            pagingItem: Item(index: 0),
            upcomingPagingItem: nil,
            progress: 0,
            initialContentOffset: .zero,
            distance: 0
        )

        #expect(state.upcomingPagingItem == nil)
    }

    @Test func visuallySelectedPagingItemProgressLarge() {
        let state: PagingState = .scrolling(
            pagingItem: Item(index: 0),
            upcomingPagingItem: Item(index: 1),
            progress: 0.6,
            initialContentOffset: .zero,
            distance: 0
        )

        #expect(state.visuallySelectedPagingItem as? Item? == Item(index: 1))
    }

    @Test func visuallySelectedPagingItemProgressSmall() {
        let state: PagingState = .scrolling(
            pagingItem: Item(index: 0),
            upcomingPagingItem: Item(index: 1),
            progress: 0.3,
            initialContentOffset: .zero,
            distance: 0
        )

        #expect(state.visuallySelectedPagingItem as? Item? == Item(index: 0))
    }

    @Test func visuallySelectedPagingItemUpcomingPagingItemNil() {
        let state: PagingState = .scrolling(
            pagingItem: Item(index: 0),
            upcomingPagingItem: nil,
            progress: 0.6,
            initialContentOffset: .zero,
            distance: 0
        )

        #expect(state.visuallySelectedPagingItem as? Item? == Item(index: 0))
    }
}

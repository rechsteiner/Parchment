import Testing
@testable import Parchment

@MainActor
struct PagingDistanceCenteredTests {
    private let sizeCache: PagingSizeCache

    init() {
        sizeCache = PagingSizeCache(options: PagingOptions())
    }

    /// Distance from centered item to upcoming item.
    ///
    /// ```
    /// ┌────────────────────────────────────┐
    /// ├──┐┌────────┐┌────────┐┌────────┐┌──┤
    /// │  ││        ││  From  ││   To   ││  │
    /// ├──┘└────────┘└────────┘└────────┘└──┤
    /// └────────────────────────────────────┘
    /// x: 100
    /// ```
    @Test func distanceCentered() {
        let distance = createDistance(
            bounds: CGRect(x: 100, y: 0, width: 500, height: 50),
            contentSize: CGSize(width: 1000, height: 50),
            currentItem: Item(index: 0),
            currentItemBounds: CGRect(x: 300, y: 0, width: 100, height: 50),
            upcomingItem: Item(index: 1),
            upcomingItemBounds: CGRect(x: 400, y: 0, width: 100, height: 50),
            sizeCache: sizeCache,
            selectedScrollPosition: .preferCentered,
            navigationOrientation: .horizontal
        )

        let value = distance.calculate()
        #expect(value == 100)
    }

    /// Distance from non-centered item to upcoming item.
    ///
    /// ```
    /// ┌────────────────────────────────────┐
    /// ├──┐┌────────┐┌────────┐┌────────┐┌──┤
    /// │  ││  From  ││        ││   To   ││  │
    /// ├──┘└────────┘└────────┘└────────┘└──┤
    /// └────────────────────────────────────┘
    /// x: 100
    /// ```
    @Test func distanceCenteredFromNotCentered() {
        let distance = createDistance(
            bounds: CGRect(x: 100, y: 0, width: 400, height: 50),
            contentSize: CGSize(width: 1000, height: 50),
            currentItem: Item(index: 0),
            currentItemBounds: CGRect(x: 150, y: 0, width: 100, height: 50),
            upcomingItem: Item(index: 1),
            upcomingItemBounds: CGRect(x: 350, y: 0, width: 100, height: 50),
            sizeCache: sizeCache,
            selectedScrollPosition: .preferCentered,
            navigationOrientation: .horizontal
        )

        let value = distance.calculate()
        #expect(value == 100)
    }

    /// Distance to already centered item.
    ///
    /// ```
    /// ┌────────────────────────────────────┐
    /// ├──┐┌────────┐┌────────┐┌────────┐┌──┤
    /// │  ││  From  ││   To   ││        ││  │
    /// ├──┘└────────┘└────────┘└────────┘└──┤
    /// └────────────────────────────────────┘
    /// x: 100
    /// ```
    @Test func distanceCenteredToAlreadyCentered() {
        let distance = createDistance(
            bounds: CGRect(x: 100, y: 0, width: 400, height: 50),
            contentSize: CGSize(width: 1000, height: 50),
            currentItem: Item(index: 0),
            currentItemBounds: CGRect(x: 150, y: 0, width: 100, height: 50),
            upcomingItem: Item(index: 1),
            upcomingItemBounds: CGRect(x: 250, y: 0, width: 100, height: 50),
            sizeCache: sizeCache,
            selectedScrollPosition: .preferCentered,
            navigationOrientation: .horizontal
        )

        let value = distance.calculate()
        #expect(value == 0)
    }

    /// Distance from larger, centered item to smaller item after.
    ///
    /// ```
    /// ┌──────────────────────────────────────┐
    /// ├───┐┌───┐┌───┐┌────────┐┌───┐┌───┐┌───┤
    /// │   ││   ││   ││  From  ││To ││   ││   │
    /// ├───┘└───┘└───┘└────────┘└───┘└───┘└───┤
    /// └──────────────────────────────────────┘
    /// x: 100
    /// ```
    @Test func distanceCenteredUsingSizeDelegateScrollingForward() {
        sizeCache.implementsSizeDelegate = true
        sizeCache.sizeForPagingItem = { _, isSelected in
            if isSelected {
                return 100
            } else {
                return 50
            }
        }

        let distance = createDistance(
            bounds: CGRect(x: 100, y: 0, width: 400, height: 50),
            contentSize: CGSize(width: 1000, height: 50),
            currentItem: Item(index: 0),
            currentItemBounds: CGRect(x: 150, y: 0, width: 100, height: 50),
            upcomingItem: Item(index: 1),
            upcomingItemBounds: CGRect(x: 250, y: 0, width: 50, height: 50),
            sizeCache: sizeCache,
            selectedScrollPosition: .preferCentered,
            navigationOrientation: .horizontal
        )

        let value = distance.calculate()
        #expect(value == -50)
    }

    /// Distance from larger, centered item to smaller item before.
    ///
    /// ```
    /// ┌──────────────────────────────────────┐
    /// ├───┐┌───┐┌───┐┌────────┐┌───┐┌───┐┌───┤
    /// │   ││   ││To ││  From  ││   ││   ││   │
    /// ├───┘└───┘└───┘└────────┘└───┘└───┘└───┤
    /// └──────────────────────────────────────┘
    /// x: 100
    /// ```
    @Test func distanceCenteredUsingSizeDelegateScrollingBackward() {
        sizeCache.implementsSizeDelegate = true
        sizeCache.sizeForPagingItem = { _, isSelected in
            if isSelected {
                return 100
            } else {
                return 50
            }
        }

        let distance = createDistance(
            bounds: CGRect(x: 100, y: 0, width: 400, height: 50),
            contentSize: CGSize(width: 1000, height: 50),
            currentItem: Item(index: 1),
            currentItemBounds: CGRect(x: 150, y: 0, width: 100, height: 50),
            upcomingItem: Item(index: 0),
            upcomingItemBounds: CGRect(x: 100, y: 0, width: 50, height: 50),
            sizeCache: sizeCache,
            selectedScrollPosition: .preferCentered,
            navigationOrientation: .horizontal
        )

        let value = distance.calculate()
        #expect(value == -100)
    }

    /// Distance from an item scrolled out of view (so we don't have any
    /// layout attributes) to an item all the way on the other side.
    ///
    /// ```
    ///                ┌──────────────────────────────────────┐
    /// ┌────────┐     ├───┐┌───┐┌───┐┌───┐┌───┐┌───┐┌───┐┌───┤
    /// │  From  │ ... │   ││   ││   ││   ││   ││To ││   ││   │
    /// └────────┘     ├───┘└───┘└───┘└───┘└───┘└───┘└───┘└───┤
    ///                └──────────────────────────────────────┘
    ///                 x: 200
    /// ```
    @Test func distanceCenteredUsingSizeDelegateWithoutFromAttributes() {
        sizeCache.implementsSizeDelegate = true
        sizeCache.sizeForPagingItem = { _, isSelected in
            if isSelected {
                return 100
            } else {
                return 50
            }
        }

        let distance = createDistance(
            bounds: CGRect(x: 200, y: 0, width: 400, height: 50),
            contentSize: CGSize(width: 2000, height: 50),
            currentItem: Item(index: 1),
            currentItemBounds: nil,
            upcomingItem: Item(index: 0),
            upcomingItemBounds: CGRect(x: 450, y: 0, width: 50, height: 50),
            sizeCache: sizeCache,
            selectedScrollPosition: .preferCentered,
            navigationOrientation: .horizontal
        )

        let value = distance.calculate()
        #expect(value == 100)
    }

    /// Distance to item at the leading edge so it cannot be centered.
    ///
    /// ```
    /// ┌────────────────────────────────────┐
    /// ├────────┐┌────────┐┌────────┐┌──────┤
    /// │   To   ││        ││  From  ││      │
    /// ├────────┘└────────┘└────────┘└──────┤
    /// └────────────────────────────────────┘
    /// x: 0
    /// ```
    @Test func distanceCenteredToLeadingEdge() {
        let distance = createDistance(
            bounds: CGRect(x: 0, y: 0, width: 400, height: 50),
            contentSize: CGSize(width: 400, height: 50),
            currentItem: Item(index: 1),
            currentItemBounds: CGRect(x: 200, y: 0, width: 100, height: 50),
            upcomingItem: Item(index: 0),
            upcomingItemBounds: CGRect(x: 0, y: 0, width: 100, height: 50),
            sizeCache: sizeCache,
            selectedScrollPosition: .preferCentered,
            navigationOrientation: .horizontal
        )

        let value = distance.calculate()
        #expect(value == 0)
    }

    /// Distance to item at the leading edge so it cannot be centered,
    /// when using the size delegate.
    ///
    /// ```
    /// ┌────────────────────────────────────┐
    /// ├───┐┌───┐┌───┐┌───┐┌────────┐┌───┐┌─┤
    /// │To ││   ││   ││   ││  From  ││   ││ │
    /// ├───┘└───┘└───┘└───┘└────────┘└───┘└─┤
    /// └────────────────────────────────────┘
    /// x: 0
    /// ```
    @Test func distanceCenteredToLeadingEdgeWhenUsingSizeDelegate() {
        sizeCache.implementsSizeDelegate = true
        sizeCache.sizeForPagingItem = { _, isSelected in
            if isSelected {
                return 100
            } else {
                return 50
            }
        }

        let distance = createDistance(
            bounds: CGRect(x: 0, y: 0, width: 400, height: 50),
            contentSize: CGSize(width: 400, height: 50),
            currentItem: Item(index: 1),
            currentItemBounds: CGRect(x: 200, y: 0, width: 100, height: 50),
            upcomingItem: Item(index: 0),
            upcomingItemBounds: CGRect(x: 0, y: 0, width: 50, height: 50),
            sizeCache: sizeCache,
            selectedScrollPosition: .preferCentered,
            navigationOrientation: .horizontal
        )

        let value = distance.calculate()
        #expect(value == 0)
    }

    /// Distance to item at the trailing edge so it cannot be centered.
    ///
    /// ```
    /// ┌──────────────────────────────────────┐
    /// ├────────┐┌────────┐┌────────┐┌────────┤
    /// │        ││  From  ││        ││   To   │
    /// ├────────┘└────────┘└────────┘└────────┤
    /// └──────────────────────────────────────┘
    /// x: 600
    /// ```
    @Test func distanceCenteredToTrailingEdge() {
        let distance = createDistance(
            bounds: CGRect(x: 600, y: 0, width: 400, height: 50),
            contentSize: CGSize(width: 1000, height: 50),
            currentItem: Item(index: 0),
            currentItemBounds: CGRect(x: 700, y: 0, width: 100, height: 50),
            upcomingItem: Item(index: 1),
            upcomingItemBounds: CGRect(x: 900, y: 0, width: 100, height: 50),
            sizeCache: sizeCache,
            selectedScrollPosition: .preferCentered,
            navigationOrientation: .horizontal
        )

        let value = distance.calculate()
        #expect(value == 0)
    }

    /// Distance to item at the trailing edge so it cannot be centered,
    /// when using the size delegate.
    ///
    /// ```
    /// ┌──────────────────────────────────────┐
    /// ├───┐┌───┐┌────────┐┌───┐┌───┐┌───┐┌───┤
    /// │   ││   ││  From  ││   ││   ││   ││To │
    /// ├───┘└───┘└────────┘└───┘└───┘└───┘└───┤
    /// └──────────────────────────────────────┘
    /// x: 600
    /// ```
    @Test func distanceCenteredToTrailingEdgeWhenUsingSizeDelegate() {
        sizeCache.implementsSizeDelegate = true
        sizeCache.sizeForPagingItem = { _, isSelected in
            if isSelected {
                return 100
            } else {
                return 50
            }
        }

        let distance = createDistance(
            bounds: CGRect(x: 600, y: 0, width: 400, height: 50),
            contentSize: CGSize(width: 1000, height: 50),
            currentItem: Item(index: 0),
            currentItemBounds: CGRect(x: 700, y: 0, width: 100, height: 50),
            upcomingItem: Item(index: 1),
            upcomingItemBounds: CGRect(x: 950, y: 0, width: 50, height: 50),
            sizeCache: sizeCache,
            selectedScrollPosition: .preferCentered,
            navigationOrientation: .horizontal
        )

        let value = distance.calculate()
        #expect(value == 0)
    }

    /// Distance to item at the trailing edge when using the size
    /// delegate, with selected width so large that the items can be
    /// centered after the transition.
    ///
    /// ```
    ///                               ┌──────────────────────────────────────┐
    /// ┌─────────────────────────────┴──────────────────┐┌───┐┌───┐┌───┐┌───┤
    /// │                      From                      ││   ││   ││   ││To │
    /// └─────────────────────────────┬──────────────────┘└───┘└───┘└───┘└───┤
    ///                               └──────────────────────────────────────┘
    ///                               x: 600
    /// ```
    @Test func distanceCenteredToTrailingEdgeWhenUsingSizeDelegateWithHugeSelectedWidth() {
        sizeCache.implementsSizeDelegate = true
        sizeCache.sizeForPagingItem = { _, isSelected in
            if isSelected {
                return 500
            } else {
                return 50
            }
        }

        let distance = createDistance(
            bounds: CGRect(x: 600, y: 0, width: 400, height: 50),
            contentSize: CGSize(width: 1000, height: 50),
            currentItem: Item(index: 0),
            currentItemBounds: CGRect(x: 300, y: 0, width: 500, height: 50),
            upcomingItem: Item(index: 1),
            upcomingItemBounds: CGRect(x: 950, y: 0, width: 50, height: 50),
            sizeCache: sizeCache,
            selectedScrollPosition: .preferCentered,
            navigationOrientation: .horizontal
        )

        let value = distance.calculate()
        #expect(value == -50)
    }
}

import Testing
@testable import Parchment

@MainActor
struct PagingDistanceRightTests {
    private let sizeCache: PagingSizeCache

    init() {
        sizeCache = PagingSizeCache(options: PagingOptions())
    }

    /// Distance from right aligned item to upcoming item.
    ///
    /// ```
    /// ┌────────────────────────────────────┐
    /// │                           ┌────────┤┌────────┐┌────────┐┌────────┐
    /// │                           │  From  ││   To   ││        ││        │
    /// │                           └────────┤└────────┘└────────┘└────────┘
    /// └────────────────────────────────────┘
    /// x: 0
    /// ```
    @Test func distanceRight() {
        let distance = createDistance(
            bounds: CGRect(x: 0, y: 0, width: 500, height: 50),
            contentSize: CGSize(width: 1000, height: 50),
            currentItem: Item(index: 0),
            currentItemBounds: CGRect(x: 400, y: 0, width: 100, height: 50),
            upcomingItem: Item(index: 1),
            upcomingItemBounds: CGRect(x: 500, y: 0, width: 100, height: 50),
            sizeCache: sizeCache,
            selectedScrollPosition: .right,
            navigationOrientation: .horizontal
        )

        let value = distance.calculate()
        #expect(value == 100)
    }

    /// Distance from right aligned item to upcoming item.
    ///
    /// ```
    /// ┌────────────────────────────────────┐
    /// │                           ┌────────┤┌────────┐┌────────┐┌────────┐
    /// │                           │  From  ││        ││   To   ││        │
    /// │                           └────────┤└────────┘└────────┘└────────┘
    /// └────────────────────────────────────┘
    /// x: 0
    /// ```
    @Test func distanceRightWithItemsBetween() {
        let distance = createDistance(
            bounds: CGRect(x: 0, y: 0, width: 500, height: 50),
            contentSize: CGSize(width: 1000, height: 50),
            currentItem: Item(index: 0),
            currentItemBounds: CGRect(x: 400, y: 0, width: 100, height: 50),
            upcomingItem: Item(index: 2),
            upcomingItemBounds: CGRect(x: 600, y: 0, width: 100, height: 50),
            sizeCache: sizeCache,
            selectedScrollPosition: .right,
            navigationOrientation: .horizontal
        )

        let value = distance.calculate()
        #expect(value == 200)
    }

    /// Distance to upcoming item when scrolled slightly.
    ///
    /// ```
    /// ┌────────────────────────────────────┐
    /// ├──────┐┌────────┐┌────────┐┌────────┤┌────────┐
    /// │      ││        ││        ││  From  ││   To   │
    /// ├──────┘└────────┘└────────┘└────────┤└────────┘
    /// └────────────────────────────────────┘
    /// x: 50
    /// ```
    @Test func distanceRightWithContentOffset() {
        let distance = createDistance(
            bounds: CGRect(x: 50, y: 0, width: 500, height: 50),
            contentSize: CGSize(width: 1000, height: 50),
            currentItem: Item(index: 0),
            currentItemBounds: CGRect(x: 400, y: 0, width: 100, height: 50),
            upcomingItem: Item(index: 1),
            upcomingItemBounds: CGRect(x: 500, y: 0, width: 100, height: 50),
            sizeCache: sizeCache,
            selectedScrollPosition: .right,
            navigationOrientation: .horizontal
        )

        let value = distance.calculate()
        #expect(value == 50)
    }

    /// Distance from larger, right-aligned item positioned before
    /// smaller upcoming item.
    ///
    /// ```
    /// ┌───────────────────────────────────────┐
    /// │    ┌────┐┌────┐┌────┐┌────┐┌──────────┤┌────┐┌────┐
    /// │    │    ││    ││    ││    ││   From   ││ To ││    │
    /// │    └────┘└────┘└────┘└────┘└──────────┤└────┘└────┘
    /// └───────────────────────────────────────┘
    /// x: 0
    /// ```
    @Test func distanceRightUsingSizeDelegateScrollingForward() {
        sizeCache.implementsSizeDelegate = true
        sizeCache.sizeForPagingItem = { _, isSelected in
            if isSelected {
                return 100
            } else {
                return 50
            }
        }

        let distance = createDistance(
            bounds: CGRect(x: 0, y: 0, width: 500, height: 50),
            contentSize: CGSize(width: 1000, height: 50),
            currentItem: Item(index: 0),
            currentItemBounds: CGRect(x: 500, y: 0, width: 100, height: 50),
            upcomingItem: Item(index: 1),
            upcomingItemBounds: CGRect(x: 500, y: 0, width: 50, height: 50),
            sizeCache: sizeCache,
            selectedScrollPosition: .right,
            navigationOrientation: .horizontal
        )

        let value = distance.calculate()
        #expect(value == 50)
    }

    /// Distance from larger, right-aligned item positioned after
    /// smaller larger item.
    ///
    /// ```
    /// ┌───────────────────────────────────────┐
    /// ├───┐┌────┐┌────┐┌────┐┌────┐┌──────────┤┌────┐┌────┐
    /// │   ││    ││    ││    ││ To ││   From   ││    ││    │
    /// ├───┘└────┘└────┘└────┘└────┘└──────────┤└────┘└────┘
    /// └───────────────────────────────────────┘
    /// x: 200
    /// ```
    @Test func distanceRightUsingSizeDelegateScrollingBackward() {
        sizeCache.implementsSizeDelegate = true
        sizeCache.sizeForPagingItem = { _, isSelected in
            if isSelected {
                return 100
            } else {
                return 50
            }
        }

        let distance = createDistance(
            bounds: CGRect(x: 200, y: 0, width: 500, height: 50),
            contentSize: CGSize(width: 2000, height: 50),
            currentItem: Item(index: 1),
            currentItemBounds: CGRect(x: 600, y: 0, width: 100, height: 50),
            upcomingItem: Item(index: 0),
            upcomingItemBounds: CGRect(x: 550, y: 0, width: 50, height: 50),
            sizeCache: sizeCache,
            selectedScrollPosition: .right,
            navigationOrientation: .horizontal
        )

        let value = distance.calculate()
        #expect(value == -50)
    }

    /// Distance from an item scrolled out of view (so we don't have any
    /// layout attributes) to an item all the way on the other side.
    ///
    /// ```
    ///                  ┌───────────────────────────────────────┐
    /// ┌──────────┐    ┌┴───┐┌────┐┌────┐┌────┐┌────┐┌────┐┌────┤
    /// │   From   │ ...│    ││    ││    ││    ││    ││    ││ To │
    /// └──────────┘    └┬───┘└────┘└────┘└────┘└────┘└────┘└────┤
    ///                  └───────────────────────────────────────┘
    ///                  x: 200
    /// ```
    @Test func distanceRightUsingSizeDelegateWithoutFromAttributes() {
        sizeCache.implementsSizeDelegate = true
        sizeCache.sizeForPagingItem = { _, isSelected in
            if isSelected {
                return 100
            } else {
                return 50
            }
        }

        let distance = createDistance(
            bounds: CGRect(x: 200, y: 0, width: 500, height: 50),
            contentSize: CGSize(width: 2000, height: 50),
            currentItem: Item(index: 1),
            currentItemBounds: nil,
            upcomingItem: Item(index: 0),
            upcomingItemBounds: CGRect(x: 650, y: 0, width: 50, height: 50),
            sizeCache: sizeCache,
            selectedScrollPosition: .right,
            navigationOrientation: .horizontal
        )

        let value = distance.calculate()
        #expect(value == 50)
    }
}

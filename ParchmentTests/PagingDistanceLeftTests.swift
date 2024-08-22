import Testing
@testable import Parchment

@MainActor
struct PagingDistanceLeftTests {
    private let sizeCache: PagingSizeCache

    init() {
        sizeCache = PagingSizeCache(options: PagingOptions())
    }

    /// Distance from left aligned item to upcoming item.
    ///
    /// ```
    /// ┌────────────────────────────────────┐
    /// ├────────┐┌────────┐┌───────┐┌───────┤
    /// │  From  ││   To   ││       ││       │
    /// ├────────┘└────────┘└───────┘└───────┤
    /// └────────────────────────────────────┘
    /// x: 0
    /// ```
    @Test func distanceLeft() {
        let distance = createDistance(
            currentItem: Item(index: 0),
            currentItemBounds: CGRect(x: 0, y: 0, width: 100, height: 100),
            upcomingItem: Item(index: 1),
            upcomingItemBounds: CGRect(x: 100, y: 0, width: 100, height: 100),
            sizeCache: sizeCache,
            selectedScrollPosition: .left,
            navigationOrientation: .horizontal
        )

        let value = distance.calculate()
        #expect(value == 100)
    }

    /// Distance from left aligned item to upcoming item with other
    /// items in between.
    ///
    /// ```
    /// ┌────────────────────────────────────┐
    /// ├────────┐┌────────┐┌────────┐┌──────┤
    /// │  From  ││        ││   To   ││      │
    /// ├────────┘└────────┘└────────┘└──────┤
    /// └────────────────────────────────────┘
    /// x: 0
    /// ```
    @Test func distanceLeftWithItemsBetween() {
        let distance = createDistance(
            currentItem: Item(index: 0),
            currentItemBounds: CGRect(x: 0, y: 0, width: 100, height: 100),
            upcomingItem: Item(index: 1),
            upcomingItemBounds: CGRect(x: 200, y: 0, width: 100, height: 100),
            sizeCache: sizeCache,
            selectedScrollPosition: .left,
            navigationOrientation: .horizontal
        )

        let value = distance.calculate()
        #expect(value == 200)
    }

    /// Distance to upcoming item when scrolled slightly.
    ///
    /// ```
    ///      ┌────────────────────────────────────┐
    /// ┌────┴───┐┌────────┐┌───────┐┌───────┐┌───┤
    /// │  From  ││   To   ││       ││       ││   │
    /// └────┬───┘└────────┘└───────┘└───────┘└───┤
    ///      └────────────────────────────────────┘
    ///      x: 50
    /// ```
    @Test func distanceLeftWithContentOffset() {
        let distance = createDistance(
            bounds: CGRect(origin: CGPoint(x: 50, y: 0), size: .zero),
            currentItem: Item(index: 0),
            currentItemBounds: CGRect(x: 0, y: 0, width: 100, height: 100),
            upcomingItem: Item(index: 1),
            upcomingItemBounds: CGRect(x: 100, y: 0, width: 100, height: 100),
            sizeCache: sizeCache,
            selectedScrollPosition: .left,
            navigationOrientation: .horizontal
        )

        let value = distance.calculate()
        #expect(value == 50)
    }

    /// Distance from larger, left-aligned item positioned before
    /// smaller upcoming item.
    ///
    /// ```
    ///             ┌───────────────────────────────────────┐
    /// ┌────┐┌────┐├──────────┐┌────┐┌────┐┌────┐┌────┐┌───┤
    /// │    ││    ││   From   ││ To ││    ││    ││    ││   │
    /// └────┘└────┘├──────────┘└────┘└────┘└────┘└────┘└───┤
    ///             └───────────────────────────────────────┘
    ///             x: 500
    /// ```
    @Test func distanceLeftUsingSizeDelegateScrollingForward() {
        sizeCache.implementsSizeDelegate = true
        sizeCache.sizeForPagingItem = { _, isSelected in
            if isSelected {
                return 100
            } else {
                return 50
            }
        }

        let distance = createDistance(
            bounds: CGRect(origin: CGPoint(x: 500, y: 0), size: .zero),
            contentSize: CGSize(width: 1000, height: 50),
            currentItem: Item(index: 0),
            currentItemBounds: CGRect(x: 500, y: 0, width: 100, height: 50),
            upcomingItem: Item(index: 1),
            upcomingItemBounds: CGRect(x: 600, y: 0, width: 50, height: 50),
            sizeCache: sizeCache,
            selectedScrollPosition: .left,
            navigationOrientation: .horizontal
        )

        let value = distance.calculate()
        #expect(value == 50)
    }

    /// Distance from larger, left-aligned item positioned after
    /// smaller larger item.
    ///
    /// ```
    ///             ┌───────────────────────────────────────┐
    /// ┌────┐┌────┐├──────────┐┌────┐┌────┐┌────┐┌────┐┌───┤
    /// │    ││ To ││   From   ││    ││    ││    ││    ││   │
    /// └────┘└────┘├──────────┘└────┘└────┘└────┘└────┘└───┤
    ///             └───────────────────────────────────────┘
    ///             x: 500
    /// ```
    @Test func distanceLeftUsingSizeDelegateScrollingBackward() {
        sizeCache.implementsSizeDelegate = true
        sizeCache.sizeForPagingItem = { _, _ in
            // Expects it to ignore this value when scrolling backwards so
            // setting it the a big number to notice if it's being used.
            1000
        }

        let distance = createDistance(
            bounds: CGRect(origin: CGPoint(x: 500, y: 0), size: .zero),
            contentSize: CGSize(width: 1000, height: 50),
            currentItem: Item(index: 1),
            currentItemBounds: CGRect(x: 500, y: 0, width: 100, height: 50),
            upcomingItem: Item(index: 0),
            upcomingItemBounds: CGRect(x: 450, y: 0, width: 50, height: 50),
            sizeCache: sizeCache,
            selectedScrollPosition: .left,
            navigationOrientation: .horizontal
        )

        let value = distance.calculate()
        #expect(value == -50)
    }
}

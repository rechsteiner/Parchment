@testable import Parchment
import XCTest

@MainActor
final class PagingDistanceCenteredTests: XCTestCase {
    private var sizeCache: PagingSizeCache!

    override func setUp() {
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
    func testDistanceCentered() {
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
        XCTAssertEqual(value, 100)
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
    func testDistanceCenteredFromNotCentered() {
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
        XCTAssertEqual(value, 100)
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
    func testDistanceCenteredToAlreadyCentered() {
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
        XCTAssertEqual(value, 0)
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
    func testDistanceCenteredUsingSizeDelegateScrollingForward() {
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
        XCTAssertEqual(value, -50)
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
    func testDistanceCenteredUsingSizeDelegateScrollingBackward() {
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
        XCTAssertEqual(value, -100)
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
    func testDistanceCenteredUsingSizeDelegateWithoutFromAttributes() {
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
        XCTAssertEqual(value, 100)
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
    func testDistanceCenteredToLeadingEdge() {
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
        XCTAssertEqual(value, 0)
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
    func testDistanceCenteredToLeadingEdgeWhenUsingSizeDelegate() {
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
        XCTAssertEqual(value, 0)
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
    func testDistanceCenteredToTrailingEdge() {
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
        XCTAssertEqual(value, 0)
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
    func testDistanceCenteredToTrailingEdgeWhenUsingSizeDelegate() {
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
        XCTAssertEqual(value, 0)
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
    func testDistanceCenteredToTrailingEdgeWhenUsingSizeDelegateWithHugeSelectedWidth() {
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
        XCTAssertEqual(value, -50)
    }
}

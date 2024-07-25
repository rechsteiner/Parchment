@testable import Parchment
import UIKit
import XCTest

@MainActor
final class PagingCollectionViewLayoutTests: XCTestCase {
    private var window: UIWindow!
    private var options: PagingOptions!
    private var dataSource: DataSource!
    private var sizeCache: PagingSizeCache!
    private var layout: PagingCollectionViewLayout!
    private var collectionView: UICollectionView!

    override func setUp() {
        options = PagingOptions()
        sizeCache = PagingSizeCache(options: options)
    }

    // MARK: - Cell Frames

    func testCellFramesForItemSizeFixed() {
        options.menuItemSize = .fixed(width: 100, height: 50)
        setupLayout()
        let frames = sortedCellFrames()

        XCTAssertEqual(frames, [
            CGRect(x: 0, y: 0, width: 100, height: 50),
            CGRect(x: 100, y: 0, width: 100, height: 50),
            CGRect(x: 200, y: 0, width: 100, height: 50),
        ])
    }

    func testCellFramesForItemSizeToFit() {
        options.menuItemSize = .sizeToFit(minWidth: 10, height: 50)
        options.menuHorizontalAlignment = .center
        setupLayout()
        let frames = sortedCellFrames()
        let expectedWidth = UIScreen.main.bounds.width / 3

        XCTAssertEqual(frames, [
            CGRect(x: 0, y: 0, width: expectedWidth, height: 50),
            CGRect(x: expectedWidth, y: 0, width: expectedWidth, height: 50),
            CGRect(x: expectedWidth * 2, y: 0, width: expectedWidth, height: 50),
        ])
    }

    func testCellFramesForItemSizeToFitWhenMinWidthExtendsOutside() {
        let minWidth = UIScreen.main.bounds.width
        options.menuItemSize = .sizeToFit(minWidth: minWidth, height: 50)
        options.menuHorizontalAlignment = .center
        setupLayout()
        let frames = sortedCellFrames()

        XCTAssertEqual(frames, [
            CGRect(x: 0, y: 0, width: minWidth, height: 50),
            CGRect(x: minWidth, y: 0, width: minWidth, height: 50),
            CGRect(x: minWidth * 2, y: 0, width: minWidth, height: 50),
        ])
    }

    func testCellFramesForItemSizeToFitWhenUsingSizeDelegate() {
        sizeCache.implementsSizeDelegate = true
        sizeCache.sizeForPagingItem = { _, _ in
            50
        }
        setupLayout()
        options.menuItemSize = .sizeToFit(minWidth: 10, height: 50)
        setupLayout()
        let frames = sortedCellFrames()

        // Expects it to use the size delegate width and not size the
        // cells to match the bounds.
        XCTAssertEqual(frames, [
            CGRect(x: 0, y: 0, width: 50, height: 50),
            CGRect(x: 50, y: 0, width: 50, height: 50),
            CGRect(x: 100, y: 0, width: 50, height: 50),
        ])
    }

    func testCellFramesForItemSizeSelfSizing() {
        options.menuItemSize = .selfSizing(estimatedWidth: 0, height: 50)
        setupLayout()
        let frames = sortedCellFrames()

        XCTAssertEqual(frames, [
            CGRect(x: 0, y: 0, width: 50, height: 50),
            CGRect(x: 50, y: 0, width: 100, height: 50),
            CGRect(x: 150, y: 0, width: 150, height: 50),
        ])
    }

    func testCellFramesForSizeDelegate() {
        options.menuItemSize = .fixed(width: 0, height: 50)
        sizeCache.implementsSizeDelegate = true
        sizeCache.sizeForPagingItem = { _, isSelected in
            if isSelected {
                return 100
            } else {
                return 50
            }
        }
        setupLayout()

        let frames = sortedCellFrames()

        XCTAssertEqual(frames, [
            CGRect(x: 0, y: 0, width: 100, height: 50),
            CGRect(x: 100, y: 0, width: 50, height: 50),
            CGRect(x: 150, y: 0, width: 50, height: 50),
        ])
    }

    func testCellFramesForSizeDelegateWhenScrollingToItem() {
        options.menuItemSize = .fixed(width: 0, height: 50)
        sizeCache.implementsSizeDelegate = true
        sizeCache.sizeForPagingItem = { _, isSelected in
            if isSelected {
                return 100
            } else {
                return 50
            }
        }
        setupLayout()
        layout.state = .scrolling(
            pagingItem: Item(index: 0),
            upcomingPagingItem: Item(index: 1),
            progress: 0.5,
            initialContentOffset: .zero,
            distance: 50
        )
        layout.invalidateLayout()
        collectionView.layoutIfNeeded()

        let frames = sortedCellFrames()

        XCTAssertEqual(frames, [
            CGRect(x: 0, y: 0, width: 75, height: 50),
            CGRect(x: 75, y: 0, width: 75, height: 50),
            CGRect(x: 150, y: 0, width: 50, height: 50),
        ])
    }

    func testCellFramesForHorizontalMenuAlignment() {
        options.menuItemSize = .fixed(width: 10, height: 50)
        options.menuHorizontalAlignment = .center
        setupLayout()

        let frames = sortedCellFrames()
        let expectedInsets = (UIScreen.main.bounds.width - 30) / 2

        XCTAssertEqual(frames, [
            CGRect(x: expectedInsets, y: 0, width: 10, height: 50),
            CGRect(x: 10 + expectedInsets, y: 0, width: 10, height: 50),
            CGRect(x: 20 + expectedInsets, y: 0, width: 10, height: 50),
        ])
    }

    func testCellFramesForSelectedScrollPositionCentered() {
        let expectedWidth = UIScreen.main.bounds.width / 2
        options.menuItemSize = .fixed(width: expectedWidth, height: 50)
        options.selectedScrollPosition = .center
        setupLayout()

        let frames = sortedCellFrames()
        let expectedInsets = (UIScreen.main.bounds.width / 2) - (expectedWidth / 2)

        XCTAssertEqual(frames, [
            CGRect(x: expectedInsets, y: 0, width: expectedWidth, height: 50),
            CGRect(x: expectedInsets + expectedWidth, y: 0, width: expectedWidth, height: 50),
            CGRect(x: expectedInsets + expectedWidth * 2, y: 0, width: expectedWidth, height: 50),
        ])
    }

    // MARK: - Indicator Frame

    func testIndicatorFrame() {
        options.menuItemSize = .fixed(width: 100, height: 50)
        options.indicatorOptions = .visible(height: 10, zIndex: Int.max, spacing: .zero, insets: .zero)
        setupLayout()

        layout.state = .selected(pagingItem: Item(index: 1))
        layout.invalidateLayout()
        collectionView.layoutIfNeeded()

        let frame = indicatorFrame()

        XCTAssertEqual(frame, CGRect(x: 100, y: 40, width: 100, height: 10))
    }

    func testIndicatorFrameWithInsets() {
        let insets = UIEdgeInsets(top: 0, left: 20, bottom: 20, right: 20)
        options.menuItemSize = .fixed(width: 100, height: 50)
        options.indicatorOptions = .visible(height: 10, zIndex: Int.max, spacing: .zero, insets: insets)
        setupLayout()

        layout.state = .selected(pagingItem: Item(index: 0))
        layout.invalidateLayout()
        collectionView.layoutIfNeeded()

        let frame = indicatorFrame()

        XCTAssertEqual(frame, CGRect(x: 20, y: 20, width: 80, height: 10))
    }

    func testIndicatorFrameWithSpacing() {
        let spacing = UIEdgeInsets(top: 0, left: 20, bottom: 20, right: 20)
        options.menuItemSize = .fixed(width: 100, height: 50)
        options.indicatorOptions = .visible(height: 10, zIndex: Int.max, spacing: spacing, insets: .zero)
        setupLayout()

        layout.state = .selected(pagingItem: Item(index: 0))
        layout.invalidateLayout()
        collectionView.layoutIfNeeded()

        let frame = indicatorFrame()

        XCTAssertEqual(frame, CGRect(x: 20, y: 40, width: 60, height: 10))
    }

    func testIndicatorFrameOutsideFirstItem() {
        options.menuItemSize = .fixed(width: 100, height: 50)
        options.indicatorOptions = .visible(height: 10, zIndex: Int.max, spacing: .zero, insets: .zero)
        setupLayout()

        layout.state = .scrolling(
            pagingItem: Item(index: 0),
            upcomingPagingItem: nil,
            progress: -1,
            initialContentOffset: .zero,
            distance: 0
        )
        layout.invalidateLayout()
        collectionView.layoutIfNeeded()

        let frame = indicatorFrame()

        XCTAssertEqual(frame, CGRect(x: -100, y: 40, width: 100, height: 10))
    }

    func testIndicatorFrameOutsideLastItem() {
        options.menuItemSize = .fixed(width: 100, height: 50)
        options.indicatorOptions = .visible(height: 10, zIndex: Int.max, spacing: .zero, insets: .zero)
        setupLayout()

        layout.state = .scrolling(
            pagingItem: Item(index: 3),
            upcomingPagingItem: nil,
            progress: 1,
            initialContentOffset: .zero,
            distance: 0
        )
        layout.invalidateLayout()
        collectionView.layoutIfNeeded()

        let frame = indicatorFrame()

        XCTAssertEqual(frame, CGRect(x: 300, y: 40, width: 100, height: 10))
    }

    // MARK: - Border Frame

    func testBorderFrame() {
        options.menuItemSize = .fixed(width: 100, height: 50)
        options.borderOptions = .visible(height: 10, zIndex: Int.max, insets: .zero)
        setupLayout()

        let frame = borderFrame()
        let expectedWidth = UIScreen.main.bounds.width

        XCTAssertEqual(frame, CGRect(x: 0, y: 40, width: expectedWidth, height: 10))
    }

    func testBorderFrameWithInsets() {
        let insets = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
        options.menuItemSize = .fixed(width: 100, height: 50)
        options.borderOptions = .visible(height: 10, zIndex: Int.max, insets: insets)
        setupLayout()

        let frame = borderFrame()
        let expectedWidth = UIScreen.main.bounds.width - insets.left - insets.right

        XCTAssertEqual(frame, CGRect(x: insets.left, y: 40, width: expectedWidth, height: 10))
    }

    // MARK: - Private

    private func borderFrame() -> CGRect? {
        let layoutAttributes = layout.layoutAttributesForElements(in: collectionView.bounds) ?? []
        return layoutAttributes
            .filter { $0 is PagingBorderLayoutAttributes }
            .map { $0.frame }
            .first
    }

    private func indicatorFrame() -> CGRect? {
        let layoutAttributes = layout.layoutAttributesForElements(in: collectionView.bounds) ?? []
        return layoutAttributes
            .filter { $0 is PagingIndicatorLayoutAttributes }
            .map { $0.frame }
            .first
    }

    private func sortedCellFrames() -> [CGRect] {
        let layoutAttributes = layout.layoutAttributesForElements(in: collectionView.bounds) ?? []
        return layoutAttributes
            .filter { $0 is PagingCellLayoutAttributes }
            .sorted { $0.indexPath < $1.indexPath }
            .map { $0.frame }
    }

    private func setupLayout() {
        layout = PagingCollectionViewLayout()
        layout.options = options
        layout.sizeCache = sizeCache
        layout.state = .selected(pagingItem: Item(index: 0))
        layout.visibleItems = PagingItems(items: [
            Item(index: 0),
            Item(index: 1),
            Item(index: 2),
        ])

        dataSource = DataSource()
        collectionView = UICollectionView(
            frame: UIScreen.main.bounds,
            collectionViewLayout: layout
        )
        collectionView.dataSource = dataSource
        collectionView.register(
            Cell.self,
            forCellWithReuseIdentifier: DataSource.CellIdentifier
        )

        window = UIWindow(frame: UIScreen.main.bounds)
        window.addSubview(collectionView)
        window.makeKeyAndVisible()

        // Trigger a layout invalidation by calling layoutIfNeeded
        collectionView.layoutIfNeeded()
    }
}

private final class DataSource: NSObject, UICollectionViewDataSource {
    static let CellIdentifier = "CellIdentifier"

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        return collectionView.dequeueReusableCell(
            withReuseIdentifier: Self.CellIdentifier,
            for: indexPath
        )
    }

    func numberOfSections(in _: UICollectionView) -> Int {
        return 1
    }

    func collectionView(_: UICollectionView, numberOfItemsInSection _: Int) -> Int {
        return 3
    }
}

private final class Cell: UICollectionViewCell {
    override func preferredLayoutAttributesFitting(_ layoutAttributes: UICollectionViewLayoutAttributes) -> UICollectionViewLayoutAttributes {
        var frame = layoutAttributes.frame
        frame.size.width = CGFloat((layoutAttributes.indexPath.item + 1) * 50)
        layoutAttributes.frame = frame
        return layoutAttributes
    }
}

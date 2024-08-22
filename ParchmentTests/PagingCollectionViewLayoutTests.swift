import UIKit
import Testing
@testable import Parchment

@MainActor
final class PagingCollectionViewLayoutTests {
    private let options: PagingOptions
    private let dataSource: DataSource
    private let sizeCache: PagingSizeCache
    private let layout: PagingCollectionViewLayout
    private let collectionView: UICollectionView

    init() {
        options = PagingOptions()
        sizeCache = PagingSizeCache(options: options)

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

        // Trigger a layout invalidation by calling layoutIfNeeded
        collectionView.layoutIfNeeded()
    }

    // MARK: - Cell Frames

    @Test func cellFramesForItemSizeFixed() {
        layout.options.menuItemSize = .fixed(width: 100, height: 50)

        let frames = createSortedCellFrames()

        #expect(frames == [
            CGRect(x: 0, y: 0, width: 100, height: 50),
            CGRect(x: 100, y: 0, width: 100, height: 50),
            CGRect(x: 200, y: 0, width: 100, height: 50),
        ])
    }

    @Test func cellFramesForItemSizeToFit() {
        layout.options.menuItemSize = .sizeToFit(minWidth: 10, height: 50)
        layout.options.menuHorizontalAlignment = .center

        let frames = createSortedCellFrames()
        let expectedWidth = UIScreen.main.bounds.width / 3

        #expect(frames == [
            CGRect(x: 0, y: 0, width: expectedWidth, height: 50),
            CGRect(x: expectedWidth, y: 0, width: expectedWidth, height: 50),
            CGRect(x: expectedWidth * 2, y: 0, width: expectedWidth, height: 50),
        ])
    }

    @Test func cellFramesForItemSizeToFitWhenMinWidthExtendsOutside() {
        let minWidth = UIScreen.main.bounds.width
        layout.options.menuItemSize = .sizeToFit(minWidth: minWidth, height: 50)
        layout.options.menuHorizontalAlignment = .center

        let frames = createSortedCellFrames()

        #expect(frames == [
            CGRect(x: 0, y: 0, width: minWidth, height: 50),
            CGRect(x: minWidth, y: 0, width: minWidth, height: 50),
            CGRect(x: minWidth * 2, y: 0, width: minWidth, height: 50),
        ])
    }

    @Test func cellFramesForItemSizeToFitWhenUsingSizeDelegate() {
        sizeCache.implementsSizeDelegate = true
        sizeCache.sizeForPagingItem = { _, _ in
            50
        }
        layout.options.menuItemSize = .sizeToFit(minWidth: 10, height: 50)

        let frames = createSortedCellFrames()

        // Expects it to use the size delegate width and not size the
        // cells to match the bounds.
        #expect(frames == [
            CGRect(x: 0, y: 0, width: 50, height: 50),
            CGRect(x: 50, y: 0, width: 50, height: 50),
            CGRect(x: 100, y: 0, width: 50, height: 50),
        ])
    }

    @Test func cellFramesForItemSizeSelfSizing() {
        layout.options.menuItemSize = .selfSizing(estimatedWidth: 0, height: 50)

        let frames = createSortedCellFrames()

        #expect(frames == [
            CGRect(x: 0, y: 0, width: 50, height: 50),
            CGRect(x: 50, y: 0, width: 100, height: 50),
            CGRect(x: 150, y: 0, width: 150, height: 50),
        ])
    }

    @Test func cellFramesForSizeDelegate() {
        layout.options.menuItemSize = .fixed(width: 0, height: 50)
        sizeCache.implementsSizeDelegate = true
        sizeCache.sizeForPagingItem = { _, isSelected in
            if isSelected {
                return 100
            } else {
                return 50
            }
        }

        let frames = createSortedCellFrames()

        #expect(frames == [
            CGRect(x: 0, y: 0, width: 100, height: 50),
            CGRect(x: 100, y: 0, width: 50, height: 50),
            CGRect(x: 150, y: 0, width: 50, height: 50),
        ])
    }

    @Test func cellFramesForSizeDelegateWhenScrollingToItem() {
        layout.options.menuItemSize = .fixed(width: 0, height: 50)
        sizeCache.implementsSizeDelegate = true
        sizeCache.sizeForPagingItem = { _, isSelected in
            if isSelected {
                return 100
            } else {
                return 50
            }
        }

        layout.state = .scrolling(
            pagingItem: Item(index: 0),
            upcomingPagingItem: Item(index: 1),
            progress: 0.5,
            initialContentOffset: .zero,
            distance: 50
        )
        layout.invalidateLayout()
        collectionView.layoutIfNeeded()

        let frames = createSortedCellFrames()

        #expect(frames == [
            CGRect(x: 0, y: 0, width: 75, height: 50),
            CGRect(x: 75, y: 0, width: 75, height: 50),
            CGRect(x: 150, y: 0, width: 50, height: 50),
        ])
    }

    @Test func cellFramesForHorizontalMenuAlignment() {
        layout.options.menuItemSize = .fixed(width: 10, height: 50)
        layout.options.menuHorizontalAlignment = .center

        let frames = createSortedCellFrames()
        let expectedInsets = (UIScreen.main.bounds.width - 30) / 2

        #expect(frames == [
            CGRect(x: expectedInsets, y: 0, width: 10, height: 50),
            CGRect(x: 10 + expectedInsets, y: 0, width: 10, height: 50),
            CGRect(x: 20 + expectedInsets, y: 0, width: 10, height: 50),
        ])
    }

    @Test func cellFramesForSelectedScrollPositionCentered() {
        let expectedWidth = UIScreen.main.bounds.width / 2
        layout.options.menuItemSize = .fixed(width: expectedWidth, height: 50)
        layout.options.selectedScrollPosition = .center

        let frames = createSortedCellFrames()
        let expectedInsets = (UIScreen.main.bounds.width / 2) - (expectedWidth / 2)

        #expect(frames == [
            CGRect(x: expectedInsets, y: 0, width: expectedWidth, height: 50),
            CGRect(x: expectedInsets + expectedWidth, y: 0, width: expectedWidth, height: 50),
            CGRect(x: expectedInsets + expectedWidth * 2, y: 0, width: expectedWidth, height: 50),
        ])
    }

    // MARK: - Indicator Frame

    @Test func indicatorFrame() {
        layout.options.menuItemSize = .fixed(width: 100, height: 50)
        layout.options.indicatorOptions = .visible(height: 10, zIndex: Int.max, spacing: .zero, insets: .zero)

        layout.state = .selected(pagingItem: Item(index: 1))
        layout.invalidateLayout()
        collectionView.layoutIfNeeded()

        let frame = createIndicatorFrame()

        #expect(frame == CGRect(x: 100, y: 40, width: 100, height: 10))
    }

    @Test func indicatorFrameWithInsets() {
        let insets = UIEdgeInsets(top: 0, left: 20, bottom: 20, right: 20)
        layout.options.menuItemSize = .fixed(width: 100, height: 50)
        layout.options.indicatorOptions = .visible(height: 10, zIndex: Int.max, spacing: .zero, insets: insets)

        layout.state = .selected(pagingItem: Item(index: 0))
        layout.invalidateLayout()
        collectionView.layoutIfNeeded()

        let frame = createIndicatorFrame()

        #expect(frame == CGRect(x: 20, y: 20, width: 80, height: 10))
    }

    @Test func indicatorFrameWithSpacing() {
        let spacing = UIEdgeInsets(top: 0, left: 20, bottom: 20, right: 20)
        layout.options.menuItemSize = .fixed(width: 100, height: 50)
        layout.options.indicatorOptions = .visible(height: 10, zIndex: Int.max, spacing: spacing, insets: .zero)

        layout.state = .selected(pagingItem: Item(index: 0))
        layout.invalidateLayout()
        collectionView.layoutIfNeeded()

        let frame = createIndicatorFrame()

        #expect(frame == CGRect(x: 20, y: 40, width: 60, height: 10))
    }

    @Test func indicatorFrameOutsideFirstItem() {
        layout.options.menuItemSize = .fixed(width: 100, height: 50)
        layout.options.indicatorOptions = .visible(height: 10, zIndex: Int.max, spacing: .zero, insets: .zero)

        layout.state = .scrolling(
            pagingItem: Item(index: 0),
            upcomingPagingItem: nil,
            progress: -1,
            initialContentOffset: .zero,
            distance: 0
        )
        layout.invalidateLayout()
        collectionView.layoutIfNeeded()

        let frame = createIndicatorFrame()

        #expect(frame == CGRect(x: -100, y: 40, width: 100, height: 10))
    }

    @Test func indicatorFrameOutsideLastItem() {
        layout.options.menuItemSize = .fixed(width: 100, height: 50)
        layout.options.indicatorOptions = .visible(height: 10, zIndex: Int.max, spacing: .zero, insets: .zero)

        layout.state = .scrolling(
            pagingItem: Item(index: 3),
            upcomingPagingItem: nil,
            progress: 1,
            initialContentOffset: .zero,
            distance: 0
        )
        layout.invalidateLayout()
        collectionView.layoutIfNeeded()

        let frame = createIndicatorFrame()

        #expect(frame == CGRect(x: 300, y: 40, width: 100, height: 10))
    }

    // MARK: - Border Frame

    @Test func borderFrame() {
        layout.options.menuItemSize = .fixed(width: 100, height: 50)
        layout.options.borderOptions = .visible(height: 10, zIndex: Int.max, insets: .zero)

        let frame = createBorderFrame()
        let expectedWidth = UIScreen.main.bounds.width

        #expect(frame == CGRect(x: 0, y: 40, width: expectedWidth, height: 10))
    }

    @Test func borderFrameWithInsets() {
        let insets = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
        layout.options.menuItemSize = .fixed(width: 100, height: 50)
        layout.options.borderOptions = .visible(height: 10, zIndex: Int.max, insets: insets)

        let frame = createBorderFrame()
        let expectedWidth = UIScreen.main.bounds.width - insets.left - insets.right

        #expect(frame == CGRect(x: insets.left, y: 40, width: expectedWidth, height: 10))
    }

    // MARK: - Private

    private func createBorderFrame() -> CGRect? {
        layout.invalidateLayout()
        collectionView.layoutIfNeeded()

        let layoutAttributes = layout.layoutAttributesForElements(in: collectionView.bounds) ?? []
        return layoutAttributes
            .filter { $0 is PagingBorderLayoutAttributes }
            .map { $0.frame }
            .first
    }

    private func createIndicatorFrame() -> CGRect? {
        layout.invalidateLayout()
        collectionView.layoutIfNeeded()

        let layoutAttributes = layout.layoutAttributesForElements(in: collectionView.bounds) ?? []
        return layoutAttributes
            .filter { $0 is PagingIndicatorLayoutAttributes }
            .map { $0.frame }
            .first
    }

    private func createSortedCellFrames() -> [CGRect] {
        layout.invalidateLayout()
        collectionView.layoutIfNeeded()

        let layoutAttributes = layout.layoutAttributesForElements(in: collectionView.bounds) ?? []
        return layoutAttributes
            .filter { $0 is PagingCellLayoutAttributes }
            .sorted { $0.indexPath < $1.indexPath }
            .map { $0.frame }
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

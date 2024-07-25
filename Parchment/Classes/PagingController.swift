import UIKit

protocol PagingControllerSizeDelegate: AnyObject {
    @MainActor
    func width(for: PagingItem, isSelected: Bool) -> CGFloat
}

@MainActor
final class PagingController: NSObject {
    weak var dataSource: PagingMenuDataSource?
    weak var sizeDelegate: PagingControllerSizeDelegate?
    weak var delegate: PagingMenuDelegate?

    weak var collectionView: CollectionView! {
        didSet {
            configureCollectionView()
        }
    }

    weak var collectionViewLayout: CollectionViewLayout! {
        didSet {
            configureCollectionViewLayout()
        }
    }

    var options: PagingOptions {
        didSet {
            optionsChanged(oldValue: oldValue)
        }
    }

    private(set) var state: PagingState {
        didSet {
            collectionViewLayout.state = state
        }
    }

    private(set) var visibleItems: PagingItems {
        didSet {
            collectionViewLayout.visibleItems = visibleItems
        }
    }

    private(set) var sizeCache: PagingSizeCache {
        didSet {
            collectionViewLayout.sizeCache = sizeCache
        }
    }

    private var swipeGestureRecognizerLeft: UISwipeGestureRecognizer?
    private var swipeGestureRecognizerRight: UISwipeGestureRecognizer?

    init(options: PagingOptions) {
        self.options = options
        sizeCache = PagingSizeCache(options: options)
        visibleItems = PagingItems(items: [])
        state = .empty
    }

    // MARK: Public

    func select(indexPath: IndexPath, animated: Bool) {
        let pagingItem = visibleItems.pagingItem(for: indexPath)
        select(pagingItem: pagingItem, animated: animated)
    }

    func select(pagingItem: PagingItem, animated: Bool) {
        if collectionView.superview == nil || collectionView.window == nil {
            state = .selected(pagingItem: pagingItem)
            return
        }

        switch state {
        case .empty:
            state = .selected(pagingItem: pagingItem)

            reloadItems(around: pagingItem)

            delegate?.selectContent(
                pagingItem: pagingItem,
                direction: .none,
                animated: false
            )

            collectionView.selectItem(
                at: visibleItems.indexPath(for: pagingItem),
                animated: false,
                scrollPosition: options.scrollPosition
            )

        case .selected:
            if let currentPagingItem = state.currentPagingItem {
                if pagingItem.isEqual(to: currentPagingItem) == false {
                    if animated {
                        appendItemsIfNeeded(upcomingPagingItem: pagingItem)

                        let transition = calculateTransition(
                            from: currentPagingItem,
                            to: pagingItem
                        )

                        state = .scrolling(
                            pagingItem: currentPagingItem,
                            upcomingPagingItem: pagingItem,
                            progress: 0,
                            initialContentOffset: transition.contentOffset,
                            distance: transition.distance
                        )

                        let direction = visibleItems.direction(
                            from: currentPagingItem,
                            to: pagingItem
                        )

                        delegate?.selectContent(
                            pagingItem: pagingItem,
                            direction: direction,
                            animated: animated
                        )
                    } else {
                        state = .selected(pagingItem: pagingItem)

                        reloadItems(around: pagingItem)

                        delegate?.selectContent(
                            pagingItem: pagingItem,
                            direction: .none,
                            animated: false
                        )

                        collectionView.selectItem(
                            at: visibleItems.indexPath(for: pagingItem),
                            animated: false,
                            scrollPosition: options.scrollPosition
                        )
                    }
                }
            }

        default:
            break
        }
    }

    func contentScrolled(progress: CGFloat) {
        switch state {
        case let .selected(pagingItem):
            var upcomingItem: PagingItem?

            if progress > 0 {
                upcomingItem = dataSource?.pagingItemAfter(pagingItem: pagingItem)
            } else if progress < 0 {
                upcomingItem = dataSource?.pagingItemBefore(pagingItem: pagingItem)
            } else {
                return
            }

            appendItemsIfNeeded(upcomingPagingItem: upcomingItem)
            let transition = calculateTransition(from: pagingItem, to: upcomingItem)
            updateScrollingState(
                pagingItem: pagingItem,
                upcomingPagingItem: upcomingItem,
                initialContentOffset: transition.contentOffset,
                distance: transition.distance,
                progress: progress
            )

        case let .scrolling(pagingItem, upcomingPagingItem, oldProgress, initialContentOffset, distance):
            if oldProgress < 0, progress > 0 {
                state = .selected(pagingItem: pagingItem)
            } else if oldProgress > 0, progress < 0 {
                state = .selected(pagingItem: pagingItem)
            } else if progress == 0 {
                state = .selected(pagingItem: pagingItem)
            } else {
                updateScrollingState(
                    pagingItem: pagingItem,
                    upcomingPagingItem: upcomingPagingItem,
                    initialContentOffset: initialContentOffset,
                    distance: distance,
                    progress: progress
                )
            }

        default:
            break
        }
    }

    func contentFinishedScrolling() {
        guard case let .scrolling(pagingItem, upcomingPagingItem, _, _, _) = state else { return }

        // If a transition finishes scrolling, but the upcoming paging
        // item is nil it means that the user scrolled away from one of
        // the items at the very edge. In this case, we don't want to
        // fire a .finishScrolling event as this will select the current
        // paging item, causing it to jump to that item even if it's
        // scrolled out of view. We still need to fire an event that
        // will reset the state to .selected.
        if let upcomingPagingItem = upcomingPagingItem {
            state = .selected(pagingItem: upcomingPagingItem)

            // We only want to select the current paging item
            // if the user is not scrolling the collection view.
            if collectionView.isDragging == false {
                reloadItems(around: upcomingPagingItem)
                collectionView.selectItem(
                    at: visibleItems.indexPath(for: upcomingPagingItem),
                    animated: options.menuTransition == .animateAfter,
                    scrollPosition: options.scrollPosition
                )
            }
        } else {
            state = .selected(pagingItem: pagingItem)
        }
    }

    func transitionSize() {
        switch state {
        case let .scrolling(pagingItem, _, _, _, _):
            sizeCache.clear()
            state = .selected(pagingItem: pagingItem)
            reloadItems(around: pagingItem)
            collectionView.selectItem(
                at: visibleItems.indexPath(for: pagingItem),
                animated: options.menuTransition == .animateAfter,
                scrollPosition: options.scrollPosition
            )

        default:
            if let pagingItem = state.currentPagingItem {
                sizeCache.clear()
                reloadItems(around: pagingItem)

                collectionView.selectItem(
                    at: visibleItems.indexPath(for: pagingItem),
                    animated: options.menuTransition == .animateAfter,
                    scrollPosition: options.scrollPosition
                )
            }
        }
    }

    func removeAll() {
        state = .empty
        sizeCache.clear()
        visibleItems = PagingItems(items: [])
        collectionView.reloadData()
        delegate?.removeContent()
    }

    func viewAppeared() {
        switch state {
        case let .selected(pagingItem), let .scrolling(_, pagingItem?, _, _, _):
            state = .selected(pagingItem: pagingItem)
            reloadItems(around: pagingItem)

            delegate?.selectContent(
                pagingItem: pagingItem,
                direction: .none,
                animated: false
            )

            collectionView.selectItem(
                at: visibleItems.indexPath(for: pagingItem),
                animated: false,
                scrollPosition: options.scrollPosition
            )

        default:
            break
        }
    }

    func reloadData(around pagingItem: PagingItem) {
        reloadMenu(around: pagingItem)

        delegate?.removeContent()
        delegate?.selectContent(
            pagingItem: pagingItem,
            direction: .none,
            animated: false
        )

        // Reloading the data triggers the didFinishScrollingFrom delegate
        // to be called which in turn means the wrong item will be selected.
        // For now, we just fix this by selecting the correct item manually.
        state = .selected(pagingItem: pagingItem)
        collectionViewLayout.invalidateLayout()
    }

    func reloadMenu(around pagingItem: PagingItem) {
        sizeCache.clear()

        let toItems = generateItems(around: pagingItem)

        visibleItems = PagingItems(
            items: toItems,
            hasItemsBefore: hasItemBefore(pagingItem: toItems.first),
            hasItemsAfter: hasItemAfter(pagingItem: toItems.last)
        )

        state = .selected(pagingItem: pagingItem)
        collectionViewLayout.invalidateLayout()
        collectionView.reloadData()
        configureSizeCache(for: pagingItem)
    }

    func menuScrolled() {
        // If we don't have any visible items there is no point in
        // checking if we're near an edge. This seems to be empty quite
        // often when scrolling very fast.
        if collectionView.indexPathsForVisibleItems.isEmpty == true {
            return
        }

        let contentInsets = collectionViewLayout.contentInsets

        if collectionView.near(edge: .left, clearance: contentInsets.left) {
            if let firstPagingItem = visibleItems.items.first {
                if visibleItems.hasItemsBefore {
                    reloadItems(around: firstPagingItem)
                }
            }
        } else if collectionView.near(edge: .right, clearance: contentInsets.right) {
            if let lastPagingItem = visibleItems.items.last {
                if visibleItems.hasItemsAfter {
                    reloadItems(around: lastPagingItem)
                }
            }
        }

        if collectionView.isDragging, case .wheel = options.menuInteraction {
            let center = CGPoint(x: collectionView.bounds.midX, y: collectionView.bounds.midY)
            if let indexPath = collectionView.indexPathForItem(at: center),
               let currentPagingItem = state.currentPagingItem {
                let currentIndexPath = visibleItems.indexPath(for: currentPagingItem)
                if indexPath != currentIndexPath {
                    let pagingItem = visibleItems.pagingItem(for: indexPath)
                    state = .selected(pagingItem: pagingItem)
                    collectionViewLayout.invalidateLayout()
                    delegate?.selectContent(
                        pagingItem: pagingItem,
                        direction: .none,
                        animated: false
                    )
                }
            }
        }
    }

    // MARK: Private

    private func optionsChanged(oldValue: PagingOptions) {
        if options.menuInteraction != oldValue.menuInteraction {
            configureMenuInteraction()
        }

        sizeCache.options = options
        collectionViewLayout.invalidateLayout()
    }

    private func configureCollectionViewLayout() {
        collectionViewLayout.state = state
        collectionViewLayout.visibleItems = visibleItems
        collectionViewLayout.sizeCache = sizeCache
    }

    private func configureCollectionView() {
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.dataSource = self
        collectionView.contentInsetAdjustmentBehavior = .never

        configureMenuInteraction()
    }

    private func configureMenuInteraction() {
        if let swipeGestureRecognizerLeft = swipeGestureRecognizerLeft {
            collectionView.removeGestureRecognizer(swipeGestureRecognizerLeft)
        }

        if let swipeGestureRecognizerRight = swipeGestureRecognizerRight {
            collectionView.removeGestureRecognizer(swipeGestureRecognizerRight)
        }

        collectionView.isScrollEnabled = false
        collectionView.alwaysBounceHorizontal = false

        switch options.menuInteraction {
        case .scrolling, .wheel:
            collectionView.isScrollEnabled = true
            collectionView.alwaysBounceHorizontal = true
        case .swipe:
            setupGestureRecognizers()
        case .none:
            break
        }
    }

    private func setupGestureRecognizers() {
        let swipeGestureRecognizerLeft = UISwipeGestureRecognizer(
            target: self,
            action: #selector(handleSwipeGestureRecognizer)
        )
        let swipeGestureRecognizerRight = UISwipeGestureRecognizer(
            target: self,
            action: #selector(handleSwipeGestureRecognizer)
        )

        swipeGestureRecognizerLeft.direction = .left
        swipeGestureRecognizerRight.direction = .right

        collectionView.addGestureRecognizer(swipeGestureRecognizerLeft)
        collectionView.addGestureRecognizer(swipeGestureRecognizerRight)

        self.swipeGestureRecognizerLeft = swipeGestureRecognizerLeft
        self.swipeGestureRecognizerRight = swipeGestureRecognizerRight
    }

    @objc private dynamic func handleSwipeGestureRecognizer(_ recognizer: UISwipeGestureRecognizer) {
        guard let currentPagingItem = state.currentPagingItem else { return }

        var upcomingPagingItem: PagingItem?

        if recognizer.direction.contains(.left) {
            upcomingPagingItem = dataSource?.pagingItemAfter(pagingItem: currentPagingItem)
        } else if recognizer.direction.contains(.right) {
            upcomingPagingItem = dataSource?.pagingItemBefore(pagingItem: currentPagingItem)
        }

        if let pagingItem = upcomingPagingItem {
            select(pagingItem: pagingItem, animated: true)
        }
    }

    private func updateScrollingState(
        pagingItem: PagingItem,
        upcomingPagingItem: PagingItem?,
        initialContentOffset: CGPoint,
        distance: CGFloat,
        progress: CGFloat
    ) {
        state = .scrolling(
            pagingItem: pagingItem,
            upcomingPagingItem: upcomingPagingItem,
            progress: progress,
            initialContentOffset: initialContentOffset,
            distance: distance
        )

        if options.menuTransition == .scrollAlongside {
            let invalidationContext = PagingInvalidationContext()

            // We don't want to update the content offset if there is no
            // upcoming item to scroll to. We still need to invalidate the
            // layout in order to update the layout attributes for the
            // decoration views. We need to use setContentOffset with no
            // animation in order to stop any ongoing scroll.
            if upcomingPagingItem != nil {
                if collectionView.contentSize.width >= collectionView.bounds.width, state.progress != 0 {
                    let contentOffset = CGPoint(
                        x: initialContentOffset.x + (distance * abs(progress)),
                        y: initialContentOffset.y
                    )
                    collectionView.setContentOffset(contentOffset, animated: false)
                }

                if sizeCache.implementsSizeDelegate {
                    invalidationContext.invalidateSizes = true
                }
            }

            collectionViewLayout.invalidateLayout(with: invalidationContext)
        }
    }

    private func calculateTransition(
        from pagingItem: PagingItem,
        to upcomingPagingItem: PagingItem?
    ) -> PagingTransition {
        guard let upcomingPagingItem = upcomingPagingItem else {
            return PagingTransition(contentOffset: .zero, distance: 0)
        }

        let distance = PagingDistance(
            view: collectionView,
            currentPagingItem: pagingItem,
            upcomingPagingItem: upcomingPagingItem,
            visibleItems: visibleItems,
            sizeCache: sizeCache,
            selectedScrollPosition: options.selectedScrollPosition,
            layoutAttributes: collectionViewLayout.layoutAttributes,
            navigationOrientation: options.contentNavigationOrientation
        )

        return PagingTransition(
            contentOffset: collectionView.contentOffset,
            distance: distance?.calculate() ?? 0
        )
    }

    /// If the upcoming item is outside the currently visible
    /// items we need to append the items that are around the
    /// upcoming item so we can animate the transition.
    private func appendItemsIfNeeded(upcomingPagingItem: PagingItem?) {
        if let upcomingPagingItem = upcomingPagingItem {
            if visibleItems.contains(upcomingPagingItem) == false {
                reloadItems(around: upcomingPagingItem, keepExisting: true)
            }
        }
    }

    private func reloadItems(around pagingItem: PagingItem, keepExisting: Bool = false) {
        var toItems = generateItems(around: pagingItem)

        if keepExisting {
            toItems = visibleItems.union(toItems)
        }

        let oldLayoutAttributes = collectionViewLayout.layoutAttributes
        let oldContentOffset = collectionView.contentOffset
        let oldVisibleItems = visibleItems

        configureSizeCache(for: pagingItem)

        visibleItems = PagingItems(
            items: toItems,
            hasItemsBefore: hasItemBefore(pagingItem: toItems.first),
            hasItemsAfter: hasItemAfter(pagingItem: toItems.last)
        )

        collectionView.reloadData()
        collectionViewLayout.prepare()

        // After reloading the data the content offset is going to be
        // reset. We need to diff which items where added/removed and
        // update the content offset so it looks it is the same as before
        // reloading. This gives the perception of a smooth scroll.
        let newLayoutAttributes = collectionViewLayout.layoutAttributes

        var offset: CGFloat = 0
        let diff = PagingDiff(from: oldVisibleItems, to: visibleItems)

        for indexPath in diff.removed() {
            offset += oldLayoutAttributes[indexPath]?.bounds.width ?? 0
            offset += options.menuItemSpacing
        }

        for indexPath in diff.added() {
            offset -= newLayoutAttributes[indexPath]?.bounds.width ?? 0
            offset -= options.menuItemSpacing
        }

        collectionView.contentOffset = CGPoint(
            x: oldContentOffset.x - offset,
            y: oldContentOffset.y
        )

        // We need to perform layout here, if not the collection view
        // seems to get in a weird state.
        collectionView.layoutIfNeeded()

        // The content offset and distance between items can change while a
        // transition is in progress meaning the current transition will be
        // wrong. For instance, when hitting the edge of the collection view
        // while transitioning we need to reload all the paging items and
        // update the transition data.
        if case let .scrolling(pagingItem, upcomingPagingItem, progress, _, distance) = state {
            let transition = calculateTransition(
                from: pagingItem,
                to: upcomingPagingItem
            )

            let contentOffset = collectionView.contentOffset
            let newContentOffset = CGPoint(
                x: contentOffset.x - (distance - transition.distance),
                y: contentOffset.y
            )

            state = .scrolling(
                pagingItem: pagingItem,
                upcomingPagingItem: upcomingPagingItem,
                progress: progress,
                initialContentOffset: newContentOffset,
                distance: distance
            )
        }
    }

    private func generateItems(around pagingItem: PagingItem) -> [PagingItem] {
        var items: [PagingItem] = [pagingItem]
        var previousItem: PagingItem = pagingItem
        var nextItem: PagingItem = pagingItem
        let menuWidth = collectionView.bounds.width

        // Add as many items as we can before the current paging item to
        // fill up the same width as the bounds.
        var widthBefore: CGFloat = menuWidth
        while widthBefore > 0 {
            if let item = dataSource?.pagingItemBefore(pagingItem: previousItem) {
                widthBefore -= itemWidth(for: item)
                widthBefore -= options.menuItemSpacing
                previousItem = item
                items.insert(item, at: 0)
            } else {
                break
            }
        }

        // When filling up the items after the current item we need to
        // include any remaining space left before the current item.
        var widthAfter: CGFloat = menuWidth + widthBefore
        while widthAfter > 0 {
            if let item = dataSource?.pagingItemAfter(pagingItem: nextItem) {
                widthAfter -= itemWidth(for: item)
                widthAfter -= options.menuItemSpacing
                nextItem = item
                items.append(item)
            } else {
                break
            }
        }

        // Make sure we add even more items if there is any remaining
        // space available after filling items items after the current.
        var remainingWidth = widthAfter
        while remainingWidth > 0 {
            if let item = dataSource?.pagingItemBefore(pagingItem: previousItem) {
                remainingWidth -= itemWidth(for: item)
                remainingWidth -= options.menuItemSpacing
                previousItem = item
                items.insert(item, at: 0)
            } else {
                break
            }
        }

        return items
    }

    private func itemWidth(for pagingItem: PagingItem) -> CGFloat {
        guard let currentPagingItem = state.currentPagingItem else { return options.estimatedItemWidth }

        if currentPagingItem.isEqual(to: pagingItem) {
            return sizeCache.itemWidthSelected(for: pagingItem)
        } else {
            return sizeCache.itemSize(for: pagingItem)
        }
    }

    private func configureSizeCache(for pagingItem: PagingItem) {
        switch options.menuItemSize {
        case .selfSizing:
            if #available(iOS 14.0, *), pagingItem is PageItem {
                sizeCache.implementsSizeDelegate = true
                sizeCache.sizeForPagingItem = { [weak self] item, selected in
                    guard let self else { return nil }
                    let item = item as! PageItem
                    let state = PageState(progress: selected ? 1 : 0, isSelected: selected)
                    let configuration = item.page.header(self.options, state)
                    let contentView = configuration.makeContentView()
                    let size = contentView.sizeThatFits(UIView.layoutFittingCompressedSize)
                    return size.width
                }
            }

        case .fixed, .sizeToFit:
            if sizeDelegate != nil  {
                sizeCache.implementsSizeDelegate = true
                sizeCache.sizeForPagingItem = { [weak self] item, selected in
                    return self?.sizeDelegate?.width(for: item, isSelected: selected)
                }
            }
        }
    }

    private func hasItemBefore(pagingItem: PagingItem?) -> Bool {
        guard let item = pagingItem else { return false }
        return dataSource?.pagingItemBefore(pagingItem: item) != nil
    }

    private func hasItemAfter(pagingItem: PagingItem?) -> Bool {
        guard let item = pagingItem else { return false }
        return dataSource?.pagingItemAfter(pagingItem: item) != nil
    }
}

extension PagingController: UICollectionViewDataSource {
    // MARK: UICollectionViewDataSource

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let pagingItem = visibleItems.items[indexPath.item]
        var reuseIdentifier: String

        if #available(iOS 14.0, *),
           let item = pagingItem as? PageItem {
            reuseIdentifier = item.page.reuseIdentifier
        } else {
            reuseIdentifier = String(describing: type(of: pagingItem))
        }

        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: reuseIdentifier,
            for: indexPath
        ) as! PagingCell
        var selected: Bool = false
        if let currentPagingItem = state.currentPagingItem {
            selected = currentPagingItem.isEqual(to: pagingItem)
        }
        cell.setPagingItem(pagingItem, selected: selected, options: options)
        return cell
    }

    func collectionView(_: UICollectionView, numberOfItemsInSection _: Int) -> Int {
        return visibleItems.items.count
    }
}

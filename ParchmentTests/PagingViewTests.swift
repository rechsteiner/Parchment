import Testing
@testable import Parchment

@MainActor
final class PagingViewTests {
    private let pagingView: PagingView
    private let collectionView: UICollectionView

    init() {
        let options = PagingOptions()
        let pageView = UIView(frame: .zero)

        collectionView = UICollectionView(
            frame: .zero,
            collectionViewLayout: UICollectionViewLayout()
        )

        pagingView = PagingView(
            options: options,
            collectionView: collectionView,
            pageView: pageView
        )
    }

    @Test func menuBackgroundColor() {
        pagingView.configure()

        var options = PagingOptions()
        options.menuBackgroundColor = .green
        pagingView.options = options

        #expect(collectionView.backgroundColor == .green)
    }
}

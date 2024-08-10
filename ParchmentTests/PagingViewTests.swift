@testable import Parchment
import XCTest

@MainActor
final class PagingViewTests: XCTestCase {
    var pagingView: PagingView!
    var collectionView: UICollectionView!

    override func setUp() {
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

    func testMenuBackgroundColor() {
        pagingView.configure()

        var options = PagingOptions()
        options.menuBackgroundColor = .green
        pagingView.options = options

        XCTAssertEqual(collectionView.backgroundColor, .green)
    }
}

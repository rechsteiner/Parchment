import Foundation
@testable import Parchment
import XCTest

@MainActor
final class PagingIndicatorLayoutAttributesTests: XCTestCase {
    let layoutAttributes = PagingIndicatorLayoutAttributes()
    var options = PagingOptions()

    override func setUp() {
        options.font = UIFont.systemFont(ofSize: 15)
        options.selectedFont = UIFont.boldSystemFont(ofSize: 15)
        options.textColor = .blue
        options.selectedTextColor = .red
        options.indicatorColor = .green
        options.indicatorOptions = .visible(
            height: 20,
            zIndex: Int.max,
            spacing: UIEdgeInsets(),
            insets: UIEdgeInsets()
        )
    }

    func testConfigure() {
        layoutAttributes.configure(options)

        XCTAssertEqual(layoutAttributes.backgroundColor, UIColor.green)
        XCTAssertEqual(layoutAttributes.frame.height, 20)
        XCTAssertEqual(layoutAttributes.frame.origin.y, 20)
        XCTAssertEqual(layoutAttributes.zIndex, Int.max)
    }

    func testTweening() {
        layoutAttributes.configure(options)

        let from = PagingIndicatorMetric(
            frame: CGRect(x: 0, y: 0, width: 200, height: 0),
            insets: .left(50),
            spacing: UIEdgeInsets()
        )

        let to = PagingIndicatorMetric(
            frame: CGRect(x: 200, y: 0, width: 100, height: 0),
            insets: .right(50),
            spacing: UIEdgeInsets()
        )

        layoutAttributes.update(from: from, to: to, progress: 0)
        XCTAssertEqual(layoutAttributes.frame, CGRect(x: 50, y: 20, width: 150, height: 20))

        layoutAttributes.update(from: from, to: to, progress: 1)
        XCTAssertEqual(layoutAttributes.frame, CGRect(x: 200, y: 20, width: 50, height: 20))

        layoutAttributes.update(from: from, to: to, progress: 0.5)
        XCTAssertEqual(layoutAttributes.frame, CGRect(x: 125, y: 20, width: 100, height: 20))
    }
}

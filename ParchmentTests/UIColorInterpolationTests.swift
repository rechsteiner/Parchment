import CoreGraphics
import Testing
@testable import Parchment

final class UIColorInterpolationTests {
    // Colors initialized with UIColor(patternImage:) have only 1
    // color component. This test ensures we don't crash.
    @Test func imageFromPatternImageDefaultToBlack() {
        let from = UIColor.red
        let bundle = Bundle(for: Self.self)
        let image = UIImage(named: "Green", in: bundle, compatibleWith: nil)!
        let to = UIColor(patternImage: image)
        let result = UIColor.interpolate(from: from, to: to, with: 1)

        #expect(result == UIColor(red: 0, green: 0, blue: 0, alpha: 1))
    }
}

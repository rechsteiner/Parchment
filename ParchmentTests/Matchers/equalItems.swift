import Foundation
import Nimble
@testable import Parchment

func equalItems(_ items: [PagingItem]) -> Predicate<[PagingItem]> {
  return Predicate.define("to equal: \(items)") { expression, message in
    if let actual = try expression.evaluate() {
      return PredicateResult(
        bool: actual.elementsEqual(items, by: { $0.isEqual(to: $1) }),
        message: message
      )
    }
    return PredicateResult(bool: false, message: message)
  }
}

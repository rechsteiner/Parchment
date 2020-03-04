import Foundation

enum Action: Equatable {
  case collectionView(MockCollectionView.Action)
  case collectionViewLayout(MockCollectionViewLayout.Action)
  case delegate(MockPagingControllerDelegate.Action)
}

struct MockCall {
  let datetime: Date
  let action: Action
}

extension MockCall: Equatable {
  static func == (lhs: MockCall, rhs: MockCall) -> Bool {
    return lhs.datetime == rhs.datetime && lhs.action == rhs.action
  }
}

extension MockCall: Comparable {
  static func < (lhs: MockCall, rhs: MockCall) -> Bool {
    return lhs.datetime < rhs.datetime
  }
}

protocol Mock {
  var calls: [MockCall] { get }
}

func actions(_ calls: [MockCall]) -> [Action] {
  return calls.map { $0.action }
}

func combinedActions(_ a: [MockCall], _ b: [MockCall]) -> [Action] {
  return actions(Array(a + b).sorted())
}

func combinedActions(_ a: [MockCall], _ b: [MockCall], _ c: [MockCall]) -> [Action] {
  return actions(Array(a + b + c).sorted())
}

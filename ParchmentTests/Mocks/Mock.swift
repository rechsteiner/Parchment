import Foundation

enum Action: Equatable {
    case collectionView(MockCollectionView.Action)
    case collectionViewLayout(MockCollectionViewLayout.Action)
    case delegate(MockPagingControllerDelegate.Action)
}

struct MockCall: Equatable {
    static var callCount: Int = 0

    let index: Int
    let action: Action

    init(action: Action) {
        Self.callCount += 1
        self.index = Self.callCount
        self.action = action
    }
}

extension MockCall: Comparable {
    static func < (lhs: MockCall, rhs: MockCall) -> Bool {
        return lhs.index < rhs.index
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

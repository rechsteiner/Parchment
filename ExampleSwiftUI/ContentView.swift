import Parchment
import SwiftUI
import UIKit

struct ContentView: View {
    let items = [
        PagingIndexItem(index: 0, title: "View 0"),
        PagingIndexItem(index: 1, title: "View 1"),
        PagingIndexItem(index: 2, title: "View 2"),
        PagingIndexItem(index: 3, title: "View 3"),
        PagingIndexItem(index: 4, title: "View 4"),
    ]
    @State
    var scrollToPosition: PageViewScrollPosition?

    var body: some View {
        VStack {
            Button(action: {
                scrollToPosition = PageViewScrollPosition(index: (0 ... 3).randomElement()!)
            }) {
                Text("Random Index")
                    .font(.largeTitle)
            }
            PageView(scrollToPosition: $scrollToPosition, items: items) { _ in
                List(0 ..< 100) { index in
                    Text(String(index))
                        .font(.largeTitle)
                        .foregroundColor(.gray)
                }
            }
            .willScroll { pagingItem in
                print("willScroll: \(pagingItem)")
            }
            .didScroll { pagingItem in
                print("didScroll: \(pagingItem)")
            }
            .didSelect { pagingItem in
                print("didSelect: \(pagingItem)")
            }
        }
    }
}

extension ContentView: Equatable {
    static func == (lhs: ContentView, rhs: ContentView) -> Bool {
        lhs.items == rhs.items
    }
}

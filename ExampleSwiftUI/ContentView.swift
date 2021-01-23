import Parchment
import SwiftUI
import UIKit

struct ContentView: View {
    @State
    var scrollToPosition: PageView.ScrollPosition?

    var body: some View {
        VStack {
            Button(action: {
                scrollToPosition = PageView.ScrollPosition(index: (0...3).randomElement()!)
            }) {
                Text("Random Index")
                    .font(.largeTitle)
            }
            PageView(scrollToPosition: $scrollToPosition) {
                PageView.TabItem(item: PagingIndexItem(index: 0, title: "View 0")) {
                    List(0 ..< 100) { index in
                        Text(String(index))
                            .font(.largeTitle)
                            .foregroundColor(.gray)
                    }
                }
                PageView.TabItem(item: PagingIndexItem(index: 1, title: "View 1")) {
                    List(0 ..< 100) { index in
                        Text(String(index))
                            .font(.largeTitle)
                            .foregroundColor(.gray)
                    }
                }
                PageView.TabItem(item: PagingIndexItem(index: 2, title: "View 2")) {
                    List(0 ..< 100) { index in
                        Text(String(index))
                            .font(.largeTitle)
                            .foregroundColor(.gray)
                    }
                }
                PageView.TabItem(item: PagingIndexItem(index: 3, title: "View 3")) {
                    List(0 ..< 100) { index in
                        Text(String(index))
                            .font(.largeTitle)
                            .foregroundColor(.gray)
                    }
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

import SwiftUI
import UIKit

/// Check if both SwiftUI and Combine is available. Without this
/// xcodebuild fails, saying it can't find the SwiftUI types used
/// inside PageView, even though it's wrapped with an @available
/// check. Found a possible fix here: https://stackoverflow.com/questions/58233454/how-to-use-swiftui-in-framework
/// This might be related to the issue discussed in this thread:
/// https://forums.swift.org/t/weak-linking-of-frameworks-with-greater-deployment-targets/26017/24
#if canImport(SwiftUI) && canImport(Combine)

    /// `PageView` provides a SwiftUI wrapper around `PagingViewController`.
    /// It can be used with any fixed array of `PagingItem`s. Use the
    /// `PagingOptions` struct to customize the properties.
    @available(iOS 13.0, *)
    public struct PageView<Item: PagingItem, Page: View>: View where Item: Hashable {
        public typealias WillScrollCallback = ((PagingItem) -> Void)
        public typealias DidScrollCallback = ((PagingItem) -> Void)
        public typealias DidSelectCallback = ((PagingItem) -> Void)
        private let options: PagingOptions
        private var items = [Item]()
        let content: (Item) -> Page
        @Binding
        private var scrollToPosition: PageViewScrollPosition?
        var willScrollCallback: WillScrollCallback?
        var didScrollCallback: DidScrollCallback?
        var didSelectCallback: DidSelectCallback?

        /// Initialize a new `PageView`.
        ///
        /// - Parameters:
        ///   - options: The configuration parameters we want to customize.
        ///   - items: The array of `PagingItem`s to display in the menu.
        ///   - content: A callback that returns the `View` for each item.
        public init(options: PagingOptions = PagingOptions(),
                    scrollToPosition: Binding<PageViewScrollPosition?>? = nil,
                    items: [Item],
                    content: @escaping (Item) -> Page)
        {
            self._scrollToPosition = scrollToPosition ?? .constant(nil)
            self.options = options
            self.items = items
            self.content = content
        }

        public var body: some View {
            PagingController(items: items,
                             options: options,
                             content: content,
                             scrollToPosition: $scrollToPosition,
                             willScrollCallback: willScrollCallback,
                             didScrollCallback: didScrollCallback,
                             didSelectCallback: didSelectCallback)
        }

        struct PagingController: UIViewControllerRepresentable {
            let items: [Item]
            let options: PagingOptions
            let content: (Item) -> Page
            var viewControllers = [Item: UIHostingController<Page>]()
            @Binding
            var scrollToPosition: PageViewScrollPosition?
            var willScrollCallback: WillScrollCallback?
            var didScrollCallback: DidScrollCallback?
            var didSelectCallback: DidSelectCallback?

            func makeCoordinator() -> Coordinator {
                Coordinator(self)
            }

            func makeUIViewController(context: UIViewControllerRepresentableContext<PagingController>) -> PagingViewController {
                let pagingViewController = PagingViewController(options: options)
                pagingViewController.dataSource = context.coordinator
                pagingViewController.delegate = context.coordinator
                return pagingViewController
            }

            func updateUIViewController(_ pagingViewController: PagingViewController,
                                        context: UIViewControllerRepresentableContext<PagingController>)
            {
                context.coordinator.parent = self

                if let position = $scrollToPosition.wrappedValue {
                    pagingViewController.select(index: position.index, animated: position.animated)
                } else {
                    pagingViewController.reloadData()
                }
            }
        }

        class Coordinator: NSObject, PagingViewControllerDataSource, PagingViewControllerDelegate {
            var parent: PagingController

            init(_ pagingController: PagingController) {
                self.parent = pagingController
            }

            func numberOfViewControllers(in pagingViewController: PagingViewController) -> Int {
                parent.items.count
            }

            func pagingViewController(_: PagingViewController, viewControllerAt index: Int) -> UIViewController {
                guard let viewController = parent.viewControllers[parent.items[index]] else {
                    let view = parent.content(parent.items[index])
                    let viewController = UIHostingController(rootView: view)
                    parent.viewControllers[parent.items[index]] = viewController
                    return viewController
                }
                return viewController
            }

            func pagingViewController(_: PagingViewController, pagingItemAt index: Int) -> PagingItem {
                parent.items[index]
            }

            func pagingViewController(_ pagingViewController: PagingViewController,
                                      didScrollToItem pagingItem: PagingItem,
                                      startingViewController: UIViewController?,
                                      destinationViewController: UIViewController,
                                      transitionSuccessful: Bool)
            {
                parent.didScrollCallback?(pagingItem)

                DispatchQueue.main.async {
                    self.parent.scrollToPosition = nil
                }
            }

            func pagingViewController(_ pagingViewController: PagingViewController,
                                      willScrollToItem pagingItem: PagingItem,
                                      startingViewController: UIViewController,
                                      destinationViewController: UIViewController)
            {
                parent.willScrollCallback?(pagingItem)
            }

            func pagingViewController(_ pagingViewController: PagingViewController, didSelectItem pagingItem: PagingItem) {
                parent.didSelectCallback?(pagingItem)
            }
        }
    }

    @available(iOS 13.0, *)
    public struct PageViewScrollPosition: Equatable {
        public var index: Int
        public var animated: Bool

        public init(index: Int, animated: Bool = true) {
            self.index = index
            self.animated = animated
        }
    }

    @available(iOS 13.0, *)
    public extension PageView {
        func didScroll(_ didScrollCallback: @escaping DidScrollCallback) -> Self {
            var this = self
            this.didScrollCallback = didScrollCallback
            return this
        }

        func willScroll(_ willScrollCallback: @escaping WillScrollCallback) -> Self {
            var this = self
            this.willScrollCallback = willScrollCallback
            return this
        }

        func didSelect(_ didSelectCallback: @escaping DidSelectCallback) -> Self {
            var this = self
            this.didSelectCallback = didSelectCallback
            return this
        }
    }

#endif

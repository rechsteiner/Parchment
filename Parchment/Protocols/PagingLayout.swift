import Foundation

/// Used to be able to initialize a layout based on the type defined
/// in the menuLayoutClass property.
protocol PagingLayout {
  init()
}

func createLayout<T>(layout: T.Type) -> T where T: PagingLayout {
  return layout.init()
}

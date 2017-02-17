import UIKit

public enum PagingMenuItemSize {
  case fixed(width: CGFloat, height: CGFloat)
  case sizeToFit(minWidth: CGFloat, height: CGFloat)
}

public extension PagingMenuItemSize {
  
  var width: CGFloat {
    switch self {
    case let .fixed(width, _): return width
    case let .sizeToFit(minWidth, _): return minWidth
    }
  }
  
  var height: CGFloat {
    switch self {
    case let .fixed(_, height): return height
    case let .sizeToFit(_, height): return height
    }
  }
  
}

public enum PagingIndicatorOptions {
  case hidden
  case visible(
    height: CGFloat,
    zIndex: Int,
    spacing: UIEdgeInsets,
    insets: UIEdgeInsets)
}

public enum PagingBorderOptions {
  case hidden
  case visible(
    height: CGFloat,
    zIndex: Int,
    insets: UIEdgeInsets)
}

public enum PagingSelectedScrollPosition {
  case left
  case right
  case preferCentered
}

public enum PagingMenuHorizontalAlignment {
  case `default`
  case center
}

public enum PagingMenuTransition {
  case scrollAlongside
  case animateAfter
}

public protocol PagingTheme {
  var font: UIFont { get }
  var textColor: UIColor { get }
  var selectedTextColor: UIColor { get }
  var backgroundColor: UIColor { get }
  var headerBackgroundColor: UIColor { get }
  var borderColor: UIColor { get }
  var indicatorColor: UIColor { get }
}

public protocol PagingOptions {
  var menuItemSize: PagingMenuItemSize { get }
  var menuItemClass: PagingCell.Type { get }
  var menuItemSpacing: CGFloat { get }
  var menuInsets: UIEdgeInsets { get }
  var menuHorizontalAlignment: PagingMenuHorizontalAlignment { get }
  var menuTransition: PagingMenuTransition { get }
  var selectedScrollPosition: PagingSelectedScrollPosition { get }
  var indicatorOptions: PagingIndicatorOptions { get }
  var borderOptions: PagingBorderOptions { get }
  var theme: PagingTheme { get }
}

extension PagingOptions {
  
  var scrollPosition: UICollectionViewScrollPosition {
    switch selectedScrollPosition {
    case .left:
      return .left
    case .right:
      return .right
    case .preferCentered:
      return .centeredHorizontally
    }
  }
  
  var menuHeight: CGFloat {
    return menuItemSize.height + menuInsets.top + menuInsets.bottom
  }
  
}

public extension PagingTheme {
  
  var font: UIFont {
    return UIFont.systemFont(ofSize: 15, weight: UIFontWeightMedium)
  }
  
  var textColor: UIColor {
    return UIColor.black
  }
  
  var selectedTextColor: UIColor {
    return UIColor(red: 3/255, green: 125/255, blue: 233/255, alpha: 1)
  }
  
  var backgroundColor: UIColor {
    return UIColor.white
  }
  
  var headerBackgroundColor: UIColor {
    return UIColor.white
  }
  
  var indicatorColor: UIColor {
    return UIColor(red: 3/255, green: 125/255, blue: 233/255, alpha: 1)
  }
  
  var borderColor: UIColor {
    return UIColor(white: 0.9, alpha: 1)
  }
  
}

public extension PagingOptions {
  
  var menuItemSize: PagingMenuItemSize {
    return .sizeToFit(minWidth: 150, height: 40)
  }
  
  var selectedScrollPosition: PagingSelectedScrollPosition {
    return .preferCentered
  }
  
  var menuTransition: PagingMenuTransition {
    return .scrollAlongside
  }
  
  var theme: PagingTheme {
    return DefaultPagingTheme()
  }
  
  var indicatorOptions: PagingIndicatorOptions {
    return .visible(
      height: 4,
      zIndex: Int.max,
     spacing: UIEdgeInsets.zero,
      insets: UIEdgeInsets(top: 0, left: 8, bottom: 0, right: 8))
  }
  
  var borderOptions: PagingBorderOptions {
    return .visible(
      height: 1,
      zIndex: Int.max - 1,
      insets: UIEdgeInsets(top: 0, left: 8, bottom: 0, right: 8))
  }
  
  var menuItemClass: PagingCell.Type {
    return PagingTitleCell.self
  }
  
  var menuInsets: UIEdgeInsets {
    return UIEdgeInsets()
  }
  
  var menuItemSpacing: CGFloat {
    return 0
  }
  
  var menuHorizontalAlignment: PagingMenuHorizontalAlignment {
    return .default
  }
}

struct DefaultPagingTheme: PagingTheme {}
struct DefaultPagingOptions: PagingOptions {}

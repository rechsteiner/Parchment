import UIKit

public class PagingOptions {
  public var menuItemSize: PagingMenuItemSize
  public var menuItemClass: PagingCell.Type
  public var menuItemSpacing: CGFloat
  public var menuInsets: UIEdgeInsets
  public var menuHorizontalAlignment: PagingMenuHorizontalAlignment
  public var menuTransition: PagingMenuTransition
  public var menuInteraction: PagingMenuInteraction
  public var contentInteraction: PagingContentInteraction
  public var selectedScrollPosition: PagingSelectedScrollPosition
  public var indicatorOptions: PagingIndicatorOptions
  public var indicatorClass: PagingIndicatorView.Type
  public var borderOptions: PagingBorderOptions
  public var borderClass: PagingBorderView.Type
  public var includeSafeAreaInsets: Bool
  public var font: UIFont
  public var selectedFont: UIFont
  public var textColor: UIColor
  public var selectedTextColor: UIColor
  public var backgroundColor: UIColor
  public var selectedBackgroundColor: UIColor
  public var menuBackgroundColor: UIColor
  public var borderColor: UIColor
  public var indicatorColor: UIColor
  
  public var scrollPosition: UICollectionViewScrollPosition {
    switch selectedScrollPosition {
    case .left:
      return .left
    case .right:
      return .right
    case .preferCentered, .center:
      return .centeredHorizontally
    }
  }
  
  public var menuHeight: CGFloat {
    return menuItemSize.height + menuInsets.top + menuInsets.bottom
  }
  
  public var estimatedItemWidth: CGFloat {
    switch menuItemSize {
    case let .fixed(width, _):
      return width
    case let .sizeToFit(minWidth, _):
      return minWidth
    }
  }
  
  public init() {
    selectedScrollPosition = .preferCentered
    menuItemSize = .sizeToFit(minWidth: 150, height: 40)
    menuTransition = .scrollAlongside
    menuInteraction = .scrolling
    menuItemClass = PagingTitleCell.self
    menuInsets = UIEdgeInsets.zero
    menuItemSpacing = 0
    menuHorizontalAlignment = .left
    includeSafeAreaInsets = true
    indicatorClass = PagingIndicatorView.self
    borderClass = PagingBorderView.self
    contentInteraction = .scrolling
    
    indicatorOptions = .visible(
        height: 4,
        zIndex: Int.max,
        spacing: UIEdgeInsets.zero,
        insets: UIEdgeInsets(top: 0, left: 8, bottom: 0, right: 8))
  
    borderOptions = .visible(
        height: 1,
        zIndex: Int.max - 1,
        insets: UIEdgeInsets(top: 0, left: 8, bottom: 0, right: 8))

    font = UIFont.systemFont(ofSize: 15, weight: UIFontWeightMedium)
    selectedFont = UIFont.systemFont(ofSize: 15, weight: UIFontWeightMedium)
    textColor = UIColor.black
    selectedTextColor = UIColor(red: 3/255, green: 125/255, blue: 233/255, alpha: 1)
    backgroundColor = .clear
    selectedBackgroundColor = .clear
    menuBackgroundColor = UIColor.white
    borderColor = UIColor(white: 0.9, alpha: 1)
    indicatorColor = UIColor(red: 3/255, green: 125/255, blue: 233/255, alpha: 1)
  }
}

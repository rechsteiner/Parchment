import UIKit

public struct PagingOptions {
  
  /// The size for each of the menu items. _Default:
  /// .sizeToFit(minWidth: 150, height: 40)_
  public var menuItemSize: PagingMenuItemSize
    
  /// Determine the spacing between the menu items. _Default: 0_
  public var menuItemSpacing: CGFloat
  
  /// Determine the insets at around all the menu items. _Default:
  /// UIEdgeInsets.zero_
  public var menuInsets: UIEdgeInsets
  
  /// Determine whether the menu items should be centered when all the
  /// items can fit within the bounds of the view. _Default: .left_
  public var menuHorizontalAlignment: PagingMenuHorizontalAlignment

  /// Determine the position of the menu relative to the content.
  /// _Default: .top_
  public var menuPosition: PagingMenuPosition
  
  /// Determine the transition behaviour of menu items while scrolling
  /// the content. _Default: .scrollAlongside_
  public var menuTransition: PagingMenuTransition
  
  /// Determine how users can interact with the menu items.
  /// _Default: .scrolling_
  public var menuInteraction: PagingMenuInteraction
  
  /// The class type for collection view layout. Override this if you
  /// want to use your own subclass of the layout. Setting this
  /// property will initialize the new layout type and update the
  /// collection view.
  /// _Default: PagingCollectionViewLayout.self_
  public var menuLayoutClass: PagingCollectionViewLayout.Type
  
  /// Determine how the selected menu item should be aligned when it
  /// is selected. Effectivly the same as the
  /// `UICollectionViewScrollPosition`. _Default: .preferCentered_
  public var selectedScrollPosition: PagingSelectedScrollPosition
  
  /// Add an indicator view to the selected menu item. The indicator
  /// width will be equal to the selected menu items width. Insets
  /// only apply horizontally. _Default: .visible_
  public var indicatorOptions: PagingIndicatorOptions
  
  /// The class type for the indicator view. Override this if you want
  /// your use your own subclass of PagingIndicatorView. _Default:
  /// PagingIndicatorView.self_
  public var indicatorClass: PagingIndicatorView.Type
  
  /// Determine the color of the indicator view.
  public var indicatorColor: UIColor
  
  /// Add a border at the bottom of the menu items. The border will be
  /// as wide as all the menu items. Insets only apply horizontally.
  /// _Default: .visible_
  public var borderOptions: PagingBorderOptions
  
  /// The class type for the border view. Override this if you want
  /// your use your own subclass of PagingBorderView. _Default:
  /// PagingBorderView.self_
  public var borderClass: PagingBorderView.Type
  
  /// Determine the color of the border view.
  public var borderColor: UIColor
  
  /// Updates the content inset for the menu items based on the
  /// .safeAreaInsets property. _Default: true_
  public var includeSafeAreaInsets: Bool
  
  /// The font used for title label on the menu items.
  public var font: UIFont
  
  /// The font used for the currently selected menu item.
  public var selectedFont: UIFont
  
  /// The color of the title label on the menu items.
  public var textColor: UIColor
  
  /// The text color for the currently selected menu item.
  public var selectedTextColor: UIColor
  
  /// The background color for the menu items.
  public var backgroundColor: UIColor
  
  /// The background color for the selected menu item.
  public var selectedBackgroundColor: UIColor
  
  /// The background color for the view behind the menu items.
  public var menuBackgroundColor: UIColor
  
  #if swift(>=4.2)
  public var scrollPosition: UICollectionView.ScrollPosition {
    switch selectedScrollPosition {
    case .left:
      return UICollectionView.ScrollPosition.left
    case .right:
      return UICollectionView.ScrollPosition.right
    case .preferCentered, .center:
      return UICollectionView.ScrollPosition.centeredHorizontally
    }
  }
  #else
  public var scrollPosition: UICollectionViewScrollPosition {
    switch selectedScrollPosition {
    case .left:
      return UICollectionViewScrollPosition.left
    case .right:
      return UICollectionViewScrollPosition.right
    case .preferCentered, .center:
      return UICollectionViewScrollPosition.centeredHorizontally
    }
  }
  #endif
  
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
    menuPosition = .top
    menuTransition = .scrollAlongside
    menuInteraction = .scrolling
    menuInsets = UIEdgeInsets.zero
    menuItemSpacing = 0
    menuHorizontalAlignment = .left
    includeSafeAreaInsets = true
    indicatorClass = PagingIndicatorView.self
    borderClass = PagingBorderView.self
    menuLayoutClass = PagingCollectionViewLayout.self
    
    indicatorOptions = .visible(
        height: 4,
        zIndex: Int.max,
        spacing: UIEdgeInsets.zero,
        insets: UIEdgeInsets(top: 0, left: 8, bottom: 0, right: 8))
  
    borderOptions = .visible(
        height: 1,
        zIndex: Int.max - 1,
        insets: UIEdgeInsets(top: 0, left: 8, bottom: 0, right: 8))

    #if swift(>=4.0)
    font = UIFont.systemFont(ofSize: 15, weight: UIFont.Weight.medium)
    selectedFont = UIFont.systemFont(ofSize: 15, weight: UIFont.Weight.medium)
    #else
    font = UIFont.systemFont(ofSize: 15, weight: UIFontWeightMedium)
    selectedFont = UIFont.systemFont(ofSize: 15, weight: UIFontWeightMedium)
    #endif
    
    textColor = UIColor.black
    selectedTextColor = UIColor(red: 3/255, green: 125/255, blue: 233/255, alpha: 1)
    backgroundColor = .clear
    selectedBackgroundColor = .clear
    menuBackgroundColor = UIColor.white
    borderColor = UIColor(white: 0.9, alpha: 1)
    indicatorColor = UIColor(red: 3/255, green: 125/255, blue: 233/255, alpha: 1)
  }
}

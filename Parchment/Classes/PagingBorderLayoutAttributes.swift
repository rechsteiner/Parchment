import UIKit

open class PagingBorderLayoutAttributes: UICollectionViewLayoutAttributes {
  
  open var backgroundColor: UIColor?
  open var insets: UIEdgeInsets = UIEdgeInsets()
  
  override open func copy(with zone: NSZone? = nil) -> Any {
    let copy = super.copy(with: zone) as! PagingBorderLayoutAttributes
    copy.backgroundColor = backgroundColor
    copy.insets = insets
    return copy
  }
  
  override open func isEqual(_ object: Any?) -> Bool {
    if let rhs = object as? PagingBorderLayoutAttributes {
      if backgroundColor != rhs.backgroundColor || insets != rhs.insets {
        return false
      }
      return super.isEqual(object)
    } else {
      return false
    }
  }
  
  func configure(_ options: PagingOptions, safeAreaInsets: UIEdgeInsets = .zero) {
    if case let .visible(height, index, borderInsets) = options.borderOptions {
      insets = borderInsets
      backgroundColor = options.borderColor
        
      switch options.menuPosition {
      case .top:
        frame.origin.y = options.menuHeight - height
      case .bottom:
        frame.origin.y = 0
      }

      frame.size.height = height
      zIndex = index
    }
  }
  
  func update(contentSize: CGSize, bounds: CGRect, safeAreaInsets: UIEdgeInsets) {
    let width = max(bounds.width, contentSize.width)
    frame.size.width = width - insets.horizontal - safeAreaInsets.horizontal
    frame.origin.x = insets.left + safeAreaInsets.left
  }
  
}

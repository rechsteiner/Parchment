import UIKit

/// A custom `UICollectionViewLayoutAttributes` subclass that adds a
/// `progress` property indicating how far the user has scrolled.
open class PagingCellLayoutAttributes: UICollectionViewLayoutAttributes {
    nonisolated(unsafe) open var progress: CGFloat = 0.0

    open override func copy(with zone: NSZone? = nil) -> Any {
        let copy = super.copy(with: zone) as! PagingCellLayoutAttributes
        copy.progress = progress
        return copy
    }

    open override func isEqual(_ object: Any?) -> Bool {
        if let rhs = object as? PagingCellLayoutAttributes {
            if progress != rhs.progress {
                return false
            }
            return super.isEqual(object)
        } else {
            return false
        }
    }
}

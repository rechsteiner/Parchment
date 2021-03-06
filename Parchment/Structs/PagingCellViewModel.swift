import Foundation
import UIKit

struct PagingTitleCellViewModel {
    let title: String?
    let font: UIFont
    let selectedFont: UIFont
    let textColor: UIColor
    let selectedTextColor: UIColor
    let backgroundColor: UIColor
    let selectedBackgroundColor: UIColor
    let selected: Bool
    let labelSpacing: CGFloat

    init(title: String?, selected: Bool, options: PagingOptions) {
        self.title = title
        font = options.font
        selectedFont = options.selectedFont
        textColor = options.textColor
        selectedTextColor = options.selectedTextColor
        backgroundColor = options.backgroundColor
        selectedBackgroundColor = options.selectedBackgroundColor
        self.selected = selected
        labelSpacing = options.menuItemLabelSpacing
    }
}

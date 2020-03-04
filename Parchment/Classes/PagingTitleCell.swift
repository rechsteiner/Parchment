import UIKit

/// A custom `PagingCell` implementation that only displays a text
/// label. The title is based on the `PagingTitleItem` and the colors
/// are based on the `PagingTheme` passed into `setPagingItem:`. When
/// applying layout attributes it will interpolate between the default
/// and selected text color based on the `progress` property.
open class PagingTitleCell: PagingCell {
  
  public let titleLabel = UILabel(frame: .zero)
  private var viewModel: PagingTitleCellViewModel?
  
  open override var isSelected: Bool {
    didSet {
      configureTitleLabel()
    }
  }
  
  public override init(frame: CGRect) {
    super.init(frame: frame)
    configure()
  }
  
  public required init?(coder: NSCoder) {
    super.init(coder: coder)
    configure()
  }
  
  open override func setPagingItem(_ pagingItem: PagingItem, selected: Bool, options: PagingOptions) {
    if let titleItem = pagingItem as? PagingIndexItem {
      viewModel = PagingTitleCellViewModel(
        title: titleItem.title,
        selected: selected,
        options: options)
    }
    configureTitleLabel()
    configureAccessibility()
  }
  
  open func configure() {
    contentView.addSubview(titleLabel)
    contentView.isAccessibilityElement = true
  }
  
  open override func layoutSubviews() {
    super.layoutSubviews()
    titleLabel.frame = contentView.bounds
  }
  
  open func configureTitleLabel() {
    guard let viewModel = viewModel else { return }
    titleLabel.text = viewModel.title
    titleLabel.textAlignment = .center
    
    if viewModel.selected {
      titleLabel.font = viewModel.selectedFont
      titleLabel.textColor = viewModel.selectedTextColor
      backgroundColor = viewModel.selectedBackgroundColor
    } else {
      titleLabel.font = viewModel.font
      titleLabel.textColor = viewModel.textColor
      backgroundColor = viewModel.backgroundColor
    }
  }

  open func configureAccessibility() {
    contentView.accessibilityLabel = viewModel?.title
    contentView.accessibilityTraits = viewModel?.selected ?? false ? .selected : .none
  }
  
  open override func apply(_ layoutAttributes: UICollectionViewLayoutAttributes) {
    super.apply(layoutAttributes)
    guard let viewModel = viewModel else { return }
    if let attributes = layoutAttributes as? PagingCellLayoutAttributes {
      titleLabel.textColor = UIColor.interpolate(
        from: viewModel.textColor,
        to: viewModel.selectedTextColor,
        with: attributes.progress)
      
      backgroundColor = UIColor.interpolate(
        from: viewModel.backgroundColor,
        to: viewModel.selectedBackgroundColor,
        with: attributes.progress)
    }
  }
}

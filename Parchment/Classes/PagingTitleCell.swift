import UIKit

/// A custom `PagingCell` implementation that only displays a text
/// label. The title is based on the `PagingTitleItem` and the colors
/// are based on the `PagingTheme` passed into `setPagingItem:`. When
/// applying layout attributes it will interpolate between the default
/// and selected text color based on the `progress` property.
open class PagingTitleCell: PagingCell {
  
  public let titleLabel = UILabel(frame: .zero)
  private var viewModel: PagingTitleCellViewModel?

  private var labelHorizontalConstraints: [NSLayoutConstraint]?
  
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
    titleLabel.translatesAutoresizingMaskIntoConstraints = false

    let horizontalConstraints = NSLayoutConstraint.constraints(
      withVisualFormat: "H:|[label]|",
      options: NSLayoutConstraint.FormatOptions(),
      metrics: nil,
      views: ["label": titleLabel])
    
    labelHorizontalConstraints = horizontalConstraints
    
    let verticalContraints = NSLayoutConstraint.constraints(
      withVisualFormat: "V:|[label]|",
      options: NSLayoutConstraint.FormatOptions(),
      metrics: nil,
      views: ["label": titleLabel])
    
    contentView.addConstraints(horizontalConstraints)
    contentView.addConstraints(verticalContraints)
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

    if case .selfSizing = viewModel.menuItemSize {
      labelHorizontalConstraints?.forEach { $0.constant = 20 }
    }
  }

  open func configureAccessibility() {
    accessibilityIdentifier = viewModel?.title
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

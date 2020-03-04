import UIKit
import Parchment

struct IconPagingCellViewModel {
  let image: UIImage?
  let selected: Bool
  let tintColor: UIColor
  let selectedTintColor: UIColor
  
  init(image: UIImage?, selected: Bool, options: PagingOptions) {
    self.image = image
    self.selected = selected
    self.tintColor = options.textColor
    self.selectedTintColor = options.selectedTextColor
  }
}

class IconPagingCell: PagingCell {
  
  fileprivate var viewModel: IconPagingCellViewModel?
  
  fileprivate lazy var imageView: UIImageView = {
    let imageView = UIImageView(frame: .zero)
    imageView.contentMode = .scaleAspectFit
    return imageView
  }()
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    contentView.addSubview(imageView)
    setupConstraints()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func setPagingItem(_ pagingItem: PagingItem, selected: Bool, options: PagingOptions) {
    if let item = pagingItem as? IconItem {

      let viewModel = IconPagingCellViewModel(
        image: item.image,
        selected: selected,
        options: options)
      
      imageView.image = viewModel.image
      
      if viewModel.selected {
        imageView.transform = CGAffineTransform(scaleX: 1, y: 1)
        imageView.tintColor = viewModel.selectedTintColor
      } else {
        imageView.transform = CGAffineTransform(scaleX: 0.6, y: 0.6)
        imageView.tintColor = viewModel.tintColor
      }
      
      self.viewModel = viewModel
    }
  }
    
  private func setupConstraints() {
    imageView.translatesAutoresizingMaskIntoConstraints = false
    
    let topContraint = NSLayoutConstraint(
      item: imageView,
      attribute: .top,
      relatedBy: .equal,
      toItem: contentView,
      attribute: .top,
      multiplier: 1.0,
      constant: 15)
    
    let bottomConstraint = NSLayoutConstraint(
      item: imageView,
      attribute: .bottom,
      relatedBy: .equal,
      toItem: contentView,
      attribute: .bottom,
      multiplier: 1.0,
      constant: -15)
    
    let leadingContraint = NSLayoutConstraint(
      item: imageView,
      attribute: .leading,
      relatedBy: .equal,
      toItem: contentView,
      attribute: .leading,
      multiplier: 1.0,
      constant: 0)
    
    let trailingContraint = NSLayoutConstraint(
      item: imageView,
      attribute: .trailing,
      relatedBy: .equal,
      toItem: contentView,
      attribute: .trailing,
      multiplier: 1.0,
      constant: 0)
    
    contentView.addConstraints([
      topContraint,
      bottomConstraint,
      leadingContraint,
      trailingContraint])
  }
  
}

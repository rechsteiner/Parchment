import UIKit
import Parchment

// First thing we need to do is create our own PagingItem that will
// hold the data for the different menu items. The header image is the
// image that will be displayed in the menu and the title will be
// overlayed above that.  We also need to store the array of images
// that we want to show when the item is tapped.
struct ImageItem: PagingItem, Hashable, Comparable {
  let index: Int
  let title: String
  let headerImage: UIImage
  let images: [UIImage]
  
  static func < (lhs: ImageItem, rhs: ImageItem) -> Bool {
    return lhs.index < rhs.index
  }
}

// Create our own custom paging view and override the layout
// constraints. The default implementation constrains the menu view
// to the page menu, but we want to keep them independent and store
// the height constraint so that we can update it later.
class CustomPagingView: PagingView {
  
  var menuHeightConstraint: NSLayoutConstraint?
  
  override func setupConstraints() {
    pageView.translatesAutoresizingMaskIntoConstraints = false
    collectionView.translatesAutoresizingMaskIntoConstraints = false
    
    menuHeightConstraint = collectionView.heightAnchor.constraint(equalToConstant: options.menuHeight)
    menuHeightConstraint?.isActive = true
    
    NSLayoutConstraint.activate([
      collectionView.leadingAnchor.constraint(equalTo: leadingAnchor),
      collectionView.trailingAnchor.constraint(equalTo: trailingAnchor),
      collectionView.topAnchor.constraint(equalTo: topAnchor),
      
      pageView.leadingAnchor.constraint(equalTo: leadingAnchor),
      pageView.trailingAnchor.constraint(equalTo: trailingAnchor),
      pageView.bottomAnchor.constraint(equalTo: bottomAnchor),
      pageView.topAnchor.constraint(equalTo: topAnchor)
    ])
  }
}

// Create a custom paging view controller and override the view with
// our own custom subclass.
class CustomPagingViewController: PagingViewController {
  override func loadView() {
    view = CustomPagingView(
      options: options,
      collectionView: collectionView,
      pageView: pageViewController.view
    )
  }
}

class ViewController: UIViewController {

  private let items = [
    ImageItem(
      index: 0,
      title: "Green",
      headerImage: UIImage(named: "green-1")!,
      images: [
        UIImage(named: "green-1")!,
        UIImage(named: "green-2")!,
        UIImage(named: "green-3")!,
        UIImage(named: "green-4")!,
        ]
    ),
    ImageItem(
      index: 1,
      title: "Food",
      headerImage: UIImage(named: "food-1")!,
      images: [
        UIImage(named: "food-1")!,
        UIImage(named: "food-2")!,
        UIImage(named: "food-3")!,
        UIImage(named: "food-4")!,
        ]
    ),
    ImageItem(
      index: 2,
      title: "Succulents",
      headerImage: UIImage(named: "succulents-1")!,
      images: [
        UIImage(named: "succulents-1")!,
        UIImage(named: "succulents-2")!,
        UIImage(named: "succulents-3")!,
        UIImage(named: "succulents-4")!,
        ]
    ),
    ImageItem(
      index: 3,
      title: "City",
      headerImage: UIImage(named: "city-1")!,
      images: [
        UIImage(named: "city-3")!,
        UIImage(named: "city-2")!,
        UIImage(named: "city-1")!,
        UIImage(named: "city-4")!,
        ]
    ),
    ImageItem(
      index: 4,
      title: "Scenic",
      headerImage: UIImage(named: "scenic-1")!,
      images: [
        UIImage(named: "scenic-1")!,
        UIImage(named: "scenic-2")!,
        UIImage(named: "scenic-3")!,
        UIImage(named: "scenic-4")!,
        ]
    ),
    ImageItem(
      index: 5,
      title: "Coffee",
      headerImage: UIImage(named: "coffee-1")!,
      images: [
        UIImage(named: "coffee-1")!,
        UIImage(named: "coffee-2")!,
        UIImage(named: "coffee-3")!,
        UIImage(named: "coffee-4")!,
        ]
    )
  ]
  
  // Create our custom paging view controller.
  private let pagingViewController = CustomPagingViewController()
  
  // Store the menu insets and item size and use that to calculate
  // the height of the collection view. We will use these values later
  // to calculate the height of the menu based on the scroll.
  private let menuInsets = UIEdgeInsets(top: 12, left: 18, bottom: 12, right: 18)
  private let menuItemSize = CGSize(width: 120, height: 100)
  
  private var menuHeight: CGFloat {
    return menuItemSize.height + menuInsets.top + menuInsets.bottom
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    pagingViewController.register(ImagePagingCell.self, for: ImageItem.self)
    pagingViewController.menuItemSize = .fixed(width: menuItemSize.width, height: menuItemSize.height)
    pagingViewController.menuItemSpacing = 8
    pagingViewController.menuInsets = menuInsets
    pagingViewController.borderColor = UIColor(white: 0, alpha: 0.1)
    pagingViewController.indicatorColor = .black
    
    pagingViewController.indicatorOptions = .visible(
      height: 1,
      zIndex: Int.max,
      spacing: UIEdgeInsets.zero,
      insets: UIEdgeInsets.zero
    )
    
    pagingViewController.borderOptions = .visible(
      height: 1,
      zIndex: Int.max - 1,
      insets: UIEdgeInsets(top: 0, left: 18, bottom: 0, right: 18)
    )
    
    // Add the paging view controller as a child view controller and
    // contrain it to all edges.
    addChild(pagingViewController)
    view.addSubview(pagingViewController.view)
    view.constrainToEdges(pagingViewController.view)
    pagingViewController.didMove(toParent: self)
    
    // Set our data source and delegate.
    pagingViewController.dataSource = self
    pagingViewController.delegate = self
    
    // Set the first item as the selected paging item.
    pagingViewController.select(pagingItem: items[0])
  }
  
  private func calculateMenuHeight(for scrollView: UIScrollView) -> CGFloat {
    // Calculate the height of the menu view based on the scroll view
    // content offset.
    let maxChange: CGFloat = 50
    let offset = min(maxChange, scrollView.contentOffset.y + menuHeight) / maxChange
    let height = menuHeight - (offset * maxChange)
    return height
  }
  
  private func updateMenu(height: CGFloat) {
    guard let menuView = pagingViewController.view as? CustomPagingView else { return }

    // Update the height constraint of the menu view.
    menuView.menuHeightConstraint?.constant = height
    
    // Update the size of the menu items.
    pagingViewController.menuItemSize = .fixed(
      width: menuItemSize.width,
      height: height - menuInsets.top - menuInsets.bottom
    )
    
    // Invalidate the collection view layout and call layoutIfNeeded
    // to make sure the collection is updated.
    pagingViewController.collectionViewLayout.invalidateLayout()
    pagingViewController.collectionView.layoutIfNeeded()
  }

}

extension ViewController: PagingViewControllerDataSource {
  
  func pagingViewController(_: PagingViewController, viewControllerAt index: Int) -> UIViewController {
    let viewController = ImagesViewController(
      images: items[index].images,
      options: pagingViewController.options
    )
    
    // Set the `ImagesViewControllerDelegate` that allows us to get
    // notified when the images view controller scrolls.
    viewController.delegate = self
    
    // Inset the collection view with the height of the menu.
    let insets = UIEdgeInsets(top: menuHeight, left: 0, bottom: 0, right: 0)
    viewController.collectionView.contentInset = insets
    viewController.collectionView.scrollIndicatorInsets = insets
    
    return viewController
  }
  
  func pagingViewController(_: PagingViewController, pagingItemAt index: Int) -> PagingItem {
    return items[index]
  }
  
  func numberOfViewControllers(in pagingViewController: PagingViewController) -> Int {
    return items.count
  }
  
}

extension ViewController: ImagesViewControllerDelegate {
  
  func imagesViewControllerDidScroll(_ imagesViewController: ImagesViewController) {
    // Calculate the menu height based on the content offset of the
    // currenly selected view controller and update the menu.
    let height = calculateMenuHeight(for: imagesViewController.collectionView)
    updateMenu(height: height)
  }
  
}

extension ViewController: PagingViewControllerDelegate {
  
  func pagingViewController(_: PagingViewController, isScrollingFromItem currentPagingItem: PagingItem, toItem upcomingPagingItem: PagingItem?, startingViewController: UIViewController, destinationViewController: UIViewController?, progress: CGFloat) {
    guard let destinationViewController = destinationViewController as? ImagesViewController else { return }
    guard let startingViewController = startingViewController as? ImagesViewController else { return }
    
    // Tween between the current menu offset and the menu offset of
    // the destination view controller.
    let from = calculateMenuHeight(for: startingViewController.collectionView)
    let to = calculateMenuHeight(for: destinationViewController.collectionView)
    let height = ((to - from) * abs(progress)) + from
    updateMenu(height: height)
  }
  
}

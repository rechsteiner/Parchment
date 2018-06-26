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
  
  var hashValue: Int {
    return index.hashValue &+ title.hashValue
  }
  
  static func ==(lhs: ImageItem, rhs: ImageItem) -> Bool {
    return lhs.index == rhs.index && lhs.title == rhs.title
  }
  
  static func <(lhs: ImageItem, rhs: ImageItem) -> Bool {
    return lhs.index < rhs.index
  }
}

class ViewController: UIViewController {

  fileprivate let items = [
    ImageItem(
      index: 0,
      title: "Green",
      headerImage: UIImage(named: "green-1")!,
      images: [
        UIImage(named: "green-1")!,
        UIImage(named: "green-2")!,
        UIImage(named: "green-3")!,
        UIImage(named: "green-4")!,
        ]),
    ImageItem(
      index: 1,
      title: "Food",
      headerImage: UIImage(named: "food-1")!,
      images: [
        UIImage(named: "food-1")!,
        UIImage(named: "food-2")!,
        UIImage(named: "food-3")!,
        UIImage(named: "food-4")!,
        ]),
    ImageItem(
      index: 2,
      title: "Succulents",
      headerImage: UIImage(named: "succulents-1")!,
      images: [
        UIImage(named: "succulents-1")!,
        UIImage(named: "succulents-2")!,
        UIImage(named: "succulents-3")!,
        UIImage(named: "succulents-4")!,
        ]),
    ImageItem(
      index: 3,
      title: "City",
      headerImage: UIImage(named: "city-1")!,
      images: [
        UIImage(named: "city-3")!,
        UIImage(named: "city-2")!,
        UIImage(named: "city-1")!,
        UIImage(named: "city-4")!,
        ]),
    ImageItem(
      index: 4,
      title: "Scenic",
      headerImage: UIImage(named: "scenic-1")!,
      images: [
        UIImage(named: "scenic-1")!,
        UIImage(named: "scenic-2")!,
        UIImage(named: "scenic-3")!,
        UIImage(named: "scenic-4")!,
        ]),
    ImageItem(
      index: 5,
      title: "Coffee",
      headerImage: UIImage(named: "coffee-1")!,
      images: [
        UIImage(named: "coffee-1")!,
        UIImage(named: "coffee-2")!,
        UIImage(named: "coffee-3")!,
        UIImage(named: "coffee-4")!,
        ]),
    ]
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    let pagingViewController = PagingViewController<ImageItem>()
    pagingViewController.menuItemClass = ImagePagingCell.self
    pagingViewController.menuItemSize = .fixed(width: 70, height: 70)
    pagingViewController.menuItemSpacing = 8
    pagingViewController.menuInsets = UIEdgeInsets(top: 12, left: 18, bottom: 12, right: 18)
    pagingViewController.borderColor = UIColor(white: 0, alpha: 0.1)
    pagingViewController.indicatorColor = .black
    
    pagingViewController.indicatorOptions = .visible(
      height: 1,
      zIndex: Int.max,
      spacing: UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0),
      insets: UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0))
    
    pagingViewController.borderOptions = .visible(
      height: 1,
      zIndex: Int.max - 1,
      insets: UIEdgeInsets(top: 0, left: 18, bottom: 0, right: 18))
    
    // Add the paging view controller as a child view controller and
    // contrain it to all edges.
    addChildViewController(pagingViewController)
    view.addSubview(pagingViewController.view)
    view.constrainToEdges(pagingViewController.view)
    pagingViewController.didMove(toParentViewController: self)
    
    // Set our custom data source.
    pagingViewController.dataSource = self
    
    // Set the first item as the selected paging item.
    pagingViewController.select(pagingItem: items[0])
  }

}

extension ViewController: PagingViewControllerDataSource {
  
  func pagingViewController<T>(_ pagingViewController: PagingViewController<T>, viewControllerForIndex index: Int) -> UIViewController {
    return ImagesViewController(images: items[index].images)
  }
  
  func pagingViewController<T>(_ pagingViewController: PagingViewController<T>, pagingItemForIndex index: Int) -> T {
    return items[index] as! T
  }
  
  func numberOfViewControllers<T>(in: PagingViewController<T>) -> Int{
    return items.count
  }
  
}

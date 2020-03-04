import UIKit
import Parchment

// This first thing we need to do is to create our own custom paging
// view and override the layout constraints. The default
// implementation positions the menu view above the page view
// controller, but we want to include a header view above the menu. We
// also create a layout constraint property that allows us to update
// the height of the header.
class CustomPagingView: PagingView {
  
  static let HeaderHeight: CGFloat = 200
  
  var headerHeightConstraint: NSLayoutConstraint?
  
  private lazy var headerView: UIImageView = {
    let view = UIImageView(image: UIImage(named: "Header"))
    view.contentMode = .scaleAspectFill
    view.clipsToBounds = true
    return view
  }()
  
  override func setupConstraints() {
    addSubview(headerView)
    
    pageView.translatesAutoresizingMaskIntoConstraints = false
    collectionView.translatesAutoresizingMaskIntoConstraints = false
    headerView.translatesAutoresizingMaskIntoConstraints = false
    
    headerHeightConstraint = headerView.heightAnchor.constraint(
      equalToConstant: CustomPagingView.HeaderHeight
    )
    headerHeightConstraint?.isActive = true
    
    NSLayoutConstraint.activate([
      collectionView.leadingAnchor.constraint(equalTo: leadingAnchor),
      collectionView.trailingAnchor.constraint(equalTo: trailingAnchor),
      collectionView.heightAnchor.constraint(equalToConstant: options.menuHeight),
      collectionView.topAnchor.constraint(equalTo: headerView.bottomAnchor),
      
      headerView.topAnchor.constraint(equalTo: topAnchor),
      headerView.leadingAnchor.constraint(equalTo: leadingAnchor),
      headerView.trailingAnchor.constraint(equalTo: trailingAnchor),
      
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
  
  private let pagingViewController = CustomPagingViewController()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    // Add the paging view controller as a child view controller.
    addChild(pagingViewController)
    view.addSubview(pagingViewController.view)
    pagingViewController.didMove(toParent: self)
    
    // Customize the menu styling.
    pagingViewController.selectedTextColor = .black
    pagingViewController.indicatorColor = .black
    pagingViewController.indicatorOptions = .visible(
      height: 1,
      zIndex: Int.max,
      spacing: .zero,
      insets: .zero
    )
    
    // Contrain the paging view to all edges.
    pagingViewController.view.translatesAutoresizingMaskIntoConstraints = false
    NSLayoutConstraint.activate([
      pagingViewController.view.topAnchor.constraint(equalTo: view.topAnchor),
      pagingViewController.view.bottomAnchor.constraint(equalTo: view.bottomAnchor),
      pagingViewController.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
      pagingViewController.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
    ])
    
    // Set our data source and delegate.
    pagingViewController.dataSource = self
    pagingViewController.delegate = self
  }

}

extension ViewController: PagingViewControllerDataSource {
  
  func pagingViewController(_: PagingViewController, viewControllerAt index: Int) -> UIViewController {
    let viewController = TableViewController()
    
    // Inset the table view with the height of the menu height.
    let height = pagingViewController.options.menuHeight + CustomPagingView.HeaderHeight
    let insets = UIEdgeInsets(top: height, left: 0, bottom: 0, right: 0)
    viewController.tableView.contentInset = insets
    viewController.tableView.scrollIndicatorInsets = insets
    viewController.tableView.delegate = self
    
    return viewController
  }
  
  func pagingViewController(_: PagingViewController, pagingItemAt index: Int) -> PagingItem {
    return PagingIndexItem(index: index, title: "View \(index)")
  }
  
  func numberOfViewControllers(in: PagingViewController) -> Int{
    return 3
  }
  
}

extension ViewController: PagingViewControllerDelegate {
  
  func pagingViewController(_ pagingViewController: PagingViewController, didScrollToItem pagingItem: PagingItem, startingViewController: UIViewController?, destinationViewController: UIViewController, transitionSuccessful: Bool) {
    guard let startingViewController = startingViewController as? TableViewController else { return }
    guard let destinationViewController = destinationViewController as? TableViewController else { return }
    
    // Set the delegate on the currently selected view so that we can
    // listen to the scroll view delegate.
    if transitionSuccessful {
      startingViewController.tableView.delegate = nil
      destinationViewController.tableView.delegate = self
    }
  }
  
  func pagingViewController(_: PagingViewController, willScrollToItem pagingItem: PagingItem, startingViewController: UIViewController, destinationViewController: UIViewController) {
    guard let destinationViewController = destinationViewController as? TableViewController else { return }

    // Update the content offset based on the height of the header view.
    if let pagingView = pagingViewController.view as? CustomPagingView {
      if let headerHeight = pagingView.headerHeightConstraint?.constant {
        let offset = headerHeight + pagingViewController.options.menuHeight
        destinationViewController.tableView.contentOffset = CGPoint(x: 0, y: -offset)
      }
    }
  }
  
}

extension ViewController: UITableViewDelegate {
  
  func scrollViewDidScroll(_ scrollView: UIScrollView) {
    guard scrollView.contentOffset.y < 0 else { return }
    
    // Update the height of the header view based on the scroll view's
    // content offset.
    if let menuView = pagingViewController.view as? CustomPagingView {
      let height = max(0, abs(scrollView.contentOffset.y) - pagingViewController.options.menuHeight)
      menuView.headerHeightConstraint?.constant = height
    }
  }
  
}

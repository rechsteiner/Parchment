import UIKit
import Parchment

// This example shows how to use Parchment togehter with
// "prefersLargeTitles" on UINavigationBar. It works by creating a
// "hidden" scroll view that is added as a subview to the view
// controller. Apparently, UIKit will look for a scroll view that is
// the first subview of the selected view controller and update
// the navigation bar according to the content offset.
//
// Note: this approach will cause the navigation bar to jump to the
// small title state when scrolling down. I haven't figured out any
// of getting around this. Any ideas are welcome.


// This first thing we need to do is to create our own custom paging
// view and override the layout constraints. The default
// implementation positions the menu view above the page view
// controller, but since we're going to put the menu view inside the
// navigation bar we don't want to setup any layout constraints for
// the menu view.
class CustomPagingView: PagingView {
    
    override func setupConstraints() {
        pageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
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

    // Create an instance of UIScrollView that we will be used to
    // "trick" the navigation bar to update.
    private let hiddenScrollView = UIScrollView()
    
    // Create an instance of our custom paging view controller that
    // does not setup any constraints for the menu view.
    private let pagingViewController = CustomPagingViewController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        guard let navigationController = navigationController else { return }
        
        // Customize the menu to match the navigation bar color
        pagingViewController.menuBackgroundColor = UIColor(red: 85/255, green: 66/255, blue: 232/255, alpha: 1)
        pagingViewController.menuItemSize = .fixed(width: 150, height: 30)
        pagingViewController.textColor = UIColor.white.withAlphaComponent(0.7)
        pagingViewController.selectedTextColor = UIColor.white
        pagingViewController.borderOptions = .hidden
        pagingViewController.indicatorColor = UIColor(red: 10/255, green: 0, blue: 105/255, alpha: 1)
        
        // Add the "hidden" scroll view to the root of the UIViewController.
        view.addSubview(hiddenScrollView)
        hiddenScrollView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            hiddenScrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            hiddenScrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            hiddenScrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            hiddenScrollView.topAnchor.constraint(equalTo: view.topAnchor),
        ])
        
        // Add the PagingViewController and constrain it to all edges.
        addChildViewController(pagingViewController)
        view.addSubview(pagingViewController.view)
        pagingViewController.didMove(toParentViewController: self)
        
        pagingViewController.dataSource = self
        pagingViewController.delegate = self
        
        pagingViewController.view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            pagingViewController.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            pagingViewController.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            pagingViewController.view.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            pagingViewController.view.topAnchor.constraint(equalTo: view.topAnchor),
        ])

        // Add the menu view as a subview to the navigation
        // controller and constrain it to the bottom of the navigation
        // bar. This is the best way I've found to make a view scroll
        // alongside the navigation bar.
        navigationController.view.addSubview(pagingViewController.collectionView)
        pagingViewController.collectionView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            pagingViewController.collectionView.heightAnchor.constraint(equalToConstant: pagingViewController.options.menuItemSize.height),
            pagingViewController.collectionView.leadingAnchor.constraint(equalTo: navigationController.view.leadingAnchor),
            pagingViewController.collectionView.trailingAnchor.constraint(equalTo: navigationController.view.trailingAnchor),
            pagingViewController.collectionView.topAnchor.constraint(equalTo: navigationController.navigationBar.bottomAnchor),
        ])
        extendedLayoutIncludesOpaqueBars = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Running layout here fixes an issue where only the first
        // cell in the menu is shown initially.
        navigationController?.view.layoutIfNeeded()
        pagingViewController.view.layoutIfNeeded()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        guard let viewController = pagingViewController.pageViewController.selectedViewController as? TableViewController else { return }
        
        // When switching to another view controller, update the hidden
        // scroll view to match the current table view.
        hiddenScrollView.contentSize = viewController.tableView.contentSize
        hiddenScrollView.contentInset = viewController.tableView.contentInset
        hiddenScrollView.contentOffset = viewController.tableView.contentOffset
        
        // Set the UITableViewDelegate to the currenly visible table view.
        viewController.tableView.delegate = self
    }

}

extension ViewController: PagingViewControllerDataSource {
    
  func pagingViewController(_: PagingViewController, viewControllerAt index: Int) -> UIViewController {
        let viewController = TableViewController(style: .plain)
        
        // Inset the table view with the height of the menu height.
        let insets = UIEdgeInsets(top: pagingViewController.options.menuItemSize.height, left: 0, bottom: 0, right: 0)
        viewController.tableView.scrollIndicatorInsets = insets
        viewController.tableView.contentInset = insets
        return viewController
    }
    
    func pagingViewController(_: PagingViewController, pagingItemAt index: Int) -> PagingItem {
        return PagingIndexItem(index: index, title: "View \(index)")
    }
    
    func numberOfViewControllers(in pagingViewController: PagingViewController) -> Int {
        return 3
    }
    
}

extension ViewController: PagingViewControllerDelegate {
    
    func pagingViewController(_: PagingViewController, willScrollToItem pagingItem: PagingItem, startingViewController: UIViewController, destinationViewController: UIViewController) {
        guard let startingViewController = startingViewController as? TableViewController else { return }
        // Remove the UITableViewDelegate delegate when starting to
        // scroll to another page.
        startingViewController.tableView.delegate = nil
    }

    func pagingViewController(_: PagingViewController, didScrollToItem pagingItem: PagingItem, startingViewController: UIViewController?, destinationViewController: UIViewController, transitionSuccessful: Bool) {
        guard let destinationViewController = destinationViewController as? TableViewController else { return }
        guard let startingViewController = startingViewController as? TableViewController else { return }

        // Set the UITableViewDelegate back to the currenly selected
        // view controller when the page scroll ended.
        if transitionSuccessful {
            destinationViewController.tableView.delegate = self
            
            // When switching to another view controller, update the
            // hidden scroll view to match the current table view.
            hiddenScrollView.contentSize = destinationViewController.tableView.contentSize
            hiddenScrollView.contentOffset = destinationViewController.tableView.contentOffset
            hiddenScrollView.contentInset = destinationViewController.tableView.contentInset
        } else {
            startingViewController.tableView.delegate = self
        }
        
        return
    }
    
}

extension ViewController: UITableViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        // When the current table view is scrolling, we update the
        // content offset of the hidden scroll view to trigger the
        // large titles to update.
        hiddenScrollView.contentOffset = scrollView.contentOffset
        hiddenScrollView.panGestureRecognizer.state = scrollView.panGestureRecognizer.state
    }
    
}

import UIKit
import Parchment

// Create our own custom paging view and override the layout
// constraints. The default implementation positions the menu view
// above the page view controller, but since we're going to put the
// menu view inside the navigation bar we don't want to setup any
// layout constraints for the menu view.
class CustomPagingView: PagingView {
  
  override func setupConstraints() {
    // Use our convenience extension to constrain the page view to all
    // of the edges of the super view.
    constrainToEdges(pageView)
  }
}

// Create a custom paging view controller and override the view with
// our own custom subclass.
class CustomPagingViewController: PagingViewController {
  override func loadView() {
    view = CustomPagingView(
      options: options,
      collectionView: collectionView,
      pageView: pageViewController.view)
  }
}

class ViewController: UIViewController {

  let pagingViewController = CustomPagingViewController(viewControllers: [
    IndexViewController(index: 0),
    IndexViewController(index: 1),
    IndexViewController(index: 2),
    IndexViewController(index: 3),
    IndexViewController(index: 4)
  ])
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    pagingViewController.borderOptions = .hidden
    pagingViewController.menuBackgroundColor = .clear
    pagingViewController.indicatorColor = UIColor(white: 0, alpha: 0.4)
    pagingViewController.textColor = UIColor(white: 1, alpha: 0.6)
    pagingViewController.selectedTextColor = .white
    
    // Make sure you add the PagingViewController as a child view
    // controller and contrain it to the edges of the view.
    addChild(pagingViewController)
    view.addSubview(pagingViewController.view)
    view.constrainToEdges(pagingViewController.view)
    pagingViewController.didMove(toParent: self)
    
    // Set the menu view as the title view on the navigation bar. This
    // will remove the menu view from the view hierachy and put it
    // into the navigation bar.
    navigationItem.titleView = pagingViewController.collectionView
  }

  override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()
    guard let navigationBar = navigationController?.navigationBar else { return }
    navigationItem.titleView?.frame = CGRect(origin: .zero, size: navigationBar.bounds.size)
    pagingViewController.menuItemSize = .fixed(width: 100, height: navigationBar.bounds.height)
  }
  
}

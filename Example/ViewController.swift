import UIKit
import Parchment

// This is the simplest use case of using Parchment. We just create a
// bunch of view controllers, and pass them into our paging view
// controller. FixedPagingViewController is a subclass of
// PagingViewController that makes it much easier to get started with
// Parchment when you only have a fixed array of view controllers. It
// will create a data source for us and set up the paging items to
// display the view controllers title.
class ViewController: UIViewController {
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    let viewControllers = (0...10).map { IndexViewController(index: $0) }
    let pagingViewController = FixedPagingViewController(viewControllers: viewControllers)
    
    // Make sure you add the PagingViewController as a child view
    // controller and constrain it to the edges of the view.
    addChild(pagingViewController)
    view.addSubview(pagingViewController.view)
    view.constrainToEdges(pagingViewController.view)
    pagingViewController.didMove(toParent: self)
  }
  
}

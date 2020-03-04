import UIKit
import Parchment

class ViewController: UIViewController {

  override func viewDidLoad() {
    super.viewDidLoad()
    
    // Load each of the view controllers you want to embed
    // from the storyboard.
    let storyboard = UIStoryboard(name: "Main", bundle: nil)
    let firstViewController = storyboard.instantiateViewController(withIdentifier: "FirstViewController")
    let secondViewController = storyboard.instantiateViewController(withIdentifier: "SecondViewController")
    
    // Initialize a FixedPagingViewController and pass
    // in the view controllers.
    let pagingViewController = PagingViewController(viewControllers: [
      firstViewController,
      secondViewController
    ])
    
    // Make sure you add the PagingViewController as a child view
    // controller and contrain it to the edges of the view.
    addChild(pagingViewController)
    view.addSubview(pagingViewController.view)
    view.constrainToEdges(pagingViewController.view)
    pagingViewController.didMove(toParent: self)

  }
}

# Basic usage

The easiest way of using Parchment is to initialize `PagingViewController` with the an array of the view controllers you want to display:

```Swift
class ViewController: UIViewController {
  override func viewDidLoad() {
    super.viewDidLoad()
    let firstViewController = UIViewController()
    let secondViewController = UIViewController()

    let pagingViewController = PagingViewController(viewControllers: [
      firstViewController,
      secondViewController
    ])
  }
}
```

Then add the `pagingViewController` as a child view controller and setup the constraints for the view:

```Swift
addChildViewController(pagingViewController)
view.addSubview(pagingViewController.view)
pagingViewController.didMove(toParentViewController: self)
pagingViewController.view.translatesAutoresizingMaskIntoConstraints = false

NSLayoutConstraint.activate([
  pagingViewController.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
  pagingViewController.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
  pagingViewController.view.bottomAnchor.constraint(equalTo: view.bottomAnchor),
  pagingViewController.view.topAnchor.constraint(equalTo: view.topAnchor)
])
```

Parchment will then generate menu items for each view controller using their title property.

_Check out the Example target for more details._

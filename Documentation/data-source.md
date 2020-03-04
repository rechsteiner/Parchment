# Using the data source

Let’s start by defining an array that contains the information we need to display our menu items:

```Swift
class ViewController: UIViewController {
    let cities = [
        "Oslo",
        "Stockholm",
        "Tokyo",
        "Barcelona",
        "Vancouver",
        "Berlin"
    ]
}
```

Then we initialize our `PagingViewController`:

```Swift
class ViewController: UIViewController {
    ...
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let pagingViewController = PagingViewController()
        pagingViewController.dataSource = self
    }
}
```

In our data source implementation we set the number of view controllers equal to the number of items in our cities array, and return an instance of `PagingTitleItem` with the title of each city:

```Swift
extension ViewController: PagingViewControllerDataSource {
    func numberOfViewControllers(in pagingViewController: PagingViewController) -> Int {
        return cities.count
    }

    func pagingViewController(_: PagingViewController, viewControllerAt index: Int) -> UIViewController {
        return CityViewController(city: cities[index])
    }

    func pagingViewController(_: PagingViewController, pagingItemAt index: Int) -> PagingItem {
        return PagingIndexItem(index: index, title: cities[index])
    }
}
```

The `viewControllerForIndex` method will only be called for the currently selected item and any of its siblings. This means that we only allocate the view controllers that are actually needed at any given point.

Parchment will automatically set the first item as selected, but if you want to select another you can do it like this:

```Swift
pagingViewController.select(index: 3)
```

This can be called both before and after the view has appeared.

_Check out the DelegateExample target for more details._
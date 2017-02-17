import UIKit
import Parchment

// First thing we need to do is create our own
// PagingItem that will hold our date. We also
// need to make sure it conforms to Equatable, 
// since that is required by PagingViewController
struct CalendarItem: PagingItem, Equatable {
  let date: Date
}

func ==(lhs: CalendarItem, rhs: CalendarItem) -> Bool {
  return lhs.date == rhs.date
}

// Create our own custom purple theme
struct CalendarPagingTheme: PagingTheme {
  let textColor = UIColor(red: 95/255, green: 102/255, blue: 108/255, alpha: 1)
  let selectedTextColor = UIColor(red: 117/255, green: 111/255, blue: 216/255, alpha: 1)
  let indicatorColor = UIColor(red: 117/255, green: 111/255, blue: 216/255, alpha: 1)
}

// We need create our own options struct so that
// we can customize it to our needs. Since we want
// to display both the current date and the weekday
// label in our menu items, we set the menuItemClass
// to be our CalendarPagingCell, which is a subclass
// of PagingCell
struct CalendarPagingOptions: PagingOptions {
  let menuItemClass: PagingCell.Type = CalendarPagingCell.self
  let menuItemSize: PagingMenuItemSize = .fixed(width: 48, height: 58)
  let indicatorOptions: PagingIndicatorOptions = .visible(height: 2,
                                                          zIndex: Int.max,
                                                          spacing: UIEdgeInsets(top: 0, left: 8, bottom: 0, right: 8),
                                                          insets: UIEdgeInsets(top: 0, left: 8, bottom: 0, right: 8))
  let theme: PagingTheme = CalendarPagingTheme()
}

class ViewController: UIViewController {
  
  // Initialize our PagingViewController with our
  // custom options. Note that we also need to specify
  // the generic type as our CalendarItem
  lazy var pagingViewController: PagingViewController<CalendarItem> = {
    return PagingViewController(options: CalendarPagingOptions())
  }()

  override func viewDidLoad() {
    super.viewDidLoad()
    
    // Add the paging view controller as a child view
    // controller and contrain it to all edges
    addChildViewController(pagingViewController)
    view.addSubview(pagingViewController.view)
    view.constrainToEdges(pagingViewController.view)
    pagingViewController.didMove(toParentViewController: self)
    
    // Set our custom data source
    pagingViewController.dataSource = self
  }
  
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    // Set the current date as the selected paging item
    pagingViewController.selectPagingItem(CalendarItem(date: Date()))
  }
  
}

// We need to conform to PagingViewControllerDataSource
// in order to implement our custom data source. We set the
// initial item to be the current date, and every time
// pagingItemBeforePagingItem: or pagingItemAfterPagingItem:
// is called, we either subtract or append the time
// interval equal to one day. This means our paging view
// controller will show one menu item for each day.

extension ViewController: PagingViewControllerDataSource {
  
  func pagingViewController<T>(_ pagingViewController: PagingViewController<T>, viewControllerForPagingItem pagingItem: T) -> UIViewController {
    let calendarItem = pagingItem as! CalendarItem
    return CalendarViewController(date: calendarItem.date)
  }
  
  func pagingViewController<T>(_ pagingViewController: PagingViewController<T>, pagingItemBeforePagingItem pagingItem: T) -> T? {
    let calendarItem = pagingItem as! CalendarItem
    return CalendarItem(date: calendarItem.date.addingTimeInterval(-86400)) as? T
  }
  
  func pagingViewController<T>(_ pagingViewController: PagingViewController<T>, pagingItemAfterPagingItem pagingItem: T) -> T? {
    let calendarItem = pagingItem as! CalendarItem
    return CalendarItem(date: calendarItem.date.addingTimeInterval(86400)) as? T
  }
  
}

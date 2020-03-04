<p align="center">
  <img src="https://rechsteiner-parchment.s3.eu-central-1.amazonaws.com/parchment-title-3.png" width="240" height="70" />
</p>

<p align="center">
    <strong><a href="#getting-started">Getting Started</a></strong> |
    <strong><a href="#customization">Customization</a></strong> |
    <strong><a href="#installation">Installation</a></strong>
</p>

<p align="center">
  <a href="https://circleci.com/gh/rechsteiner/Parchment"><img src="https://circleci.com/gh/rechsteiner/Parchment/tree/master.svg?style=shield&circle-token=8e4da6c8bf09271f72f32bf3c7a7c9d743ff50fb" /></a>
  <a href="https://cocoapods.org/pods/Parchment"><img src="https://img.shields.io/cocoapods/v/Parchment.svg" /></a>
  <a href="https://github.com/Carthage/Carthage"><img src="https://img.shields.io/badge/Carthage-compatible-4BC51D.svg" /></a>
</p>

<br/>

<p align="center">
  <img src="https://rechsteiner-parchment.s3.eu-central-1.amazonaws.com/parchment-delegate.gif" alt="Cities Example" />
  <img src="https://rechsteiner-parchment.s3.eu-central-1.amazonaws.com/parchment-unplash.gif" alt="Unsplash Example" />
  <img src="https://rechsteiner-parchment.s3.eu-central-1.amazonaws.com/parchment-calendar.gif" alt="Calendar Example" />
</p>

## Features

Parchment lets you page between view controllers while showing any type of generic indicator that scrolls along with the content. Here are some benefits of using Parchment:

* **Highly customizable** <br/> The menu items are built using
  `UICollectionView`, which means you can display pretty much whatever you want. You can even subclass the layout to create completely custom behaviours.

* **Memory-efficient**: <br/> Parchment only allocates view controllers when they’re needed, meaning if you have a lot of view controllers you don’t have to initialize them all up-front.

* **Infinite scrolling**: <br /> Because view controllers are only allocated as you are scrolling, you can create data sources that are infinitely large. This is perfect for things like [calendars](/Documentation/infinite-data-source.md).

## Table of contents

* [Getting started](#getting-started)
  * [Basic usage](#basic-usage)
  * [Data source](#data-source)
  * [Infinite data source](#infinite-data-source)
  * [Selecting items](#selecting-items)
  * [Reloading data](#reloading-data)
  * [Delegate](#delegate)
  * [Size delegate](#size-delegate)
  * [Selecting items](#selecting-items)
* [Customization](#customization)
* [Installation](#installation)
* [Acknowledgements](#acknowledgements)
* [Changelog](#changelog)
* [Licence](#licence)

## Getting started

### Basic usage

Parchment is built around the `PagingViewController` class. You can initialize it with an array of view controllers and it will display menu items for each view controller using their `title` property.

```Swift
let firstViewController = UIViewController()
let secondViewController = UIViewController()

let pagingViewController = PagingViewController(viewControllers: [
  firstViewController,
  secondViewController
])
```

See more: [Basic usage](/Documentation/basic-usage.md)

### Data source

Initializing `PagingViewController` with an array of view controllers is fine in most cases, but if you have more than a few view controllers you probably don't want to allocate them all up-front. If you're going to display a fixed number of view controllers, you can setup your own data source by implementing `PagingViewControllerDataSource`:

```Swift
extension ViewController: PagingViewControllerDataSource {
    func numberOfViewControllers(in pagingViewController: PagingViewController) -> Int {
        return 10
    }

    func pagingViewController(_ pagingViewController: PagingViewController, viewControllerAt index: Int) -> UIViewController {
        return ChildViewController(index: index)
    }

    func pagingViewController(_: PagingViewController, pagingItemAt index: Int) -> PagingItem {
        return PagingTitleItem(title: "View \(index)", index: index)
    }
}
```

Then you need to set the `dataSource` property and select the initial item:

```Swift
let pagingViewController = PagingViewController()
pagingViewController.dataSource = self
pagingViewController.select(index: 0)
```

Using the data source means Parchment will only allocate view controllers for the currently selected item and any of its siblings. This is a lot more memory efficient than using `PagingViewController(viewControllers:)` if you have many view controllers.

Read more: [Using the data source](/Documentation/data-source.md)

### Infinite data source

Using `PagingViewControllerDataSource` means you need to know how many view controllers to display. If you’re creating something like a [calendar](), the number of view controllers can be infinitely large. In that case you can use the `PagingViewControllerInfiniteDataSource` protocol:

```Swift
extension ViewController: PagingViewControllerInfiniteDataSource {
    func pagingViewController(_: PagingViewController, viewControllerFor pagingItem: PagingItem) -> UIViewController {
        return ItemViewController(item: pagingItem)
    }

    func pagingViewController(_: PagingViewController, itemBefore pagingItem: PagingItem) -> PagingItem? {
        guard let item = pagingItem as? Item else { return nil }
        return Item(index: item.index - 1)
    }

    func pagingViewController(_ : PagingViewController, itemAfter pagingItem: PagingItem) -> PagingItem? {
        guard let item = pagingItem as? Item else { return nil }
        return Item(index: item.index + 1)
    }
}
```

Then set the `infiniteDataSource` property and select the initial item:

```Swift
let pagingViewController = PagingViewController()
pagingViewController.infiniteDataSource = self
pagingViewController.select(pagingItem: Item(index: 0))
```

This pattern is very similar to the
[UIPageViewControllerDataSource](https://developer.apple.com/library/ios/documentation/UIKit/Reference/UIPageViewControllerClassReferenceClassRef/)
protocol. The main difference is that instead of returning view controllers directly, you have to return an instance conforming to the `PagingItem` protocol. Parchment will recursively call these methods for the selected `PagingItem` until the available space is filled up.

Read more: [Using the infinite data source](/Documentation/infinite-data-source.md)

### Selecting items

You can select items programatically using:

```Swift
func select(pagingItem: PagingItem, animated: Bool = false)
```

Let’s say you want to select the first item:

```Swift
override func viewDidLoad() {
  super.viewDidLoad()
  if let first = pagingViewController.items.first {
    pagingViewController.select(pagingItem: first)
  }
}
```

Or if you have set the `dateSource` property, you can select items based on their index:

```Swift
func select(index: Int, animated: Bool = false)
```

### Reloading data

You can reload data using this method:

```Swift
func reloadData()
```

This will keep the previously selected item if it's still part of the
updated data. If not, it will select the first item in the list. It
will also reload the view controllers displayed in the page view
controller. If you only want to reload the menu items, you can use
this method:

```Swift
func reloadMenu()
```

Calling `reloadData()` will not work when using
`PagingViewControllerInfiniteDataSource`, as we then need to know what
the initial item should be. In that case you should use this method:

```Swift
func reloadData(around: PagingItem)
```

This will mark the given paging item as selected and generate new items around it.

### Delegate

Parchment provides delegate methods for every step of the transition process through the `PagingViewControllerDelegate` protocol.

```Swift
protocol PagingViewControllerDelegate: class {

    func pagingViewController(
        _: PagingViewController,
        isScrollingFromItem currentPagingItem: PagingItem,
        toItem upcomingPagingItem: PagingItem?,
        startingViewController: UIViewController,
        destinationViewController: UIViewController?,
        progress: CGFloat)

    func pagingViewController(
        _: PagingViewController,
        willScrollToItem pagingItem: PagingItem,
        startingViewController: UIViewController,
        destinationViewController: UIViewController)

    func pagingViewController(
        _ pagingViewController: PagingViewController,
        didScrollToItem pagingItem: PagingItem,
        startingViewController: UIViewController?,
        destinationViewController: UIViewController,
        transitionSuccessful: Bool)
}
```

### Size delegate

By default, the size of the menu items is controlled by the `menuItemSize` property. If you need to control width of each menu item individually you can use the `PagingControllerSizeDelegate` protocol:

```Swift
protocol PagingViewControllerSizeDelegate: class {
    func pagingViewController(
        _: PagingViewController,
        widthForPagingItem pagingItem: PagingItem,
        isSelected: Bool) -> CGFloat
}
```

Then set the `sizeDelegate` on the `PagingViewController`:

```Swift
let pagingViewController = PagingViewController()
pagingViewController.sizeDelegate = self
```

## Customization

Parchment is built to be very flexible. The menu items are displayed using UICollectionView, so they can display pretty much whatever you want. If you need any further customization you can even subclass the collection view layout. All customization is handled by the properties listed below. 

### Custom cells

To use custom cells you need to subclass `PagingCell` and register the cell type for a given `PagingItem`:

```Swift
let pagingViewController = PagingViewController()
pagingViewController.register(CalendarPagingCell.self, for: CalendarItem.self)
```

Parchment will then dequeue your custom cell when you return the given `PagingItem` in your data source. You can register multiple cell types for different `PagingItem`s.

### Properties

All customization properties are set on `PagingViewController`:

```Swift
let pagingViewController = PagingViewController()
pagingViewController.menuItemSize = .fixed(width: 40, height: 40)
pagingViewController.menuItemSpacing = 10
```

#### `menuItemSize`

The size of the menu items. When using [`sizeDelegate`](#size-delegate) the width will be ignored.

```Swift
enum PagingMenuItemSize {
  case fixed(width: CGFloat, height: CGFloat)

  // Tries to fit all menu items inside the bounds of the screen.
  // If the items can't fit, the items will scroll as normal and
  // set the menu items width to `minWidth`.
  case sizeToFit(minWidth: CGFloat, height: CGFloat)
}
```

_Default: `.sizeToFit(minWidth: 150, height: 40)`_

#### `menuItemSpacing`

The spacing between the menu items.

_Default: `0`_

#### `menuInsets`

The insets around all of the menu items.

_Default: `UIEdgeInsets()`_

#### `menuHorizontalAlignment`

```Swift
enum PagingMenuHorizontalAlignment {
  case `default`

  // Allows all paging items to be centered within the paging menu
  // when PagingMenuItemSize is .fixed and the sum of the widths
  // of all the paging items are less than the paging menu
  case center
}
```

_Default: `.default`_

#### `menuTransition`

Determine the transition behaviour of menu items while scrolling the content.

```Swift
enum PagingMenuTransition {
  // Update scroll offset based on how much the content has
  // scrolled. Makes the menu items transition smoothly as you scroll.
  case scrollAlongside

  // Animate the menu item position after a transition has completed.
  case animateAfter
}
```

_Default: `.scrollAlongside`_

#### `menuInteraction`

Determine how users can interact with the menu items.

```Swift
enum PagingMenuInteraction {
  case scrolling
  case swipe
  case none
}
```

_Default: `.scrolling`_

#### `menuLayoutClass`

The class type for collection view layout. Override this if you want to use your own subclass of the layout. Setting this property will initialize the new layout type and update the collection view.

_Default: `PagingCollectionViewLayout.Type`_

#### `selectedScrollPosition`

Determine how the selected menu item should be aligned when it is selected. Effectively the same as the `UICollectionViewScrollPosition`.

```Swift
enum PagingSelectedScrollPosition {
  case left
  case right

  // Centers the selected menu item where possible. If the item is
  // to the far left or right, it will not update the scroll position.
  // Effectivly the same as .centeredHorizontally on UIScrollView.
  case preferCentered
}
```

_Default: `.preferCentered`_

#### `indicatorOptions`

Add an indicator view to the selected menu item. The indicator width will be equal to the selected menu items width. Insets only apply horizontally.

```Swift
enum PagingIndicatorOptions {
  case hidden
  case visible(
    height: CGFloat,
    zIndex: Int,
    spacing: UIEdgeInsets,
    insets: UIEdgeInsets)
}
```

_Default:_

```Swift
.visible(
  height: 4,
  zIndex: Int.max,
  spacing: UIEdgeInsets.zero,
  insets: UIEdgeInsets(top: 0, left: 8, bottom: 0, right: 8))
```

#### `indicatorClass`

The class type for the indicator view. Override this if you want your use your own subclass of `PagingIndicatorView`.

_Default: `PagingIndicatorView.self`_

#### `indicatorColor`

The background color for the indicator view.

_Default: `UIColor(red: 3/255, green: 125/255, blue: 233/255, alpha: 1)`_

#### `borderOptions`

Add a border at the bottom of the menu items. The border will be as wide as all the menu items. Insets only apply horizontally.

```Swift
enum PagingBorderOptions {
  case hidden
  case visible(
    height: CGFloat,
    zIndex: Int,
    insets: UIEdgeInsets)
}
```

_Default:_

```Swift
.visible(
  height: 1,
  zIndex: Int.max - 1,
  insets: UIEdgeInsets(top: 0, left: 8, bottom: 0, right: 8))
```

#### `borderClass`

The class type for the border view. Override this if you want your use your own subclass of `PagingBorderView`.

_Default: `PagingBorderView.self`_

#### `borderColor`

The background color for the border view.

_Default: `UIColor(white: 0.9, alpha: 1)`_

#### `includeSafeAreaInsets`

Updates the content inset for the menu items based on the `.safeAreaInsets` property.

_Default: `true`_

#### `font`

The font used for title label on the menu items.

_Default: `UIFont.systemFont(ofSize: 15, weight: UIFont.Weight.medium)`_

#### `selectedFont`

The font used for title label on the currently selected menu item.

_Default: `UIFont.systemFont(ofSize: 15, weight: UIFont.Weight.medium)`_

#### `textColor`

The color of the title label on the menu items.

_Default: `UIColor.black`_

#### `selectedTextColor`

The text color for the currently selected menu item.

_Default: `UIColor(red: 3/255, green: 125/255, blue: 233/255, alpha: 1)`_

#### `backgroundColor`

The background color for the menu items.

_Default: `UIColor.white`_

#### `selectedBackgroundColor`

The background color for the selected menu item.

_Default: `UIColor.clear`_

#### `menuBackgroundColor`

The background color for the view behind the menu items.

_Default: `UIColor.white`_

## Installation

Parchment will be compatible with the lastest public release of Swift.

### Requirements

* iOS 8.2+
* Xcode 8.0+

### CocoaPods

Parchment is available through [CocoaPods](https://cocoapods.org). To install it, add the following to your `Podfile`:

```
pod 'Parchment'
```

### Swift Package Manager

Parchment is available through [Swift Package Manager](https://swift.org/package-manager/). Add Parchment as a dependency to your `Package.swift`:

```Swift
.package(url: "https://github.com/rechsteiner/Parchment", from: "2.0.0")
```

### Carthage

Parchment also supports [Carthage](https://github.com/Carthage/Carthage). To install it, you need to do the following steps:

1. Add `github "rechsteiner/Parchment"` to your `Cartfile`
2. Run `carthage update`
3. Link `Parchment.framework` with you target
4. Add `$(SRCROOT)/Carthage/Build/iOS/Parchment.framework` to your
   `copy-frameworks` script phase

See [this guide](https://github.com/Carthage/Carthage#adding-frameworks-to-an-application) for more details on using Carthage.

## Acknowledgements

* Parchment uses [`EMPageViewController`](https://github.com/emalyak/EMPageViewController) as a replacement for `UIPageViewController`.

## Changelog

This can be found in the [CHANGELOG](/CHANGELOG.md) file.

## Licence

Parchment is released under the MIT license. See [LICENSE](/LICENSE.md) for details.

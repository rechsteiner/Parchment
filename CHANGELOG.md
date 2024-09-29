# Changelog

`Parchment` adheres to [Semantic Versioning](http://semver.org/).

## [4.1.0](https://github.com/rechsteiner/Parchment/compare/v4.0.0...v4.1.0) - 2024-09-29

### Changes

- Enable Swift 6 mode #723

## [4.0.0](https://github.com/rechsteiner/Parchment/compare/v3.4.0...v4.0.0) - 2024-05-25

Version 4.0 introduced a new and improved API for PageView in SwiftUI. Each page can now show define their own menu items, which can be any SwiftUI view. The new API also supports result builders, which allows you to easily setup your PageView.

```swift
PageView {
    Page("Title 1") {
        Text("Page 1")
    }
    Page { _ in
        Image(systemName: "star.fill")
    } content: {
        Text("Page 2")
    }
}
```

## Changes

- New API for PageView in SwiftUI #666
- Updated minimum deployment target to iOS 11 #661
- Constrain menu to safe area insets by default #668

## Added

- Add support for custom SwiftUI styles for indicator views #684
- Add horizontal right alignment support #658
- Add missing color modifiers to PageView #675
- Add new PagingIndexable protocol to allow comparison between items #678

## Fixes

- Fix PageViewController isScrollingFrom delegate when overshooting #669
- Fix didSelectItem delegate being called before actual selection #676
- Fix setting PageView closures multiple times #677
- Fix rotation and crash issues with calling layoutIfNeeded #680
- Fix options not propagating changes when SwiftUI view is updated #697

## [3.4.0](https://github.com/rechsteiner/Parchment/compare/v3.3.0...v3.4.0) - 2024-04-14

- Update Swift version to 5.10 #705

## [3.3.0](https://github.com/rechsteiner/Parchment/compare/v3.2.1...v3.3.0) - 2024-02-17

- Set minimum deployment target to iOS 12 #699
- Add privacy manifest file #695
- Update Swift version to 5.9 #700

## [3.2.1](https://github.com/rechsteiner/Parchment/compare/v3.2.0...v3.2.1) - 2023-03-07

### Fixes

- Fix issue with unsafe flags when using SwiftPM #662

## [3.2.0](https://github.com/rechsteiner/Parchment/compare/v3.1.0...v3.2.0) - 2022-01-23

### Fixes

- Fix issue with menu insets not updating #619
- Update content size after parent size #623
- Fix SPM linker settings #622 #615
- Update Pods file to support iOS >= 9 #620

## [3.1.0](https://github.com/rechsteiner/Parchment/compare/v3.0.1...v3.1.0) - 2021-10-16

### Added

- Add support for `pagingContentBackgroundColor` property #592
- Add `contentInteraction` property into `PagingOptions` #593

### Changes

- Support for Xcode 13 #581 #601
- Updated API for SwiftUI wrapper #572 #551
- Drop support for iOS 8 #568
- Remove support for older Swift versions #595
- Improve accessibility of default paging cell #602

### Fixes

- Remove Carthage reference in FRAMEWORK_SEARCH_PATH #569
- Fix wrong page direction when current paging item is out of view #567
- Fix issue with rotation when using SwiftUI wrapper #596

## [3.0.1](https://github.com/rechsteiner/Parchment/compare/v3.0.0...v3.0.1) - 2020-12-15

### Fixes

- Fix layout issue in PageViewController #543
- Fix crash when using UIColor(patternImage:) #544

## [3.0.0](https://github.com/rechsteiner/Parchment/compare/v2.4.0...v3.0.0) - 2020-12-03

### Changes

- Custom PageViewController (#468)
- RTL language support (#468)

## [2.4.0](https://github.com/rechsteiner/Parchment/compare/v2.3.0...v2.4.0) - 2020-01-06

### Fixes

- Fix PagingTitleCell label horizontal constraints (#480)
- Fix regression causing menuInteraction property not to work properly (#486)
- Reload data when updating paging items in SwiftUI (#470)

## [2.3.0](https://github.com/rechsteiner/Parchment/compare/v2.2.0...v2.3.0) - 2020-02-04

### Added

- Add support for SwiftUI (#460)
- Add support for self-sizing menu cells (#461)

### Fixes

- Handle menu background color change after viewDidLoad (#465)

## [2.2.0](https://github.com/rechsteiner/Parchment/compare/v2.1.0...v2.2.0) - 2020-21-03

### Added

- Add delegate method when selecting item (#450)

### Changes

- Update menu constraints when menuItemSize changes (#449)

## [2.1.0](https://github.com/rechsteiner/Parchment/compare/v2.0.1...v2.1.0) - 2020-11-03

### Changes

- Add option to position menu vertically (#412)
- Combine all example targets into single target (#442)

### Fixes

- Fix missing import causing SwiftPM to fail (#420)
- Fix memory leak occurring when configuring size cache (#433)
- Fix issue with initial selection not being set (#438)
- Fix regression causing indicator not to animate (#441)
- Fix issues with invalidation of size cache (#444)

## [2.0.1](https://github.com/rechsteiner/Parchment/compare/v2.0.0...v2.0.1) - 2020-08-02

### Fixes

- Remove unused `FixedPagingViewController` file to fix xcodebuild.

## [2.0.0](https://github.com/rechsteiner/Parchment/compare/v1.7.0...v2.0.0) - 2020-08-02

See releases for more details: [https://github.com/rechsteiner/Parchment/releases/tag/v2.0.0]()

### Changes

- Removed `FixedPagingViewController`
- Removed generics (#285)
- Moved size delegate into separate protocol
- Replaced `menuItemSource` with `register(cellClass:)`
- Updated naming of data sources

## [1.7.0](https://github.com/rechsteiner/Parchment/compare/v1.6.0...v1.7.0) - 2019-26-09

### Fixes

- Update to Swift 5 and Xcode 10.2 #339
- Fix issue changing selection when view is not visible #371
- Fix unbalanced appearance transitions #373
- Fix issues when compiled as SPM dependency (Xcode 11) (#386)

### Added

- Add support for Accio as dependency manager #345

## [1.6.0](https://github.com/rechsteiner/Parchment/compare/v1.5.0...v1.6.0) - 2019-03-03

### Fixes

- Forward appearance methods from EMPageViewController #306
- Fix indicator insets with only one item #307

### Added

- Add method for reloading menu #312

## [1.5.0](https://github.com/rechsteiner/Parchment/compare/v1.4.1...v1.5.0) - 2018-11-18

### Fixes

- Include vertical insets for indicator view #271
- Remove development team from Parchment target #280
- Update indicator and border views when changing options #245
- Fix issue with width delegate not being called #244
- Fix issue with invalidating collection view layout #240

## [1.4.1](https://github.com/rechsteiner/Parchment/compare/v1.4.0...v1.4.1) - 2018-08-15

### Fixes

- Fix issue with reloadData causing a crash #230

## [1.4.0](https://github.com/rechsteiner/Parchment/compare/v1.3.0...v1.4.0) - 2018-08-11

### Changes

- Upgrade to Swift 4.2 #228

### Added

- Add option for registering cells from NIB #227

## [1.3.0](https://github.com/rechsteiner/Parchment/compare/v1.2.0...v1.3.0) - 2018-05-19

### Changes

- Add version checks to support Swift >=3.2 #190, #184

### Fixes

- Fix issue with indicator/border class was not registered #191
- Fix issue with reloading data when view controllers did not change #201

## [1.2.0](https://github.com/rechsteiner/Parchment/compare/v1.1.0...v1.2.0) - 2018-04-15

### Changes

- Upgrade to Swift 4.1 #171
- Prevent unnecessary view controller initializations #160

### Fixes

- Fix issues with reloading data #157
- Fix issue with clearing all items in page view controller (a5759ba)
- Fix issue where willScrollToItem delegate was not called #173
- Fix layout bug with cell heights when using width delegate #155

## [1.1.0](https://github.com/rechsteiner/Parchment/compare/v1.0.3...v1.1.0) - 2018-03-25

### Added

- Add method for reloading data without passing initial item (8ebd931)
- Add option for selected font #143

### Fixes

- Fix issue with reloading data when using PagingViewControllerDataSource (07641e2)
- Fix integer overflow causing crash in UnplashExample #140

## [1.0.3](https://github.com/rechsteiner/Parchment/compare/v1.0.2...v1.0.3) - 2018-03-01

### Fixes

- Fix issue where size delegate was not called #135

## [1.0.2](https://github.com/rechsteiner/Parchment/compare/v1.0.1...v1.0.2) - 2018-02-22

### Changes

- Update default background color for menu items #131

## [1.0.1](https://github.com/rechsteiner/Parchment/compare/v1.0.0...v1.0.1) - 2018-02-03

### Fixes

- Fix issue with selecting items programatically #125
- Fix wrong color on collection view background #126
- Fix issue with menu items being clipped #127

## [1.0.0](https://github.com/rechsteiner/Parchment/compare/v0.9.0...v1.0.0) - 2018-01-29

This release introduces a lot of breaking changes, a bunch of new features and a couple of bug fixes. Here are the most notable changes, with a full list of changes below.

### Removed `PagingOptions` initializer #98

All configuration is now moved into properties on the `PagingViewController` class. You no longer have to initialize a `PagingViewController` with an instance conforming to the `PagingOptions` protocol. This reduces the boilerplate of having to create a separate options struct when you just need to override a single value. It also means you can change the options after the `PagingViewController` has been initialized. All the properties on the `PagingTheme` protocol has also moved into separate properties on `PagingViewController`.

**Before:**

```Swift
struct Theme: PagingTheme {
  let textColor: UIColor = .red
}

struct Options: PagingOptions {
  let theme: PagingTheme = Theme()
  let menuItemSize: PagingMenuItemSize = .fixed(width: 100, height: 40)
}

let pagingViewController = PagingViewController(options: Options())
```

**After:**

```Swift
let pagingViewController = PagingViewController()
pagingViewController.menuItemSize = .fixed(width: 100, height: 40)
pagingViewController.textColor = .red
```

### Renamed data source #99

The current data source protocol has been renamed to `PagingViewControllerInfiniteDataSource` and moved into the property called `infiniteDataSource`.

### Added new data source #99

A new `PagingViewControllerDataSource` protocol has been added that makes it easier to set up a custom data source if you have a fixed number of view controllers. To use the new data source, you only need to return the total number of
view controllers as well as the view controller and `PagingItem` for a given index. The new data source replaces the existing `dataSource` property.

**Example:**

```Swift
extension ViewController: PagingViewControllerDataSource {

  func numberOfViewControllers<T>(in: PagingViewController<T>) -> Int {
    return items.count
  }

  func pagingViewController<T>(_ pagingViewController: PagingViewController<T>, viewControllerForIndex index: Int) -> UIViewController {
    return ItemViewController(item: items[index])
  }

  func pagingViewController<T>(_ pagingViewController: PagingViewController<T>, pagingItemForIndex index: Int) -> T {
    return items[index] as! T
  }
}

...

pagingViewController.dataSource = self
```

### Updated delegate protocol #100

Three new delegate methods have been added to the `PagingViewControllerDelegate` protocol. You can now be notified before, during and after the user navigates to another view controller:

```Swift
protocol PagingViewControllerDelegate: class {

  func pagingViewController<T>(
    _ pagingViewController: PagingViewController<T>,
    isScrollingFromItem currentPagingItem: T,
    toItem upcomingPagingItem: T?,
    startingViewController: UIViewController,
    destinationViewController: UIViewController?,
    progress: CGFloat)

  func pagingViewController<T>(
    _ pagingViewController: PagingViewController<T>,
    willScrollToItem pagingItem: T,
    startingViewController: UIViewController,
    destinationViewController: UIViewController)

  func pagingViewController<T>(
    _ pagingViewController: PagingViewController<T>,
    didScrollToItem pagingItem: T,
    startingViewController: UIViewController?,
    destinationViewController: UIViewController,
    transitionSuccessful: Bool)

  func pagingViewController<T>(
    _ pagingViewController: PagingViewController<T>,
    widthForPagingItem pagingItem: T,
    isSelected: Bool) -> CGFloat?
}
```

The `widthForPagingItem:` delegate has been changed to return `CGFloat?` instead of `CGFloat` (See: #100). The default implementation will return nil.

### Removed `FixedPagingViewControllerDelegate` protocol #100

The `FixedPagingViewControllerDelegate` protocol is replaced by the `PagingViewControllerDelegate` protocol. The new delegate does not include the index for the paging items, but you can get the current index from the `PagingIndexItem` like this:

```Swift
extension ViewController: PagingViewControllerDelegate {
  func pagingViewController<T>(_ pagingViewController: PagingViewController<T>, didScrollToItem pagingItem: T, startingViewController: UIViewController?, destinationViewController: UIViewController, transitionSuccessful: Bool) {
    if let indexItem = pagingItem as? PagingIndexItem {
      print("index: ", indexItem.index)
    }
  }
}
```

### Added

- Add option to always center selected menu item #101
- Allow subclassing the collection view layout #104
- Add empty implementations of collection view delegate methods (4840483)
- Add option to disable content interaction #113
- Add option for selected background color #114
- Add method for selecting paging items based on index #117

### Changed

- Rename selectPagingItem to select(pagingItem:) #105
- Make PagingState property public #107
- Make PagingItems struct public #108
- Make PagingState extension properties public (f842a7b)
- Make indicator layout attributes open to allow subclassing (7c35acc)
- Change collection view delegate methods to open (68b125b)
- Replace PagingTheme with PagingOptions #111
- Rename `headerBackgroundColor` to `menuBackgroundColor` #116

### Fixes

- Fix performance issue with updating content offset #106
- Set background color for paging cell based on options (1a70bd6)
- Fix layout calculation when using transforms #102
- Account for menu spacing when generating items #103
- Fix bug with animation when selecting items (73913f)

## [0.9.0](https://github.com/rechsteiner/Parchment/compare/v0.8.0...v0.9.0) - 2017-12-25

### Added

- Add method for reloading data #94
- Allow setting different width for selected cell #85

## [0.8.0](https://github.com/rechsteiner/Parchment/compare/v0.7.0...v0.8.0) - 2017-11-19

### Fixes

- Fix selecting paging items before view appears #79
- Fix issues with safe area insets #81

## [0.7.0](https://github.com/rechsteiner/Parchment/compare/v0.6.0...v0.7.0) - 2017-11-07

### Changes

- Change access for EMPageViewController delegate method #72
- Improve performance by using manual frames for menu cells #68
- Add option to customize indicator and border view #67
- Update documentation #60

## [0.6.0](https://github.com/rechsteiner/Parchment/compare/v0.5.0...v0.6.0) - 2017-09-25

### Changes

- Upgrade to Swift 4.0 #54

### Fixes

- Fix bug where selecting items was not working #55

## [0.5.0](https://github.com/rechsteiner/Parchment/compare/v0.4.0...v0.5.0) - 2017-08-22

### Added

- Add support for scrolling in header #48

### Changes

- Require `PagingItem` to conform to `Hashable` and `Comparable`:
  [fbd7aff](https://github.com/rechsteiner/Parchment/pull/48/commits/fbd7aff8c1e3ac17dad8644961d073dc49da6a1e)
- Use custom collection view layout instead of using
  `UICollectionViewFlowLayout`
  [c6f78b4](https://github.com/rechsteiner/Parchment/pull/48/commits/c6f78b4521c4cae56050316ae3ec3ac72fe895ba)

## [0.4.0](https://github.com/rechsteiner/Parchment/compare/v0.3.0...v0.4.0) - 2017-05-04

### Added

- Add delegate for selected items in FixedPagingViewController #46

### Fixes

- Fix issue with delayed rendering #45

## [0.3.0](https://github.com/rechsteiner/Parchment/compare/v0.2.0...v0.3.0) - 2017-03-12

### Changes

- Allow selectPagingItem to be called before viewDidAppear #32
- Move collection view above paging view #31

### Fixes

- Fixes for EMPageViewController #36
- Fix calculation for transition distance #33
- Fix background color on header view #41

## [0.2.0](https://github.com/rechsteiner/Parchment/compare/v0.1.2...v0.2.0) - 2017-02-19

### Added

- Add progress value to menu items: #20
- Scroll menu items alongside content: #22
- Option to add spacing to indicator: #27
- Add new icons example project
- Add example for loading view controllers from storyboard

## [0.1.2](https://github.com/rechsteiner/Parchment/compare/v0.1.1...v0.1.2) - 2016-12-08

### Changes

- Update to Swift 3.0 #11
- Update public accessors
  [1f057a9](https://github.com/rechsteiner/Parchment/commit/1f057a94dc8e204343eeb78b9be6f516e1a6af15)

### Fixes

- Account for menuInsets when using sizeToFit #8
- Add support for centering fixed width menu items #10

## [0.1.1](https://github.com/rechsteiner/Parchment/compare/v0.1.0...v0.1.1) - 2016-05-22

### Changes

- Add MIT license #4

## [0.1.0](https://github.com/rechsteiner/Parchment/compare/0ad346e...v0.1.0) - 2016-05-22

- Inital release

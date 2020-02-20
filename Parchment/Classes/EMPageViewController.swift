/*

  EMPageViewController.swift

  Copyright (c) 2015-2019 Erik Malyak

  Permission is hereby granted, free of charge, to any person obtaining a copy
  of this software and associated documentation files (the "Software"), to deal
  in the Software without restriction, including without limitation the rights
  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
  copies of the Software, and to permit persons to whom the Software is
  furnished to do so, subject to the following conditions:

  The above copyright notice and this permission notice shall be included in all
  copies or substantial portions of the Software.

  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
  SOFTWARE.

*/

import UIKit

/**
    The `EMPageViewControllerDataSource` protocol is adopted to provide the view controllers that are displayed when the user scrolls through pages. Methods are called on an as-needed basis.

    Each method returns a `UIViewController` object or `nil` if there are no view controllers to be displayed.

    - note: If the data source is `nil`, gesture based scrolling will be disabled and all view controllers must be provided through `selectViewController:direction:animated:completion:`.
*/
@objc public protocol EMPageViewControllerDataSource {
    
    /**
        Called to optionally return a view controller that is to the left of a given view controller in a horizontal orientation, or above a given view controller in a vertical orientation.
        
        - parameter pageViewController: The page view controller
        - parameter viewController: The point of reference view controller
        
        - returns: The view controller that is to the left of the given `viewController` in a horizontal orientation, or above the given `viewController` in a vertical orientation, or `nil` if there is no view controller to be displayed.
    */
    func em_pageViewController(_ pageViewController: EMPageViewController, viewControllerBeforeViewController viewController: UIViewController) -> UIViewController?
    
    /**
        Called to optionally return a view controller that is to the right of a given view controller.

        - parameter pageViewController: The page view controller
        - parameter viewController: The point of reference view controller
     
        - returns: The view controller that is to the right of the given `viewController` in a horizontal orientation, or below the given `viewController` in a vertical orientation, or `nil` if there is no view controller to be displayed.
    */
    func em_pageViewController(_ pageViewController: EMPageViewController, viewControllerAfterViewController viewController: UIViewController) -> UIViewController?
}

/**
    The EMPageViewControllerDelegate protocol is adopted to receive messages for all important events of the page transition process.
*/
@objc public protocol EMPageViewControllerDelegate {
    
    /**
        Called before scrolling to a new view controller.

        - note: This method will not be called if the starting view controller is `nil`. A common scenario where this will occur is when you initialize the page view controller and use `selectViewController:direction:animated:completion:` to load the first selected view controller.

        - important: If bouncing is enabled, it is possible this method will be called more than once for one page transition. It can be called before the initial scroll to the destination view controller (which is when it is usually called), and it can also be called when the scroll momentum carries over slightly to the view controller after the original destination view controller.

        - parameter pageViewController: The page view controller
        - parameter startingViewController: The currently selected view controller the transition is starting from
        - parameter destinationViewController: The view controller that will be scrolled to, where the transition should end
     */
    @objc optional func em_pageViewController(_ pageViewController: EMPageViewController, willStartScrollingFrom startingViewController: UIViewController, destinationViewController:UIViewController)
    
    /**
        Called whenever there has been a scroll position change in a page transition. This method is very useful if you need to know the exact progress of the page transition animation.

        - note: This method will not be called if the starting view controller is `nil`. A common scenario where this will occur is when you initialize the page view controller and use `selectViewController:direction:animated:completion:` to load the first selected view controller.

        - parameter pageViewController: The page view controller
        - parameter startingViewController: The currently selected view controller the transition is starting from
        - parameter destinationViewController: The view controller being scrolled to where the transition should end
        - parameter progress: The progress of the transition, where 0 is a neutral scroll position, >= 1 is a complete transition to the right view controller in a horizontal orientation, or the below view controller in a vertical orientation, and <= -1 is a complete transition to the left view controller in a horizontal orientation, or the above view controller in a vertical orientation. Values may be greater than 1 or less than -1 if bouncing is enabled and the scroll velocity is quick enough.
    */
    @objc optional func em_pageViewController(_ pageViewController: EMPageViewController, isScrollingFrom startingViewController: UIViewController, destinationViewController:UIViewController, progress: CGFloat)
    
    /**
        Called after a page transition attempt has completed.
     
        - important: If bouncing is enabled, it is possible this method will be called more than once for one page transition. It can be called after the scroll transition to the intended destination view controller (which is when it is usually called), and it can also be called when the scroll momentum carries over slightly to the view controller after the intended destination view controller. In the latter scenario, `transitionSuccessful` will return `false` the second time it's called because the scroll view will bounce back to the intended destination view controller.

        - parameter pageViewController: The page view controller
        - parameter startingViewController: The currently selected view controller the transition is starting from
        - parameter destinationViewController: The view controller that has been attempted to be selected
        - parameter transitionSuccessful: A Boolean whether the transition to the destination view controller was successful or not. If `true`, the new selected view controller is `destinationViewController`. If `false`, the transition returned to the view controller it started from, so the selected view controller is still `startingViewController`.
    */
    @objc optional func em_pageViewController(_ pageViewController: EMPageViewController, didFinishScrollingFrom startingViewController: UIViewController?, destinationViewController:UIViewController, transitionSuccessful: Bool)
}

/**
    The navigation scroll direction.
*/
@objc public enum EMPageViewControllerNavigationDirection : Int {
    /// Forward direction. Can be right in a horizontal orientation or down in a vertical orientation.
    case forward
    /// Reverse direction. Can be left in a horizontal orientation or up in a vertical orientation.
    case reverse
}

/**
    The navigation scroll orientation.
*/
@objc public enum EMPageViewControllerNavigationOrientation: Int {
    /// Horiziontal orientation. Scrolls left and right.
    case horizontal
    /// Vertical orientation. Scrolls up and down.
    case vertical
}

/// Manages page navigation between view controllers. View controllers can be navigated via swiping gestures, or called programmatically.
open class EMPageViewController: UIViewController, UIScrollViewDelegate {
    
    /// The object that provides view controllers on an as-needed basis throughout the navigation of the page view controller.
    ///
    /// If the data source is `nil`, gesture based scrolling will be disabled and all view controllers must be provided through `selectViewController:direction:animated:completion:`.
    ///
    /// - important: If you are using a data source, make sure you set `dataSource` before calling `selectViewController:direction:animated:completion:`.
    @objc open weak var dataSource: EMPageViewControllerDataSource?
    
    /// The object that receives messages throughout the navigation process of the page view controller.
    @objc open weak var delegate: EMPageViewControllerDelegate?
    
    /// The direction scrolling navigation occurs
    open private(set) var navigationOrientation: EMPageViewControllerNavigationOrientation = .horizontal
    
    private var isOrientationHorizontal: Bool {
        return self.navigationOrientation == .horizontal
    }

    /// The underlying `UIScrollView` responsible for scrolling page views.
    /// - important: Properties should be set with caution to prevent unexpected behavior.
    open private(set) lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.isPagingEnabled = true
        scrollView.scrollsToTop = false
        scrollView.autoresizingMask = [.flexibleTopMargin, .flexibleRightMargin, .flexibleBottomMargin, .flexibleLeftMargin]
        scrollView.bounces = true
        scrollView.alwaysBounceHorizontal = self.isOrientationHorizontal
        scrollView.alwaysBounceVertical = !self.isOrientationHorizontal
        scrollView.translatesAutoresizingMaskIntoConstraints = true
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.showsVerticalScrollIndicator = false
        return scrollView
    }()
    
    /// The view controller before the selected view controller.
    @objc open private(set) var beforeViewController: UIViewController?
    
    /// The currently selected view controller. Can be `nil` if no view controller is selected.
    @objc open private(set) var selectedViewController: UIViewController?
    
    /// The view controller after the selected view controller.
    @objc open private(set) var afterViewController: UIViewController?
    
    /// Boolean that indicates whether the page controller is currently in the process of scrolling.
    @objc open private(set) var scrolling = false
    
    /// The direction the page controller is scrolling towards.
    open private(set) var navigationDirection: EMPageViewControllerNavigationDirection?
    
    private var adjustingContentOffset = false // Flag used to prevent isScrolling delegate when shifting scrollView
    private var loadNewAdjoiningViewControllersOnFinish = false
    private var didFinishScrollingCompletionHandler: ((_ transitionSuccessful: Bool) -> Void)?
    private var transitionAnimated = false // Used for accurate view appearance messages
    private var viewHasAppeared = false // Used to track if viewDidAppear has been called
    
    // MARK: - Public Methods
    
    /// Initializes a newly created page view controller with the specified navigation orientation.
    /// - parameter navigationOrientation: The page view controller's navigation scroll direction.
    /// - returns: The initialized page view controller.
    public convenience init(navigationOrientation: EMPageViewControllerNavigationOrientation) {
        self.init()
        self.navigationOrientation = navigationOrientation
    }
    
    /**
        Sets the view controller that will be selected after the animation. This method is also used to provide the first view controller that will be selected in the page view controller.

        If a data source has been set, the view controllers before and after the selected view controller will also be loaded but not appear yet.

        - important: If you are using a data source, make sure you set `dataSource` before calling `selectViewController:direction:animated:completion:`

        - parameter viewController: The view controller to be selected.
        - parameter direction: The direction of the navigation and animation, if applicable.
        - parameter completion: A block that's called after the transition is finished. The block parameter `transitionSuccessful` is `true` if the transition to the selected view controller was completed successfully.
    */
    @objc open func selectViewController(_ viewController: UIViewController, direction: EMPageViewControllerNavigationDirection, animated: Bool, completion: ((_ transitionSuccessful: Bool) -> Void)?) {
        guard self.selectedViewController != viewController else { return }
        
        if (direction == .forward) {
            self.afterViewController = viewController
            self.layoutViews()
            self.loadNewAdjoiningViewControllersOnFinish = true
            self.scrollForward(animated: animated, completion: completion)
        } else if (direction == .reverse) {
            self.beforeViewController = viewController
            self.layoutViews()
            self.loadNewAdjoiningViewControllersOnFinish = true
            self.scrollReverse(animated: animated, completion: completion)
        }
        
    }

    @objc open func removeAllViewControllers() {
        self.removeChildIfNeeded(beforeViewController, shouldEndAppearanceTransition: false)
        self.removeChildIfNeeded(selectedViewController, shouldEndAppearanceTransition: false)
        self.removeChildIfNeeded(afterViewController, shouldEndAppearanceTransition: false)

        self.beforeViewController = nil
        self.selectedViewController = nil
        self.afterViewController = nil
    }
    
    /**
     Transitions to the view controller right of the currently selected view controller in a horizontal orientation, or below the currently selected view controller in a vertical orientation. Also described as going to the next page.
     
     - parameter animated: A Boolean whether or not to animate the transition
     - parameter completion: A block that's called after the transition is finished. The block parameter `transitionSuccessful` is `true` if the transition to the selected view controller was completed successfully. If `false`, the transition returned to the view controller it started from.
     */
    @objc(scrollForwardAnimated:completion:)
    open func scrollForward(animated: Bool, completion: ((_ transitionSuccessful: Bool) -> Void)?) {
        
        if (self.afterViewController != nil) {
            
            // Cancel current animation and move
            if self.scrolling {
                if self.isOrientationHorizontal {
                    self.scrollView.setContentOffset(CGPoint(x: self.view.bounds.width * 2, y: 0), animated: false)
                } else {
                    self.scrollView.setContentOffset(CGPoint(x: 0, y: self.view.bounds.height * 2), animated: false)
                }
                
            }
            
            self.didFinishScrollingCompletionHandler = completion
            self.transitionAnimated = animated
            if self.isOrientationHorizontal {
                self.scrollView.setContentOffset(CGPoint(x: self.view.bounds.width * 2, y: 0), animated: animated)
            } else {
                self.scrollView.setContentOffset(CGPoint(x: 0, y: self.view.bounds.height * 2), animated: animated)
            }
            
        }
    }
    
    /**
     Transitions to the view controller left of the currently selected view controller in a horizontal orientation, or above the currently selected view controller in a vertical orientation. Also described as going to the previous page.
     
     - parameter animated: A Boolean whether or not to animate the transition
     - parameter completion: A block that's called after the transition is finished. The block parameter `transitionSuccessful` is `true` if the transition to the selected view controller was completed successfully. If `false`, the transition returned to the view controller it started from.
     */
    @objc(scrollReverseAnimated:completion:)
    open func scrollReverse(animated: Bool, completion: ((_ transitionSuccessful: Bool) -> Void)?) {
        if (self.beforeViewController != nil) {
            
            // Cancel current animation and move
            if self.scrolling {
                self.scrollView.setContentOffset(CGPoint(x: 0, y: 0), animated: false)
            }
            
            self.didFinishScrollingCompletionHandler = completion
            self.transitionAnimated = animated
            self.scrollView.setContentOffset(CGPoint(x: 0, y: 0), animated: animated)
        }
    }
    

    @nonobjc @available(*, unavailable, renamed: "scrollForward(animated:completion:)")
    open func scrollForwardAnimated(_ animated: Bool, completion: ((_ transitionSuccessful: Bool) -> Void)?) {
        self.scrollForward(animated: animated, completion: completion)
    }

    @nonobjc @available(*, unavailable, renamed: "scrollReverse(animated:completion:)")
    open func scrollReverseAnimated(_ animated: Bool, completion: ((_ transitionSuccessful: Bool) -> Void)?) {
        self.scrollReverse(animated: animated, completion: completion)
    }
    
    
    // MARK: - View Controller Overrides
    
    // Overriden to have control of accurate view appearance method calls
    open override var shouldAutomaticallyForwardAppearanceMethods : Bool {
        return false
    }
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        
        self.scrollView.delegate = self
        self.view.addSubview(self.scrollView)
    }
    
    open override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        guard !self.scrolling else {
            return
        }
        
        self.scrollView.frame = self.view.bounds
        if self.isOrientationHorizontal {
            self.scrollView.contentSize = CGSize(width: self.view.bounds.width * 3, height: self.view.bounds.height)
        } else {
            self.scrollView.contentSize = CGSize(width: self.view.bounds.width, height: self.view.bounds.height * 3)
        }

        self.layoutViews()
    }
    
    
    open override func viewWillAppear(_ animated: Bool) {
        print("[EMPageViewController] viewWillAppear")
        super.viewWillAppear(animated)
        self.beginAppearanceTransition(for: self.selectedViewController, isAppearing: true, animated: animated)
    }

     open override func viewDidAppear(_ animated: Bool) {
        print("[EMPageViewController] viewDidAppear")
        super.viewDidAppear(animated)
        self.viewHasAppeared = true
        self.endAppearanceTransition(for: self.selectedViewController)
    }

     open override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.beginAppearanceTransition(for: self.selectedViewController, isAppearing: false, animated: animated)
    }

     open override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        self.viewHasAppeared = false
        self.endAppearanceTransition(for: self.selectedViewController)
    }
    
    
    // MARK: - View Controller Management
    
    private func loadViewControllers(_ selectedViewController: UIViewController) {

        // Scrolled forward
        if (selectedViewController == self.afterViewController) {

            // Shift view controllers forward
            self.beforeViewController = self.selectedViewController
            self.selectedViewController = self.afterViewController

            self.endAppearanceTransition(for: self.selectedViewController)

            self.removeChildIfNeeded(self.beforeViewController, shouldEndAppearanceTransition: true)

            self.delegate?.em_pageViewController?(self, didFinishScrollingFrom: self.beforeViewController, destinationViewController: self.selectedViewController!, transitionSuccessful: true)

            self.didFinishScrollingCompletionHandler?(true)
            self.didFinishScrollingCompletionHandler = nil

            // Load new before view controller if required
            if self.loadNewAdjoiningViewControllersOnFinish {
                self.loadBeforeViewController(for: selectedViewController)
                self.loadNewAdjoiningViewControllersOnFinish = false
            }

            // Load new after view controller
            self.loadAfterViewController(for: selectedViewController)


        // Scrolled reverse
        } else if (selectedViewController == self.beforeViewController) {

            // Shift view controllers reverse
            self.afterViewController = self.selectedViewController
            self.selectedViewController = self.beforeViewController

            self.endAppearanceTransition(for: self.selectedViewController)

            self.removeChildIfNeeded(self.afterViewController, shouldEndAppearanceTransition: true)

            self.delegate?.em_pageViewController?(self, didFinishScrollingFrom: self.afterViewController!, destinationViewController: self.selectedViewController!, transitionSuccessful: true)

            self.didFinishScrollingCompletionHandler?(true)
            self.didFinishScrollingCompletionHandler = nil

            // Load new after view controller if required
            if self.loadNewAdjoiningViewControllersOnFinish {
                self.loadAfterViewController(for: selectedViewController)
                self.loadNewAdjoiningViewControllersOnFinish = false
            }

            // Load new before view controller
            self.loadBeforeViewController(for: selectedViewController)

        // Scrolled but ended up where started
        } else if (selectedViewController == self.selectedViewController) {

            self.selectedViewController!.beginAppearanceTransition(true, animated: self.transitionAnimated)

            if (self.navigationDirection == .forward) {
                self.beginAppearanceTransition(for: self.afterViewController, isAppearing: false, animated: self.transitionAnimated)
            } else if (self.navigationDirection == .reverse) {
                self.beginAppearanceTransition(for: self.beforeViewController, isAppearing: false, animated: self.transitionAnimated)
            }

            self.endAppearanceTransition(for: self.selectedViewController)

            if (self.navigationDirection == .forward) {
                self.removeChildIfNeeded(self.beforeViewController, shouldEndAppearanceTransition: false)
                self.removeChildIfNeeded(self.afterViewController, shouldEndAppearanceTransition: true)

                self.delegate?.em_pageViewController?(self, didFinishScrollingFrom: self.selectedViewController!, destinationViewController: self.afterViewController!, transitionSuccessful: false)
            } else if (self.navigationDirection == .reverse) {
                self.removeChildIfNeeded(self.beforeViewController, shouldEndAppearanceTransition: true)
                self.removeChildIfNeeded(self.afterViewController, shouldEndAppearanceTransition: false)

                self.delegate?.em_pageViewController?(self, didFinishScrollingFrom: self.selectedViewController!, destinationViewController: self.beforeViewController!, transitionSuccessful: false)
            }

            self.didFinishScrollingCompletionHandler?(false)
            self.didFinishScrollingCompletionHandler = nil

            if self.loadNewAdjoiningViewControllersOnFinish {
                if (self.navigationDirection == .forward) {
                    self.loadAfterViewController(for: selectedViewController)
                } else if (self.navigationDirection == .reverse) {
                    self.loadBeforeViewController(for: selectedViewController)
                }
            }

        }
        
        self.navigationDirection = nil
        self.scrolling = false
        
    }
    
    private func loadBeforeViewController(for selectedViewController:UIViewController) {
        // Retreive the new before controller from the data source if available, otherwise set as nil
        self.beforeViewController = self.dataSource?.em_pageViewController(self, viewControllerBeforeViewController: selectedViewController)
    }
    
    private func loadAfterViewController(for selectedViewController:UIViewController) {
        // Retreive the new after controller from the data source if available, otherwise set as nil
        self.afterViewController = self.dataSource?.em_pageViewController(self, viewControllerAfterViewController: selectedViewController)
    }
    
    
    // MARK: - View Management
    
    private func addChildIfNeeded(_ viewController: UIViewController, shouldBeginAppearanceTransition: Bool) {
        print("[EMPageViewController] addChild \(viewController.debugDescription)")
        self.addChild(viewController)
        self.scrollView.addSubview(viewController.view)
        if shouldBeginAppearanceTransition {
            self.beginAppearanceTransition(for: viewController, isAppearing: true, animated: self.transitionAnimated)
        }
        viewController.didMove(toParent: self)
    }
    
    private func removeChildIfNeeded(_ viewController: UIViewController?, shouldEndAppearanceTransition: Bool) {
        if let vc = viewController {
            print("[EMPageViewController] removeChild \(vc.debugDescription)")
        }
        viewController?.willMove(toParent: nil)
        viewController?.view.removeFromSuperview()
        if shouldEndAppearanceTransition {
            self.endAppearanceTransition(for: viewController)
        }
        viewController?.removeFromParent()
    }
    
    private func beginAppearanceTransition(for viewController: UIViewController?, isAppearing: Bool, animated: Bool) {
        guard let viewController = viewController, viewController.parent == self else { return }
        viewController.beginAppearanceTransition(isAppearing, animated: animated)
    }

    private func endAppearanceTransition(for viewController: UIViewController?) {
        guard self.viewHasAppeared, let viewController = viewController, viewController.parent == self else { return }
        viewController.endAppearanceTransition()
    }

    private func layoutViews() {
        
        let viewWidth = self.view.bounds.width
        let viewHeight = self.view.bounds.height
        
        var beforeInset:CGFloat = 0
        var afterInset:CGFloat = 0
        
        if (self.beforeViewController == nil) {
            beforeInset = self.isOrientationHorizontal ? -viewWidth : -viewHeight
        }
        
        if (self.afterViewController == nil) {
            afterInset = self.isOrientationHorizontal ? -viewWidth : -viewHeight
        }
        
        self.adjustingContentOffset = true
        self.scrollView.contentOffset = CGPoint(x: self.isOrientationHorizontal ? viewWidth : 0, y: self.isOrientationHorizontal ? 0 : viewHeight)
        if self.isOrientationHorizontal {
            self.scrollView.contentInset = UIEdgeInsets.init(top: 0, left: beforeInset, bottom: 0, right: afterInset)
        } else {
            self.scrollView.contentInset = UIEdgeInsets.init(top: beforeInset, left: 0, bottom: afterInset, right: 0)
        }
        self.adjustingContentOffset = false
        
        if self.isOrientationHorizontal {
            self.beforeViewController?.view.frame = CGRect(x: 0, y: 0, width: viewWidth, height: viewHeight)
            self.selectedViewController?.view.frame = CGRect(x: viewWidth, y: 0, width: viewWidth, height: viewHeight)
            self.afterViewController?.view.frame = CGRect(x: viewWidth * 2, y: 0, width: viewWidth, height: viewHeight)
        } else {
            self.beforeViewController?.view.frame = CGRect(x: 0, y: 0, width: viewWidth, height: viewHeight)
            self.selectedViewController?.view.frame = CGRect(x: 0, y: viewHeight, width: viewWidth, height: viewHeight)
            self.afterViewController?.view.frame = CGRect(x: 0, y: viewHeight * 2, width: viewWidth, height: viewHeight)
        }
        
    }
    
    
    // MARK: - Internal Callbacks
    
    private func willScroll(from startingViewController: UIViewController?, to destinationViewController: UIViewController) {
        if (startingViewController != nil) {
            self.delegate?.em_pageViewController?(self, willStartScrollingFrom: startingViewController!, destinationViewController: destinationViewController)
        }
        
        self.addChildIfNeeded(destinationViewController, shouldBeginAppearanceTransition: self.viewHasAppeared)
        if self.viewHasAppeared {
            self.beginAppearanceTransition(for: startingViewController, isAppearing: false, animated: self.transitionAnimated)
        }
    }
    
    private func didFinishScrolling(to viewController: UIViewController) {
        self.loadViewControllers(viewController)
        self.layoutViews()
    }
    
    
    // MARK: - UIScrollView Delegate
    
    open func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if !adjustingContentOffset {
        
            let distance = self.isOrientationHorizontal ? self.view.bounds.width : self.view.bounds.height
            let progress = ((self.isOrientationHorizontal ? scrollView.contentOffset.x : scrollView.contentOffset.y) - distance) / distance
            
            // Scrolling forward / after
            if (progress > 0) {
                if (self.afterViewController != nil) {
                    if !scrolling { // call willScroll once
                        self.willScroll(from: self.selectedViewController, to: self.afterViewController!)
                        self.scrolling = true
                    }
                    
                    if self.navigationDirection == .reverse { // check if direction changed
                        self.didFinishScrolling(to: self.selectedViewController!)
                        self.willScroll(from: self.selectedViewController, to: self.afterViewController!)
                    }
                    
                    self.navigationDirection = .forward
                    
                    if (self.selectedViewController != nil) {
                        self.delegate?.em_pageViewController?(self, isScrollingFrom: self.selectedViewController!, destinationViewController: self.afterViewController!, progress: progress)
                    }
                }
                
            // Scrolling reverse / before
            } else if (progress < 0) {
                if (self.beforeViewController != nil) {
                    if !scrolling { // call willScroll once
                        self.willScroll(from: self.selectedViewController, to: self.beforeViewController!)
                        self.scrolling = true
                    }
                    
                    if self.navigationDirection == .forward { // check if direction changed
                        self.didFinishScrolling(to: self.selectedViewController!)
                        self.willScroll(from: self.selectedViewController, to: self.beforeViewController!)
                    }
                    
                    self.navigationDirection = .reverse
                    
                    if (self.selectedViewController != nil) {
                        self.delegate?.em_pageViewController?(self, isScrollingFrom: self.selectedViewController!, destinationViewController: self.beforeViewController!, progress: progress)
                    }
                }
                
            // At zero
            } else {
                if (self.navigationDirection == .forward) {
                    self.delegate?.em_pageViewController?(self, isScrollingFrom: self.selectedViewController!, destinationViewController: self.afterViewController!, progress: progress)
                } else if (self.navigationDirection == .reverse) {
                    self.delegate?.em_pageViewController?(self, isScrollingFrom: self.selectedViewController!, destinationViewController: self.beforeViewController!, progress: progress)
                }
            }
            
            // Thresholds to update view layouts call delegates
            if (progress >= 1 && self.afterViewController != nil) {
                self.didFinishScrolling(to: self.afterViewController!)
            } else if (progress <= -1  && self.beforeViewController != nil) {
                self.didFinishScrolling(to: self.beforeViewController!)
            } else if (progress == 0  && self.selectedViewController != nil) {
                self.didFinishScrolling(to: self.selectedViewController!)
            }
            
        }
        
    }
    
    open func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        self.transitionAnimated = true
    }
    
    open func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        // setContentOffset is called to center the selected view after bounces
        // This prevents yucky behavior at the beginning and end of the page collection by making sure setContentOffset is called only if...
        
        if self.isOrientationHorizontal {
            if  (self.beforeViewController != nil && self.afterViewController != nil) || // It isn't at the beginning or end of the page collection
                (self.afterViewController != nil && self.beforeViewController == nil && scrollView.contentOffset.x > abs(scrollView.contentInset.left)) || // If it's at the beginning of the collection, the decelleration can't be triggered by scrolling away from, than torwards the inset
                (self.beforeViewController != nil && self.afterViewController == nil && scrollView.contentOffset.x < abs(scrollView.contentInset.right)) { // Same as the last condition, but at the end of the collection
                    scrollView.setContentOffset(CGPoint(x: self.view.bounds.width, y: 0), animated: true)
            }
        } else {
            if  (self.beforeViewController != nil && self.afterViewController != nil) || // It isn't at the beginning or end of the page collection
                (self.afterViewController != nil && self.beforeViewController == nil && scrollView.contentOffset.y > abs(scrollView.contentInset.top)) || // If it's at the beginning of the collection, the decelleration can't be triggered by scrolling away from, than torwards the inset
                (self.beforeViewController != nil && self.afterViewController == nil && scrollView.contentOffset.y < abs(scrollView.contentInset.bottom)) { // Same as the last condition, but at the end of the collection
                    scrollView.setContentOffset(CGPoint(x: 0, y: self.view.bounds.height), animated: true)
            }
        }
        
    }
}

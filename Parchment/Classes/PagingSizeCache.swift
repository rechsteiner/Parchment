import Foundation
import UIKit

class PagingSizeCache<T: PagingItem>  where T: Hashable & Comparable {
  
  var implementsWidthDelegate: Bool = false
  var widthForPagingItem: ((T, Bool) -> CGFloat?)?
  
  private let options: PagingOptions
  private var widthCache: [T: CGFloat] = [:]
  private var selectedWidthCache: [T: CGFloat] = [:]
  
  init(options: PagingOptions) {
    self.options = options
    
    #if swift(>=4.2)
    let didEnterBackground = UIApplication.didEnterBackgroundNotification
    let didReceiveMemoryWarning = UIApplication.didReceiveMemoryWarningNotification
    #else
    let didEnterBackground = NSNotification.Name.UIApplicationDidEnterBackground
    let didReceiveMemoryWarning = NSNotification.Name.UIApplicationDidReceiveMemoryWarning
    #endif
    
    NotificationCenter.default.addObserver(self,
      selector: #selector(applicationDidEnterBackground(notification:)),
      name: didEnterBackground,
      object: nil)
    
    NotificationCenter.default.addObserver(self,
      selector: #selector(didReceiveMemoryWarning(notification:)),
      name: didReceiveMemoryWarning,
      object: nil)
  }
  
  deinit {
    NotificationCenter.default.removeObserver(self)
  }
  
  func clear() {
    self.widthCache =  [:]
    self.selectedWidthCache = [:]
  }
  
  func itemWidth(for pagingItem: T) -> CGFloat {
    if let width = widthCache[pagingItem] {
      return width
    } else {
      let width = widthForPagingItem?(pagingItem, false)
      widthCache[pagingItem] = width
      return width ?? options.estimatedItemWidth
    }
  }
  
  func itemWidthSelected(for pagingItem: T) -> CGFloat {
    if let width = selectedWidthCache[pagingItem] {
      return width
    } else {
      let width = widthForPagingItem?(pagingItem, true)
      selectedWidthCache[pagingItem] = width
      return width ?? options.estimatedItemWidth
    }
  }
  
  @objc private func didReceiveMemoryWarning(notification: NSNotification) {
    self.clear()
  }
  
  @objc private func applicationDidEnterBackground(notification: NSNotification) {
    self.clear()
  }
  
}

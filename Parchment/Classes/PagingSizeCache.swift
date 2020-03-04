import Foundation
import UIKit

class PagingSizeCache {
  
  var options: PagingOptions
  var implementsWidthDelegate: Bool = false
  var widthForPagingItem: ((PagingItem, Bool) -> CGFloat?)?
  
  private var widthCache: [Int: CGFloat] = [:]
  private var selectedWidthCache: [Int: CGFloat] = [:]
  
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
  
  func itemWidth(for pagingItem: PagingItem) -> CGFloat {
    if let width = widthCache[pagingItem.identifier] {
      return width
    } else {
      let width = widthForPagingItem?(pagingItem, false)
      widthCache[pagingItem.identifier] = width
      return width ?? options.estimatedItemWidth
    }
  }
  
  func itemWidthSelected(for pagingItem: PagingItem) -> CGFloat {
    if let width = selectedWidthCache[pagingItem.identifier] {
      return width
    } else {
      let width = widthForPagingItem?(pagingItem, true)
      selectedWidthCache[pagingItem.identifier] = width
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

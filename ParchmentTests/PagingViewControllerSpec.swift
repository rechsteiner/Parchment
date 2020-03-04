import Foundation
import Quick
import Nimble
import UIKit
@testable import Parchment

class DataSource: PagingViewControllerInfiniteDataSource {
  
  func pagingViewController(_: PagingViewController, itemAfter: PagingItem) -> PagingItem? {
    guard let item = itemAfter as? Item else { return nil }
    if item.index < 50 {
      return Item(index: item.index + 1)
    }
    return nil
  }
  
  func pagingViewController(_: PagingViewController, itemBefore: PagingItem) -> PagingItem? {
    guard let item = itemBefore as? Item else { return nil }
    if item.index > 0 {
      return Item(index: item.index - 1)
    }
    return nil
  }
  
  func pagingViewController(_: PagingViewController, viewControllerFor pagingItem: PagingItem) -> UIViewController {
    return UIViewController()
  }
  
}

class SizeDelegate: PagingViewControllerSizeDelegate {
  
  func pagingViewController(_ pagingViewController: PagingViewController, widthForPagingItem pagingItem: PagingItem, isSelected: Bool) -> CGFloat {
    guard let item = pagingItem as? PagingIndexItem else { return 0 }
    if item.index == 0 {
      return 100
    } else {
      return 50
    }
  }
  
}

class DeinitPagingViewController: PagingViewController {
  var deinitCalled: (() -> Void)?
  deinit { deinitCalled?() }
}

class ReloadingDataSource: PagingViewControllerDataSource {
  var items: [PagingIndexItem] = []
  var viewControllers: [UIViewController] = []
  
  func numberOfViewControllers(in pagingViewController: PagingViewController) -> Int {
    return items.count
  }
  
  func pagingViewController(_: PagingViewController, viewControllerAt index: Int) -> UIViewController {
    return viewControllers[index]
  }
  
  func pagingViewController(_: PagingViewController, pagingItemAt index: Int) -> PagingItem {
    return items[index]
  }
}

class PagingViewControllerSpec: QuickSpec {
  
  override func spec() {
    
    describe("PagingViewController") {
      
      describe("reloading menu") {
        
        let dataSource = ReloadingDataSource()
        var pagingViewController: PagingViewController!
        var viewController0: UIViewController!
        var viewController1: UIViewController!
        
        beforeEach {
          viewController0 = UIViewController()
          viewController1 = UIViewController()
          
          dataSource.viewControllers = [
            viewController0,
            viewController1
          ]
          
          dataSource.items = [
            PagingIndexItem(index: 0, title: "0"),
            PagingIndexItem(index: 1, title: "1")
          ]
          
          pagingViewController = PagingViewController()
          pagingViewController.menuItemSize = .fixed(width: 100, height: 50)
          pagingViewController.dataSource = dataSource
          
          UIApplication.shared.keyWindow!.rootViewController = pagingViewController
          let _ = pagingViewController.view
          
          pagingViewController.collectionView.bounds = CGRect(x: 0, y: 0, width: 1000, height: 50)
          pagingViewController.viewDidLayoutSubviews()
        }
        
        it("reload the menu items") {
          let item2 = PagingIndexItem(index: 0, title: "2")
          let item3 = PagingIndexItem(index: 1, title: "3")
          
          dataSource.items = [item2, item3]
          pagingViewController.reloadMenu()
          pagingViewController.view.layoutIfNeeded()
          
          let cell2 = pagingViewController.collectionView.cellForItem(
            at: IndexPath(item: 0, section: 0)
          ) as? PagingTitleCell
          let cell3 = pagingViewController.collectionView.cellForItem(
            at: IndexPath(item: 1, section: 0)
          ) as? PagingTitleCell
          
          expect(pagingViewController.collectionView.numberOfItems(inSection: 0)).to(equal(2))
          expect(cell2?.titleLabel.text).to(equal("2"))
          expect(cell3?.titleLabel.text).to(equal("3"))
        }
        
        it("does not reload the view controllers") {
          let viewController2 = UIViewController()
          let viewController3 = UIViewController()
          
          dataSource.viewControllers = [viewController2, viewController3]
          pagingViewController.reloadMenu()
          
          let pageViewController = pagingViewController.pageViewController
          expect(pageViewController.selectedViewController).to(be(viewController0))
          expect(pageViewController.afterViewController).to(be(viewController1))
        }
        
      }
      
      describe("reloading data") {
        
        let dataSource = ReloadingDataSource()
        var delegate: SizeDelegate!
        var pagingViewController: PagingViewController!
        
        context("has items before reloading") {
          var viewController0: UIViewController!
          var viewController1: UIViewController!
          
          beforeEach {
            viewController0 = UIViewController()
            viewController1 = UIViewController()
            
            dataSource.viewControllers = [
              viewController0,
              viewController1
            ]
            
            dataSource.items = [
              PagingIndexItem(index: 0, title: "0"),
              PagingIndexItem(index: 1, title: "1")
            ]
            
            pagingViewController = PagingViewController()
            pagingViewController.menuItemSize = .fixed(width: 100, height: 50)
            pagingViewController.dataSource = dataSource
            
            UIApplication.shared.keyWindow!.rootViewController = pagingViewController
            let _ = pagingViewController.view
            
            pagingViewController.collectionView.bounds = CGRect(x: 0, y: 0, width: 1000, height: 50)
            pagingViewController.viewDidLayoutSubviews()
          }
          
          it("reloads data around item") {
            let item2 = PagingIndexItem(index: 2, title: "2")
            let item3 = PagingIndexItem(index: 3, title: "3")
            
            dataSource.items = [item2, item3]
            pagingViewController.reloadData(around: item2)
            pagingViewController.view.layoutIfNeeded()
            
            let cell2 = pagingViewController.collectionView.cellForItem(at: IndexPath(item: 0, section: 0))
            let cell3 = pagingViewController.collectionView.cellForItem(at: IndexPath(item: 1, section: 0))
            
            expect((cell2 as? PagingTitleCell)?.titleLabel.text).to(equal("2"))
            expect((cell3 as? PagingTitleCell)?.titleLabel.text).to(equal("3"))
            expect(pagingViewController.state).to(equal(PagingState.selected(pagingItem: item2)))
            expect(pagingViewController.pageViewController.selectedViewController).to(be(viewController0))
            expect(pagingViewController.pageViewController.afterViewController).to(be(viewController1))
          }
          
          it("updates view controllers when reloading data") {
            let item2 = PagingIndexItem(index: 2, title: "2")
            let item3 = PagingIndexItem(index: 3, title: "3")
            
            let viewController2 = UIViewController()
            let viewController3 = UIViewController()
            
            dataSource.viewControllers = [viewController2, viewController3]
            dataSource.items = [item2, item3]
            pagingViewController.reloadData()
            
            expect(pagingViewController.pageViewController.selectedViewController).to(be(viewController2))
            expect(pagingViewController.pageViewController.afterViewController).to(be(viewController3))
          }
          
          it("updates view controllers when reloading around last item") {
            let item2 = PagingIndexItem(index: 2, title: "2")
            let item3 = PagingIndexItem(index: 3, title: "3")
            
            let viewController2 = UIViewController()
            let viewController3 = UIViewController()
            
            dataSource.viewControllers = [viewController2, viewController3]
            dataSource.items = [item2, item3]
            pagingViewController.reloadData(around: item3)
            
            expect(pagingViewController.pageViewController.selectedViewController).to(be(viewController3))
            expect(pagingViewController.pageViewController.beforeViewController).to(be(viewController2))
          }
          
          it("updates view controllers when reloading data without changing items") {
            let viewController2 = UIViewController()
            let viewController3 = UIViewController()
            
            dataSource.viewControllers = [viewController2, viewController3]
            pagingViewController.reloadData()
            
            expect(pagingViewController.pageViewController.selectedViewController).to(be(viewController2))
            expect(pagingViewController.pageViewController.afterViewController).to(be(viewController3))
          }
          
          it("selects previously selected item when reloading data") {
            let item0 = PagingIndexItem(index: 0, title: "0")
            let item1 = PagingIndexItem(index: 1, title: "1")
            let item2 = PagingIndexItem(index: 2, title: "2")
            let viewController2 = UIViewController()
            
            dataSource.viewControllers = [
              viewController0,
              viewController1,
              viewController2
            ]
            
            pagingViewController.select(index: 1)
            pagingViewController.view.layoutIfNeeded()
            
            dataSource.items = [item0, item1, item2]
            pagingViewController.reloadData()
            pagingViewController.view.layoutIfNeeded()
            
            let cell0 = pagingViewController.collectionView.cellForItem(at: IndexPath(item: 0, section: 0))
            let cell1 = pagingViewController.collectionView.cellForItem(at: IndexPath(item: 1, section: 0))
            let cell2 = pagingViewController.collectionView.cellForItem(at: IndexPath(item: 2, section: 0))
            
            expect((cell0 as? PagingTitleCell)?.titleLabel.text).to(equal("0"))
            expect((cell1 as? PagingTitleCell)?.titleLabel.text).to(equal("1"))
            expect((cell2 as? PagingTitleCell)?.titleLabel.text).to(equal("2"))
            expect(pagingViewController.state).to(equal(PagingState.selected(pagingItem: item1)))
          }
          
          it("selects the first item when reloading data with all new items") {
            let item2 = PagingIndexItem(index: 2, title: "2")
            let item3 = PagingIndexItem(index: 3, title: "3")
            
            pagingViewController.select(index: 1)
            pagingViewController.view.layoutIfNeeded()
            
            dataSource.items = [item2, item3]
            pagingViewController.reloadData()
            pagingViewController.view.layoutIfNeeded()
            
            let cell2 = pagingViewController.collectionView.cellForItem(at: IndexPath(item: 0, section: 0))
            let cell3 = pagingViewController.collectionView.cellForItem(at: IndexPath(item: 1, section: 0))
            
            expect((cell2 as? PagingTitleCell)?.titleLabel.text).to(equal("2"))
            expect((cell3 as? PagingTitleCell)?.titleLabel.text).to(equal("3"))
            expect(pagingViewController.state).to(equal(PagingState.selected(pagingItem: item2)))
          }
          
          it("display an empty view after reloading data with no items") {
            dataSource.items = []
            pagingViewController.reloadData()
            
            expect(pagingViewController.pageViewController.scrollView.subviews).to(beEmpty())
            expect(pagingViewController.collectionView.numberOfItems(inSection: 0)).to(equal(0))
          }
        }

        context("is empty before reloading") {
          
          beforeEach {
            pagingViewController = PagingViewController()
            pagingViewController.dataSource = dataSource
            
            UIApplication.shared.keyWindow!.rootViewController = pagingViewController
            let _ = pagingViewController.view
            pagingViewController.collectionView.bounds = CGRect(x: 0, y: 0, width: 1000, height: 50)
            pagingViewController.viewDidLayoutSubviews()
          }
          
          describe("width delegate") {
            
            beforeEach {
              delegate = SizeDelegate()
              pagingViewController.sizeDelegate = delegate
            }
            
            it("uses the width delegate after reloading data") {
              dataSource.viewControllers = [
                UIViewController(),
                UIViewController()
              ]
              dataSource.items = [
                PagingIndexItem(index: 0, title: "0"),
                PagingIndexItem(index: 1, title: "1")
              ]
              
              pagingViewController.reloadData()
              pagingViewController.view.layoutIfNeeded()
              
              let cell0 = pagingViewController.collectionView.cellForItem(at: IndexPath(item: 0, section: 0))
              let cell1 = pagingViewController.collectionView.cellForItem(at: IndexPath(item: 1, section: 0))
              
              expect((cell0 as? PagingTitleCell)?.titleLabel.text).to(equal("0"))
              expect((cell1 as? PagingTitleCell)?.titleLabel.text).to(equal("1"))
              expect(cell0?.bounds.width).to(equal(100))
              expect(cell1?.bounds.width).to(equal(50))
            }
            
          }
          
        }
        
      }
      
      describe("selecting items") {
        
        let dataSource = DataSource()
        var viewController: PagingViewController!
        
        beforeEach {
          viewController = PagingViewController()
          viewController.register(PagingTitleCell.self, for: Item.self)
          viewController.menuItemSize = .fixed(width: 100, height: 50)
          viewController.infiniteDataSource = dataSource
          
          UIApplication.shared.keyWindow!.rootViewController = viewController
          let _ = viewController.view
          
          viewController.collectionView.bounds = CGRect(x: 0, y: 0, width: 1000, height: 50)
          viewController.viewDidLayoutSubviews()
        }
        
        it("selecting the first item generates enough items") {
          viewController.select(pagingItem: Item(index: 0))
          let items = viewController.collectionView.numberOfItems(inSection: 0)
          expect(items).to(equal(21))
        }
        
        it("selecting the center item generates enough items") {
          viewController.select(pagingItem: Item(index: 20))
          let items = viewController.collectionView.numberOfItems(inSection: 0)
          expect(items).to(equal(21))
        }
        
        it("selecting the last item generates enough items") {
          viewController.select(pagingItem: Item(index: 50))
          let items = viewController.collectionView.numberOfItems(inSection: 0)
          expect(items).to(equal(21))
        }
        
      }
      
      describe("retain cycles") {
        
        it("deinits PagingViewController") {
          var instance: DeinitPagingViewController? = DeinitPagingViewController()
          waitUntil { done in
            instance?.deinitCalled = {
              done()
            }
            DispatchQueue.global(qos: .background).async {
              instance = nil
            }
          }
        }
        
      }
    }
  }
}


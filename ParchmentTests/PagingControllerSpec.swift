import Foundation
import Quick
import Nimble
@testable import Parchment

class PagingControllerSpec: QuickSpec {
  
  static let ItemSize: CGFloat = 50
  
  override func spec() {
    
    var options: PagingOptions!
    var collectionView: MockCollectionView!
    var collectionViewLayout: MockCollectionViewLayout!
    var dataSource: MockPagingControllerDataSource!
    var delegate: MockPagingControllerDelegate!
    var sizeDelegate: MockPagingControllerSizeDelegate?
    var pagingController: PagingController!
    
    beforeEach {
      options = PagingOptions()
      options.selectedScrollPosition = .left
      options.menuItemSize = .fixed(
        width: PagingControllerSpec.ItemSize,
        height: PagingControllerSpec.ItemSize
      )
      
      collectionViewLayout = MockCollectionViewLayout()
      collectionView = MockCollectionView()
      collectionView.superview = UIView(frame: .zero)
      collectionView.collectionViewLayout = collectionViewLayout
      collectionView.window = UIWindow(frame: .zero)
      collectionView.bounds = CGRect(
        origin: .zero,
        size: CGSize(
          width: PagingControllerSpec.ItemSize * 2,
          height: PagingControllerSpec.ItemSize
        )
      )
      collectionView.visibleItems = {
        return pagingController.visibleItems.items.count
      }
      
      dataSource = MockPagingControllerDataSource()
      delegate = MockPagingControllerDelegate()
      
      pagingController = PagingController(options: options)
      pagingController.collectionView = collectionView
      pagingController.collectionViewLayout = collectionViewLayout
      pagingController.dataSource = dataSource
      pagingController.delegate = delegate
    }
    
    // MARK: Content scrolled
    
    describe("content scrolled") {
      context("state is .selected") {
        context("progress is positive") {
          it("enters the scrolling state and invalidates the layout") {
            // Select the first item.
            pagingController.select(pagingItem: Item(index: 3), animated: false)
            
            // Reset the mock call count.
            collectionView.calls = []
            collectionViewLayout.calls = []
          
            // Simulate that the user scrolled to the next page.
            pagingController.contentScrolled(progress: 0.5)
            
            expect(pagingController.state).to(equal(PagingState.scrolling(
              pagingItem: Item(index: 3),
              upcomingPagingItem: Item(index: 4),
              progress: 0.5,
              initialContentOffset: CGPoint(x: 100, y: 0),
              distance: PagingControllerSpec.ItemSize
            )))
            
            // Combine the method calls for the collection view and
            // collection view layout to ensure that they were called in
            // the correct order.
            let actions = combinedActions(collectionView.calls, collectionViewLayout.calls)
            expect(actions).to(equal(
              [
                .collectionView(.setContentOffset(
                  contentOffset: CGPoint(x: 125, y: 0),
                  animated: false
                )),
                .collectionViewLayout(.invalidateLayoutWithContext(
                  invalidateSizes: false
                ))
              ]
            ))
          }
        }
        
        context("progress is negative") {
          it("enters the scrolling state and invalidates the layout") {
            // Select the first item.
            pagingController.select(pagingItem: Item(index: 3), animated: false)
            
            // Reset the mock call count.
            collectionView.calls = []
            collectionViewLayout.calls = []
            
            // Simulate that the user scrolled to the next page.
            pagingController.contentScrolled(progress: -0.1)
            
            expect(pagingController.state).to(equal(PagingState.scrolling(
              pagingItem: Item(index: 3),
              upcomingPagingItem: Item(index: 2),
              progress: -0.1,
              initialContentOffset: CGPoint(x: 100, y: 0),
              distance: -PagingControllerSpec.ItemSize
            )))
            
            // Combine the method calls for the collection view and
            // collection view layout to ensure that they were called in
            // the correct order.
            let actions = combinedActions(collectionView.calls, collectionViewLayout.calls)
            expect(actions).to(equal(
              [
                .collectionView(.setContentOffset(
                  contentOffset: CGPoint(x: 95, y: 0),
                  animated: false
                )),
                .collectionViewLayout(.invalidateLayoutWithContext(
                  invalidateSizes: false
                ))
              ]
            ))
          }
        }
        
        context("does not have upcoming paging item") {
          it("does not update the content offset") {
            // Prevent the data source from returning an upcoming item.
            dataSource.maxIndexAfter = 3
            
            // Select the first item.
            pagingController.select(pagingItem: Item(index: 3), animated: false)
            
            // Reset the mock call count.
            collectionView.calls = []
            collectionViewLayout.calls = []
            
            // Simulate that the user scrolled to the next page.
            pagingController.contentScrolled(progress: 0.1)
            
            // Combine the method calls for the collection view and
            // collection view layout to ensure that they were called in
            // the correct order.
            let actions = combinedActions(collectionView.calls, collectionViewLayout.calls)
            expect(actions).to(equal(
              [
                .collectionViewLayout(.invalidateLayoutWithContext(
                  invalidateSizes: false
                ))
              ]
            ))
          }
        }
        
        context("progress is zero") {
          it("does not update the state or call any methods") {
            // Select the first item.
            pagingController.select(pagingItem: Item(index: 3), animated: false)
            
            // Reset the mock call count.
            collectionView.calls = []
            collectionViewLayout.calls = []
            
            // Simulate that the user scrolled, but the progress is zero.
            pagingController.contentScrolled(progress: 0)
            
            expect(collectionView.calls).to(beEmpty())
            expect(collectionViewLayout.calls).to(beEmpty())
            expect(pagingController.state).to(equal(PagingState.selected(
              pagingItem: Item(index: 3)
            )))
          }
        }
        
        context("implements width delegate") {
          it("invalidates the collection view layout sizes") {
            // Setup the size delegate.
            sizeDelegate = MockPagingControllerSizeDelegate()
            sizeDelegate?.pagingItemWidth = { 100 }
            pagingController.sizeDelegate = sizeDelegate
            
            // Select the first item.
            pagingController.select(pagingItem: Item(index: 3), animated: false)
            
            // Simulate that the user scrolled to the next page.
            pagingController.contentScrolled(progress: 0.1)
            
            let action = collectionViewLayout.calls.last?.action
            expect(action).to(equal(.collectionViewLayout(.invalidateLayoutWithContext(
              invalidateSizes: true
            ))))
          }
        }
        
        context("upcoming item is nil and implements width delegate") {
          it("does not update the content offset or invalidate the sizes") {
            // Prevent the data source from returning an upcoming item.
            dataSource.maxIndexAfter = 3
            
            // Setup the size delegate.
            sizeDelegate = MockPagingControllerSizeDelegate()
            sizeDelegate?.pagingItemWidth = { 100 }
            pagingController.sizeDelegate = sizeDelegate
            
            // Select the first item.
            pagingController.select(pagingItem: Item(index: 3), animated: false)
            
            // Reset the mock call count.
            collectionView.calls = []
            collectionViewLayout.calls = []
            
            // Simulate that the user scrolled to the next page.
            pagingController.contentScrolled(progress: 0.1)
            
            // Combine the method calls for the collection view and
            // collection view layout to ensure that they were called in
            // the correct order.
            let actions = combinedActions(collectionView.calls, collectionViewLayout.calls)
            expect(actions).to(equal(
              [
                .collectionViewLayout(.invalidateLayoutWithContext(
                  invalidateSizes: false
                ))
              ]
            ))
          }
        }
        
        context("upcoming item is outside visible items") {
          it("appends items around the upcoming item") {
            // Select the first item, and scroll to the edge of the
            // collection view a few times to make sure the selected
            // item is no longer in view.
            dataSource.minIndexBefore = 0
            pagingController.select(pagingItem: Item(index: 0), animated: false)
            collectionView.contentOffset = CGPoint(x: 150, y: 0)
            pagingController.menuScrolled()
            collectionView.contentOffset = CGPoint(x: 200, y: 0)
            pagingController.menuScrolled()
            collectionView.contentOffset = CGPoint(x: 250, y: 0)
            pagingController.menuScrolled()
            
            // Reset the mock call count.
            collectionView.calls = []
            collectionViewLayout.calls = []
            
            // Simulate that the user scrolled to the next page.
            pagingController.contentScrolled(progress: 0.5)
            
            // The visible items should now contain the items that were
            // visible before scrolling (6..10), plus the items around
            // the selected item (0...4).
            expect(pagingController.visibleItems.items).to(equalItems(
              [
                Item(index: 0),
                Item(index: 1),
                Item(index: 2),
                Item(index: 3),
                Item(index: 4),
                Item(index: 6),
                Item(index: 7),
                Item(index: 8),
                Item(index: 9),
                Item(index: 10)
              ]
            ))
            
            // Combine the method calls for the collection view and
            // collection view layout to ensure that they were called in
            // the correct order.
            let actions = combinedActions(collectionView.calls, collectionViewLayout.calls)
            expect(actions).to(equal(
              [
                .collectionView(.reloadData),
                .collectionViewLayout(.prepare),
                .collectionView(.contentOffset(CGPoint(x: 400, y: 0))),
                .collectionView(.layoutIfNeeded),
                .collectionView(.setContentOffset(
                  contentOffset: CGPoint(x: 225, y: 0),
                  animated: false
                )),
                .collectionViewLayout(.invalidateLayoutWithContext(
                  invalidateSizes: false
                ))
              ]
            ))
          }
        }
      }
      
      context("state is .scrolling") {
        
        context("progress changed from positive to negative") {
          it("enters the selected state") {
            // Select an item and enter the scrolling state.
            pagingController.select(pagingItem: Item(index: 1), animated: false)
            pagingController.contentScrolled(progress: 0.1)
            
            // Reset the mock call count.
            collectionView.calls = []
            collectionViewLayout.calls = []
            
            // Simulate that the user change scroll direction.
            pagingController.contentScrolled(progress: -0.1)
            
            expect(collectionView.calls).to(beEmpty())
            expect(collectionViewLayout.calls).to(beEmpty())
            expect(pagingController.state).to(equal(PagingState.selected(
              pagingItem: Item(index: 1)
            )))
          }
        }
        
        context("progress changed from negative to positive") {
          it("enters the selected state") {
            // Select an item and enter the scrolling state.
            pagingController.select(pagingItem: Item(index: 1), animated: false)
            pagingController.contentScrolled(progress: -0.1)
            
            // Reset the mock call count.
            collectionView.calls = []
            collectionViewLayout.calls = []
            
            // Simulate that the user change scroll direction.
            pagingController.contentScrolled(progress: 0.1)
            
            expect(collectionView.calls).to(beEmpty())
            expect(collectionViewLayout.calls).to(beEmpty())
            expect(pagingController.state).to(equal(PagingState.selected(
              pagingItem: Item(index: 1)
            )))
          }
        }
        
        context("progres changed to zero") {
          it("enters the selected state") {
            // Select an item and enter the scrolling state.
            pagingController.select(pagingItem: Item(index: 1), animated: false)
            pagingController.contentScrolled(progress: -0.1)
            
            // Reset the mock call count.
            collectionView.calls = []
            collectionViewLayout.calls = []
            
            // Simulate that the progress changes to zero.
            pagingController.contentScrolled(progress: 0)
            
            expect(collectionView.calls).to(beEmpty())
            expect(collectionViewLayout.calls).to(beEmpty())
            expect(pagingController.state).to(equal(PagingState.selected(
              pagingItem: Item(index: 1)
            )))
          }
        }
        
        context("progress sign is the same") {
          it("updates the scrolling state and invalidates the layout") {
            // Select an item and enter the scrolling state.
            pagingController.select(pagingItem: Item(index: 1), animated: false)
            pagingController.contentScrolled(progress: 0.1)
            
            // Reset the mock call count.
            collectionView.calls = []
            collectionViewLayout.calls = []
            
            // Simulate that the progress changes to zero.
            pagingController.contentScrolled(progress: 0.2)
            
            expect(pagingController.state).to(equal(PagingState.scrolling(
              pagingItem: Item(index: 1),
              upcomingPagingItem: Item(index: 2),
              progress: 0.2,
              initialContentOffset: CGPoint(x: 100, y: 0),
              distance: PagingControllerSpec.ItemSize
            )))
            
            // Combine the method calls for the collection view and
            // collection view layout to ensure that they were called in
            // the correct order.
            let actions = combinedActions(collectionView.calls, collectionViewLayout.calls)
            expect(actions).to(equal(
              [
                .collectionView(.setContentOffset(
                  contentOffset: CGPoint(x: 110, y: 0),
                  animated: false
                )),
                .collectionViewLayout(.invalidateLayoutWithContext(
                  invalidateSizes: false
                ))
              ]
            ))
          }
        }
      }
    }
    
    // MARK: Select item
    
    describe("select item") {
      
      context("state is .empty") {
        context("has no superview") {
          it("enters selected state with no actions") {
            // Remove the superview.
            collectionView.superview = nil
            
            // Select the first item.
            pagingController.select(pagingItem: Item(index: 0), animated: false)
            
            expect(collectionView.calls).to(beEmpty())
            expect(collectionViewLayout.calls).to(beEmpty())
            expect(delegate.calls).to(beEmpty())
            expect(pagingController.state).to(equal(PagingState.selected(
              pagingItem: Item(index: 0)
            )))
          }
        }
        
        context("has superview but no window") {
          it("enters selected state and calls select content delegate") {
            // Remove the window and make sure we have a superview.
            collectionView.superview = UIView(frame: .zero)
            collectionView.window = nil
            
            pagingController.select(pagingItem: Item(index: 0), animated: false)
            
            expect(collectionView.calls).to(beEmpty())
            expect(collectionViewLayout.calls).to(beEmpty())
            expect(pagingController.state).to(equal(PagingState.selected(
              pagingItem: Item(index: 0)
            )))
            
            expect(delegate.calls).to(haveCount(1))
            expect(delegate.calls[0].action).to(equal(
              .delegate(.selectContent(
                pagingItem: Item(index: 0),
                direction: PagingDirection.none,
                animated: false
              ))
            ))
          }
          
          context("has superview and window") {
            it("enters selected state") {
              // Make sure there is no item before index 0.
              dataSource.minIndexBefore = 0
              
              // Make sure we have a superview and window
              collectionView.superview = UIView(frame: .zero)
              collectionView.window = UIWindow(frame: .zero)
              
              // Select the first item.
              pagingController.select(pagingItem: Item(index: 0), animated: false)
              
              expect(pagingController.state).to(equal(PagingState.selected(
                pagingItem: Item(index: 0)
              )))
              
              // Combine the method calls for the collection view,
              // collection view layout and delegate to ensure that
              // they were called in the correct order.
              let actions = combinedActions(
                collectionView.calls,
                collectionViewLayout.calls,
                delegate.calls
              )
              
              expect(actions).to(equal(
                [
                  .collectionView(.reloadData),
                  .collectionViewLayout(.prepare),
                  .collectionView(.contentOffset(.zero)),
                  .collectionView(.layoutIfNeeded),
                  .delegate(.selectContent(
                    pagingItem: Item(index: 0),
                    direction: PagingDirection.none,
                    animated: false
                  )),
                  .collectionView(.selectItem(
                    indexPath: IndexPath(item: 0, section: 0),
                    animated: false,
                    scrollPosition: .left
                  )),
                  .collectionView(.contentOffset(CGPoint(x: 0, y: 0)))
                ]
              ))
            }
          }
        }
      }
      
      context("state is .scrolling") {
        it("does not change the state") {
          // Select an item and enter the scrolling state.
          pagingController.select(pagingItem: Item(index: 1), animated: false)
          pagingController.contentScrolled(progress: -0.1)
          
          // Reset the mock call count and store the state.
          let oldState = pagingController.state
          collectionView.calls = []
          collectionViewLayout.calls = []
          delegate.calls = []
          
          // Select the third item.
          pagingController.select(pagingItem: Item(index: 2), animated: false)
          
          expect(collectionView.calls).to(beEmpty())
          expect(collectionViewLayout.calls).to(beEmpty())
          expect(delegate.calls).to(beEmpty())
          expect(pagingController.state).to(equal(oldState))
        }
      }
      
      context("state is .selected") {
        context("selected item is equal current item") {
          it("does not change the state") {
            // Select an item and enter the scrolling state.
            pagingController.select(pagingItem: Item(index: 0), animated: false)
            
            // Reset the mock call count and store the state.
            let oldState = pagingController.state
            collectionView.calls = []
            collectionViewLayout.calls = []
            delegate.calls = []
            
            // Select the first item.
            pagingController.select(pagingItem: Item(index: 0), animated: false)
            
            expect(collectionView.calls).to(beEmpty())
            expect(collectionViewLayout.calls).to(beEmpty())
            expect(delegate.calls).to(beEmpty())
            expect(pagingController.state).to(equal(oldState))
          }
        }
        
        context("selected item is not equal current item") {
          beforeEach {
            // Make sure there is no item before index 0.
            dataSource.minIndexBefore = 0
            
            // Select an item and enter the scrolling state.
            pagingController.select(pagingItem: Item(index: 1), animated: false)
            
            // Reset the mock call count and store the state.
            collectionView.calls = []
            collectionViewLayout.calls = []
            delegate.calls = []
          }
          
          it("enters the scrolling state") {
            pagingController.select(pagingItem: Item(index: 0), animated: false)
            
            expect(pagingController.state).to(equal(PagingState.scrolling(
              pagingItem: Item(index: 1),
              upcomingPagingItem: Item(index: 0),
              progress: 0,
              initialContentOffset: CGPoint(x: 50, y: 0),
              distance: -PagingControllerSpec.ItemSize
            )))
          }
          
          context("selected item is the previous sibling") {
            it("selects the previous content view") {
              pagingController.select(pagingItem: Item(index: 0), animated: false)
              
              expect(collectionView.calls).to(beEmpty())
              expect(collectionViewLayout.calls).to(beEmpty())
              expect(actions(delegate.calls)).to(equal([
                .delegate(.selectContent(
                  pagingItem: Item(index: 0),
                  direction: .reverse(sibling: true),
                  animated: false
                ))
              ]))
            }
          }
          
          context("selected item is the next sibling") {
            it("selects the next content view") {
              pagingController.select(pagingItem: Item(index: 2), animated: false)
              
              expect(collectionView.calls).to(beEmpty())
              expect(collectionViewLayout.calls).to(beEmpty())
              expect(actions(delegate.calls)).to(equal([
                .delegate(.selectContent(
                  pagingItem: Item(index: 2),
                  direction: .forward(sibling: true),
                  animated: false
                ))
              ]))
            }
          }
          
          context("selected item not any sibling") {
            it("selects the content view") {
              pagingController.select(pagingItem: Item(index: 4), animated: false)
              
              expect(collectionView.calls).to(beEmpty())
              expect(collectionViewLayout.calls).to(beEmpty())
              expect(actions(delegate.calls)).to(equal([
                .delegate(.selectContent(
                  pagingItem: Item(index: 4),
                  direction: .forward(sibling: false),
                  animated: false
                ))
              ]))
            }
          }
        }
        
        context("upcoming item is outside visible items") {
          it("appends items around the upcoming item") {
            // Select the first item, and scroll to the edge of the
            // collection view a few times to make sure the selected
            // item is no longer in view.
            dataSource.minIndexBefore = 0
            pagingController.select(pagingItem: Item(index: 0), animated: false)
            collectionView.contentOffset = CGPoint(x: 150, y: 0)
            pagingController.menuScrolled()
            collectionView.contentOffset = CGPoint(x: 200, y: 0)
            pagingController.menuScrolled()
            collectionView.contentOffset = CGPoint(x: 250, y: 0)
            pagingController.menuScrolled()
            
            // Reset the mock call count.
            collectionView.calls = []
            collectionViewLayout.calls = []
            delegate.calls = []
            
            // Select the item next to the selected item, which is now
            // scrolled out of view.
            pagingController.select(pagingItem: Item(index: 1), animated: false)
            
            // The visible items should now contain the items that were
            // visible before scrolling (6..10), plus the items around
            // the selected item (0...4).
            expect(pagingController.visibleItems.items).to(equalItems(
              [
                Item(index: 0),
                Item(index: 1),
                Item(index: 2),
                Item(index: 3),
                Item(index: 4),
                Item(index: 6),
                Item(index: 7),
                Item(index: 8),
                Item(index: 9),
                Item(index: 10)
              ]
            ))
            
            // Combine the method calls for the collection view,
            // collection view layout and delegate to ensure that
            // they were called in the correct order.
            let actions = combinedActions(
              collectionView.calls,
              collectionViewLayout.calls,
              delegate.calls
            )
            
            expect(actions).to(equal(
              [
                .collectionView(.reloadData),
                .collectionViewLayout(.prepare),
                .collectionView(.contentOffset(CGPoint(x: 400, y: 0))),
                .collectionView(.layoutIfNeeded),
                .delegate(.selectContent(
                  pagingItem: Item(index: 1),
                  direction: .forward(sibling: true),
                  animated: false
                ))
              ]
            ))
          }
        }
      }
      
    }
    
    // MARK: Content finished scrolling
    
    describe("content finished scrolling") {
      
      context("has an upcoming paging item") {
        
        beforeEach {
          // Select an item and enter the scrolling state.
          dataSource.minIndexBefore = 0
          pagingController.select(pagingItem: Item(index: 0), animated: false)
          pagingController.contentScrolled(progress: 0.5)
          
          // Reset the mock call count.
          collectionView.calls = []
          collectionViewLayout.calls = []
          delegate.calls = []
        }
        
        it("sets the selected item to equal the upcoming paging item") {
          pagingController.contentFinishedScrolling()
          
          expect(pagingController.state).to(equal(
            .selected(pagingItem: Item(index: 1))
          ))
        }
        
        context("collection view is not being dragged") {
          it("reload data, updates the layout and selects the item") {
            collectionView.isDragging = false
            pagingController.contentFinishedScrolling()
            
            // Combine the method calls for the collection view,
            // collection view layout and delegate to ensure that
            // they were called in the correct order.
            let actions = combinedActions(
              collectionView.calls,
              collectionViewLayout.calls,
              delegate.calls
            )
            
            expect(actions).to(equal(
              [
                .collectionView(.reloadData),
                .collectionViewLayout(.prepare),
                .collectionView(.contentOffset(CGPoint(x: 0, y: 0))),
                .collectionView(.layoutIfNeeded),
                .collectionView(.selectItem(
                  indexPath: IndexPath(item: 1, section: 0),
                  animated: false,
                  scrollPosition: .left
                )),
                .collectionView(.contentOffset(CGPoint(x: 50, y: 0)))
              ]
            ))
          }
        }
        
        context("collection view is being dragged") {
          it("does not update the collection view") {
            collectionView.isDragging = true
            pagingController.contentFinishedScrolling()
            
            expect(collectionView.calls).to(beEmpty())
            expect(collectionViewLayout.calls).to(beEmpty())
            expect(delegate.calls).to(beEmpty())
          }
        }
      }
      
      context("upcoming paging item is nil") {
        it("sets the selected item to equal the current paging item") {
          // Select an item and enter the scrolling state.
          dataSource.minIndexBefore = 0
          pagingController.select(pagingItem: Item(index: 0), animated: false)
          pagingController.contentScrolled(progress: -0.5)
          
          // Reset the mock call count.
          collectionView.calls = []
          collectionViewLayout.calls = []
          delegate.calls = []
          
          pagingController.contentFinishedScrolling()
          
          expect(pagingController.state).to(equal(
            .selected(pagingItem: Item(index: 0))
          ))
        }
      }
      
    }
    
    // MARK: Transition size
    
    describe("transition size") {
      
      beforeEach {
        dataSource.minIndexBefore = 0
        pagingController.select(pagingItem: Item(index: 0), animated: false)
        
        // Reset the mock call count.
        collectionView.calls = []
        collectionViewLayout.calls = []
        delegate.calls = []
      }
      
      it("reload data, updates the layout and selects the current item") {
        pagingController.transitionSize()
        
        // Combine the method calls for the collection view,
        // collection view layout and delegate to ensure that
        // they were called in the correct order.
        let actions = combinedActions(
          collectionView.calls,
          collectionViewLayout.calls,
          delegate.calls
        )
        
        expect(actions).to(equal(
          [
            .collectionView(.reloadData),
            .collectionViewLayout(.prepare),
            .collectionView(.contentOffset(.zero)),
            .collectionView(.layoutIfNeeded),
            .collectionView(.selectItem(
              indexPath: IndexPath(item: 0, section: 0),
              animated: false,
              scrollPosition: .left
            )),
            .collectionView(.contentOffset(.zero))
          ]
        ))
      }
      
      context("state is .selected") {
        it("does not updated the state") {
          pagingController.transitionSize()
          
          expect(pagingController.state).to(equal(
            .selected(pagingItem: Item(index: 0))
          ))
        }
      }
      
      context("state is .scrolling") {
        it("selects the current item") {
          // Simulate that the user scrolled to the next page.
          pagingController.contentScrolled(progress: 0.5)
          
          pagingController.transitionSize()
          
          expect(pagingController.state).to(equal(
            .selected(pagingItem: Item(index: 0))
          ))
        }
      }
    }
    
    // MARK: Reload data
    
    describe("reload data") {
      
      it("selects the paging item") {
        pagingController.reloadData(around: Item(index: 0))
        
        expect(pagingController.state).to(equal(
          .selected(pagingItem: Item(index: 0))
        ))
      }
      
      it("generates items around the paging item") {
        pagingController.reloadData(around: Item(index: 2))
        
        expect(pagingController.visibleItems.hasItemsBefore).to(beTrue())
        expect(pagingController.visibleItems.hasItemsAfter).to(beTrue())
        expect(pagingController.visibleItems.items as? [Item]).to(equal(
          [
            Item(index: 0),
            Item(index: 1),
            Item(index: 2),
            Item(index: 3),
            Item(index: 4)
          ]
        ))
        
        // Combine the method calls for the collection view,
        // collection view layout and delegate to ensure that
        // they were called in the correct order.
        let actions = combinedActions(
          collectionView.calls,
          collectionViewLayout.calls,
          delegate.calls
        )
        
        expect(actions).to(equal(
          [
            .collectionViewLayout(.invalidateLayout),
            .collectionView(.reloadData),
            .delegate(.removeContent),
            .delegate(.selectContent(
              pagingItem: Item(index: 2),
              direction: .none,
              animated: false
            )),
            .collectionViewLayout(.invalidateLayout)
          ]
        ))
      }
    }
    
    // MARK: Reload menu
    
    describe("reload menu") {
      
      it("selects the paging item") {
        pagingController.reloadMenu(around: Item(index: 0))
        
        expect(pagingController.state).to(equal(
          .selected(pagingItem: Item(index: 0))
        ))
      }
      
      it("generates items around the paging item") {
        pagingController.reloadMenu(around: Item(index: 2))
        
        expect(pagingController.visibleItems.hasItemsBefore).to(beTrue())
        expect(pagingController.visibleItems.hasItemsAfter).to(beTrue())
        expect(pagingController.visibleItems.items as? [Item]).to(equal(
          [
            Item(index: 0),
            Item(index: 1),
            Item(index: 2),
            Item(index: 3),
            Item(index: 4)
          ]
        ))
        
        // Combine the method calls for the collection view,
        // collection view layout and delegate to ensure that
        // they were called in the correct order.
        let actions = combinedActions(
          collectionView.calls,
          collectionViewLayout.calls,
          delegate.calls
        )
        
        expect(actions).to(equal(
          [
            .collectionViewLayout(.invalidateLayout),
            .collectionView(.reloadData)
          ]
        ))
      }
    }
    
  }
}

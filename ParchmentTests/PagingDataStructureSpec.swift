import Foundation
import Quick
import Nimble
@testable import Parchment

class PagingDataSpec: QuickSpec {
  
  override func spec() {
    
    describe("PagingData") {
      
      var visibleItems: PagingItems!
      
      beforeEach {
        visibleItems = PagingItems(items: [
          Item(index: 0),
          Item(index: 1),
          Item(index: 2)
        ])
      }
      
      describe("indexPathForPagingItem:") {
        
        it("returns the index path if the paging item exists") {
          let indexPath = visibleItems.indexPath(for: Item(index: 0))!
          expect(indexPath.item).to(equal(0))
        }
        
        it("returns nil if paging item is not in visible items") {
          let indexPath = visibleItems.indexPath(for: Item(index: -1))
          expect(indexPath).to(beNil())
        }
        
      }
      
      describe("pagingItemForIndexPath:") {
        it("returns the paging item for a given index path") {
          let indexPath = IndexPath(item: 0, section: 0)
          let pagingItem = visibleItems.pagingItem(for: indexPath) as! Item
          expect(pagingItem).to(equal(Item(index: 0)))
        }
      }
      
      describe("directionForIndexPath:currentPagingItem:") {
        
        describe("has a index path for the current paging item") {

          describe("upcoming index path is larger than current index path") {
            it("returns forward") {
              let currentPagingItem = Item(index: 0)
              let upcomingPagingItem = Item(index: 1)
              let direction = visibleItems.direction(from: currentPagingItem, to: upcomingPagingItem)
              expect(direction).to(equal(PagingDirection.forward(sibling: true)))
            }
          }
          
          describe("upcoming index path is smaller than current index path") {
            it("returns reverse") {
              let currentPagingItem = Item(index: 1)
              let upcomingPagingItem = Item(index: 0)
              let direction = visibleItems.direction(from: currentPagingItem, to: upcomingPagingItem)
              expect(direction).to(equal(PagingDirection.reverse(sibling: true)))
            }
          }
          
        }
        
        describe("does not have a index path for the current item") {
          it("returns none") {
            let currentPagingItem = Item(index: -1)
            let upcomingPagingItem = Item(index: 0)
            let direction = visibleItems.direction(from: currentPagingItem, to: upcomingPagingItem)
            expect(direction).to(equal(PagingDirection.none))
          }
        }
        
      }
      
    }
    
  }
  
}

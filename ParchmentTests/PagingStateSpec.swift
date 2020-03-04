import Foundation
import Quick
import Nimble
@testable import Parchment

class PagingStateSpec: QuickSpec {
  
  override func spec() {
    
    describe("PagingState") {
      
      describe("Scrolling") {
        
        it("returns the current paging item") {
          let state: PagingState = .scrolling(
            pagingItem: Item(index: 0),
            upcomingPagingItem: Item(index: 1),
            progress: 0,
            initialContentOffset: .zero,
            distance: 0)
          expect(state.currentPagingItem as! Item?).to(equal(Item(index: 0)))
        }
        
        it("returns the correct progress") {
          let state: PagingState = .scrolling(
            pagingItem: Item(index: 0),
            upcomingPagingItem: Item(index: 1),
            progress: 0.5,
            initialContentOffset: .zero,
            distance: 0)
          expect(state.progress).to(equal(0.5))
        }
        
        describe("has an upcoming paging item") {
          
          it("returns the correct upcoming paging item") {
            let state: PagingState = .scrolling(
              pagingItem: Item(index: 0),
              upcomingPagingItem: Item(index: 1),
              progress: 0,
              initialContentOffset: .zero,
              distance: 0)
            expect(state.upcomingPagingItem as! Item?).to(equal(Item(index: 1)))
          }
          
          describe("visuallySelectedPagingItem") {
            
            describe("progress is larger then 0.5") {
              it("returns the upcoming paging item as the visually selected item") {
                let state: PagingState = .scrolling(
                  pagingItem: Item(index: 0),
                  upcomingPagingItem: Item(index: 1),
                  progress: 0.6,
                  initialContentOffset: .zero,
                  distance: 0)
                expect(state.visuallySelectedPagingItem as! Item?).to(equal(Item(index: 1)))
              }
            }
            
            describe("progress is smaller then 0.5") {
              it("returns the current paging item as the visually selected item") {
                let state: PagingState = .scrolling(
                  pagingItem: Item(index: 0),
                  upcomingPagingItem: Item(index: 1),
                  progress: 0.3,
                  initialContentOffset: .zero,
                  distance: 0)
                expect(state.visuallySelectedPagingItem as! Item?).to(equal(Item(index: 0)))
              }
            }
            
          }
          
        }
        
        describe("does not have an upcoming paging item") {
          
          it("returns nil for upcoming paging item") {
            let state: PagingState = .scrolling(
              pagingItem: Item(index: 0),
              upcomingPagingItem: nil,
              progress: 0,
              initialContentOffset: .zero,
              distance: 0)
            expect(state.upcomingPagingItem).to(beNil())
          }
          
          describe("visuallySelectedPagingItem") {
            
            describe("progress is larger then 0.5") {
              it("returns the current paging item as the visually selected item") {
                let state: PagingState = .scrolling(
                  pagingItem: Item(index: 0),
                  upcomingPagingItem: nil,
                  progress: 0.6,
                  initialContentOffset: .zero,
                  distance: 0)
                expect(state.visuallySelectedPagingItem as! Item?).to(equal(Item(index: 0)))
              }
            }
            
            describe("progress is smaller then 0.5") {
              it("returns the current paging item as the visually selected item") {
                let state: PagingState = .scrolling(
                  pagingItem: Item(index: 0),
                  upcomingPagingItem: nil,
                  progress: 0.3,
                  initialContentOffset: .zero,
                  distance: 0)
                expect(state.visuallySelectedPagingItem as! Item?).to(equal(Item(index: 0)))
              }
            }
            
          }
        }
        
      }
      
      describe("Selected") {
        
        let state: PagingState = .selected(pagingItem: Item(index: 0))
        
        it("returns the current paging item") {
          expect(state.currentPagingItem as! Item?).to(equal(Item(index: 0)))
        }
        
        it("returns nil for the upcoming paging item") {
          expect(state.upcomingPagingItem).to(beNil())
        }
        
        it("returns zero for the progress") {
          expect(state.progress).to(equal(0))
        }
        
        it("returns the current paging item as the visually selected item") {
          expect(state.visuallySelectedPagingItem as! Item?).to(equal(Item(index: 0)))
        }
        
      }
    
    }
    
  }
  
}

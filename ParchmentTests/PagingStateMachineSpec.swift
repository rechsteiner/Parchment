/*
import Foundation
import Quick
import Nimble
@testable import Parchment

private func beScrolling() -> Predicate<PagingState<Item>> {
  return Predicate.define("be .Scrolling)") { expression, message in
    if let actual = try expression.evaluate(), case .scrolling = actual {
      return PredicateResult(bool: true, message: message)
    }
    return PredicateResult(bool: false, message: message)
  }
}

private func beSelected() -> Predicate<PagingState<Item>> {
  return Predicate.define("be .Selected)") { expression, message in
    if let actual = try expression.evaluate(), case .selected = actual {
      return PredicateResult(bool: true, message: message)
    }
    return PredicateResult(bool: false, message: message)
  }
}

class PagingStateMachineSpec: QuickSpec {
  
  override func spec() {
    
    describe("PagingStateMachine") {
      
      var stateMachine: PagingStateMachine<Item>!
      
      beforeEach {
        let state: PagingState = .selected(pagingItem: Item(index: 0))
        stateMachine = PagingStateMachine(initialState: state)
        
        stateMachine.pagingItemAfterItem = { item in
          return Item(index: item.index + 1)
        }
        
        stateMachine.pagingItemBeforeItem = { item in
          return Item(index: item.index - 1)
        }
        
        stateMachine.transitionFromItem = { from, to in
          return PagingTransition(contentOffset: .zero, distance: 0)
        }
      }
      
      describe("finish scrolling event") {
        
        describe("is in the selected state") {
          it("does not updated the state") {
            stateMachine.fire(.finishScrolling)
            let expectedState: PagingState = .selected(pagingItem: Item(index: 0))
            expect(stateMachine.state).to(equal(expectedState))
          }
        }
        
        describe("is in the scrolling state") {
          
          beforeEach {
            let state: PagingState = .scrolling(
              pagingItem: Item(index: 0),
              upcomingPagingItem: Item(index: 1),
              progress: 0.5,
              initialContentOffset: .zero,
              distance: 0)
            stateMachine = PagingStateMachine(initialState: state)
          }
          
          it("enters the selected state") {
            stateMachine.fire(.finishScrolling)
            expect(stateMachine.state).to(beSelected())
          }
          
          describe("has an upcoming paging item") {
            it("sets the selected item to equal the upcoming paging item") {
              stateMachine.fire(.finishScrolling)
              expect(stateMachine.state.currentPagingItem).to(equal(Item(index: 1)))
            }
          }
          
          describe("the upcoming paging item is nil") {
            
            beforeEach {
              let state: PagingState = .scrolling(
                pagingItem: Item(index: 0),
                upcomingPagingItem: nil,
                progress: 0.5,
                initialContentOffset: .zero,
                distance: 0)
              stateMachine = PagingStateMachine(initialState: state)
            }
            
            it("sets the selected item to equal the current paging item") {
              stateMachine.fire(.finishScrolling)
              expect(stateMachine.state.currentPagingItem).to(equal(Item(index: 0)))
            }
          }
          
        }
        
      }
      
      describe("transition size") {
        
        describe("is in the selected state") {
          it("does not updated the state") {
            stateMachine.fire(.transitionSize)
            let expectedState: PagingState = .selected(pagingItem: Item(index: 0))
            expect(stateMachine.state).to(equal(expectedState))
          }
        }
        
        describe("is in the scrolling state") {
          
          beforeEach {
            let state: PagingState = .scrolling(
              pagingItem: Item(index: 0),
              upcomingPagingItem: Item(index: 1),
              progress: 0.5,
              initialContentOffset: .zero,
              distance: 0)
            stateMachine = PagingStateMachine(initialState: state)
          }
          
          it("selects the current paging item") {
            stateMachine.fire(.transitionSize)
            expect(stateMachine.state).to(equal(PagingState.selected(pagingItem: Item(index: 0))))
          }
          
        }
        
      }
      
      describe("cancel scrolling") {
        
        describe("is in the selected state") {
          it("does not updated the state") {
            stateMachine.fire(.cancelScrolling)
            let expectedState: PagingState = .selected(pagingItem: Item(index: 0))
            expect(stateMachine.state).to(equal(expectedState))
          }
        }
        
        describe("is in the scrolling state") {
          
          beforeEach {
            let state: PagingState = .scrolling(
              pagingItem: Item(index: 0),
              upcomingPagingItem: Item(index: 1),
              progress: 0.5,
              initialContentOffset: .zero,
              distance: 0)
            stateMachine = PagingStateMachine(initialState: state)
          }
          
          it("selects the current paging item") {
            stateMachine.fire(.cancelScrolling)
            expect(stateMachine.state).to(equal(PagingState.selected(pagingItem: Item(index: 0))))
          }
          
        }
        
      }
      
      describe("select event") {
        
        describe("selected paging item is not equal current item") {
          
          describe("is in the scrolling state") {
            it("does not change the state") {
              
              let state: PagingState = .scrolling(
                pagingItem: Item(index: 0),
                upcomingPagingItem: nil,
                progress: 0,
                initialContentOffset: .zero,
                distance: 0)
              
              stateMachine = PagingStateMachine(initialState: state)
              
              stateMachine.fire(.select(
                pagingItem: Item(index: 1),
                direction: .none,
                animated: false))
              
              expect(stateMachine.state).to(equal(state))
            }
          }
          
          describe("is in the selected state") {
            
            it("enters the scrolling state") {
              stateMachine.fire(.select(
                pagingItem: Item(index: 1),
                direction: .none,
                animated: false))
              expect(stateMachine.state).to(beScrolling())
            }
            
            it("sets to progress to zero") {
              stateMachine.fire(.select(
                pagingItem: Item(index: 1),
                direction: .none,
                animated: false))
              expect(stateMachine.state.progress).to(equal(0))
            }
            
            it("uses the state's current paging item") {
              stateMachine.fire(.select(
                pagingItem: Item(index: 1),
                direction: .none,
                animated: false))
              expect(stateMachine.state.currentPagingItem).to(equal(Item(index: 0)))
            }
            
            it("sets the upcoming paging item to the selected paging item") {
              stateMachine.fire(.select(
                pagingItem: Item(index: 1),
                direction: .none,
                animated: false))
              expect(stateMachine.state.upcomingPagingItem).to(equal(Item(index: 1)))
            }
            
            describe("has a select block") {
              
              it("calls the select block with the selected paging item, direction and animation") {
                var selectedPagingItem: Item?
                var direction: PagingDirection?
                var animated: Bool?
                
                stateMachine.onPagingItemSelect = {
                  selectedPagingItem = $0
                  direction = $1
                  animated = $2
                }
                
                stateMachine.fire(.select(
                  pagingItem: Item(index: 1),
                  direction: .forward,
                  animated: false))
                
                expect(selectedPagingItem).to(equal(Item(index: 1)))
                expect(direction).to(equal(PagingDirection.forward))
                expect(animated).to(equal(false))
              }
              
            }
          }
        }
        
        describe("selected paging item is equal current item") {
          
          it("does not updated the state") {
            stateMachine.fire(.select(
              pagingItem: Item(index: 0),
              direction: .none,
              animated: false))
            let expectedState: PagingState = .selected(pagingItem: Item(index: 0))
            expect(stateMachine.state).to(equal(expectedState))
          }
          
          describe("has a select block") {
            
            it("does not call the select block") {
              var selectedPagingItem: Item?
              
              stateMachine.onPagingItemSelect = { pagingItem, _, _ in
                selectedPagingItem = pagingItem
              }
              
              stateMachine.fire(.select(
                pagingItem: Item(index: 0),
                direction: .none,
                animated: false))
              
              expect(selectedPagingItem).to(beNil())
            }
            
          }
          
        }
        
      }
      
      describe("scroll event") {
        
        it("uses the state's current paging item") {
          stateMachine.fire(.scroll(progress: 0))
          expect(stateMachine.state.currentPagingItem).to(equal(Item(index: 0)))
        }
        
        it("sets the new progress") {
          stateMachine.fire(.scroll(progress: 0.5))
          expect(stateMachine.state.progress).to(equal(0.5))
        }
        
        describe("is in the scrolling state") {
          
          describe("the sign of the progress value changed to negative") {
            it("resets the scrolling state") {
              let initialState: PagingState = .scrolling(
                pagingItem: Item(index: 0),
                upcomingPagingItem: Item(index: 1),
                progress: 0.1,
                initialContentOffset: .zero,
                distance: 0)
              stateMachine = PagingStateMachine(initialState: initialState)
              stateMachine.fire(.scroll(progress: -0.1))
              expect(stateMachine.state).to(beSelected())
            }
          }
          
          describe("the sign of the progress value changed to postive") {
            
            it("resets the scrolling state if the progress changes from negative to positive") {
              let initialState: PagingState = .scrolling(
                pagingItem: Item(index: 0),
                upcomingPagingItem: Item(index: 1),
                progress: -0.1,
                initialContentOffset: .zero,
                distance: 0)
              stateMachine = PagingStateMachine(initialState: initialState)
              stateMachine.fire(.scroll(progress: 0.1))
              expect(stateMachine.state).to(beSelected())
            }
            
          }
          
          describe("the sign of the progress didn't change") {
            
            it("resets the scrolling state if the progress is zero") {
              let initialState: PagingState = .scrolling(
                pagingItem: Item(index: 0),
                upcomingPagingItem: Item(index: 1),
                progress: 0.5,
                initialContentOffset: .zero,
                distance: 0)
              stateMachine = PagingStateMachine(initialState: initialState)
              stateMachine.fire(.scroll(progress: 0))
              expect(stateMachine.state).to(beSelected())
            }
            
            it("uses the state's upcoming paging item if the progress is not zero") {
              let initialState: PagingState = .scrolling(
                pagingItem: Item(index: 0),
                upcomingPagingItem: Item(index: 1),
                progress: 0,
                initialContentOffset: .zero,
                distance: 0)
              stateMachine = PagingStateMachine(initialState: initialState)
              stateMachine.fire(.scroll(progress: 0.1))
              expect(stateMachine.state.upcomingPagingItem).to(equal(Item(index: 1)))
            }
            
          }
          
        }
        
        describe("is in the selected state") {
          
          it("it does not update the state if the progress is zero") {
            stateMachine.fire(.scroll(progress: 0))
            let expectedState: PagingState = .selected(pagingItem: Item(index: 0))
            expect(stateMachine.state).to(equal(expectedState))
          }
          
          it("uses the leading paging item if the progress is negative") {
            stateMachine.fire(.scroll(progress: -0.1))
            expect(stateMachine.state.upcomingPagingItem).to(equal(Item(index: -1)))
          }
          
          it("uses the trailing paging item if the progress is positive") {
            stateMachine.fire(.scroll(progress: 0.1))
            expect(stateMachine.state.upcomingPagingItem).to(equal(Item(index: 1)))
          }
          
        }
    
      }
      
    }
    
  }
  
}
*/

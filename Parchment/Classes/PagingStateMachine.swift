import Foundation
import UIKit

class PagingStateMachine<T: PagingItem> where T: Equatable {
  
  var onPagingItemSelect: ((T, PagingDirection, Bool) -> Void)?
  var onStateChange: ((PagingState<T>, PagingState<T>, PagingEvent<T>?) -> Void)?
  var pagingItemBeforeItem: ((T) -> T?)?
  var pagingItemAfterItem: ((T) -> T?)?
  var transitionFromItem: ((T, T?) -> PagingTransition)?
  
  private(set) var state: PagingState<T>
  
  init(initialState: PagingState<T>) {
    self.state = initialState
  }
  
  func fire(_ event: PagingEvent<T>) {
    switch event {
    case let .reload(contentOffset):
      handleReloadEvent(contentOffset: contentOffset, event)
    case let .scroll(progress):
      handleScrollEvent(
        event,
        progress: progress)
    case let .initial(pagingItem):
      handleInitialEvent(event, pagingItem: pagingItem)
    case let .select(pagingItem, direction, animated):
      handleSelectEvent(
        event,
        selectedPagingItem: pagingItem,
        direction: direction,
        animated: animated)
    case .finishScrolling:
      handleFinishScrollingEvent(event)
    case .transitionSize:
      handleTransitionSizeEvent(event)
    case .cancelScrolling:
      handleCancelScrollingEvent(event)
    case .removeAll:
      handleRemoveAllEvent(event)
    case let .reset(pagingItem):
      handleResetEvent(event, pagingItem: pagingItem)
    }
  }
  
  private func handleReloadEvent(contentOffset: CGPoint, _ event: PagingEvent<T>) {
    let oldState = state
    if case let .scrolling(pagingItem, upcomingPagingItem, progress, _, distance) = state {
      if let transition = transitionFromItem?(pagingItem, upcomingPagingItem) {
      
        let newContentOffset = CGPoint(
          x: contentOffset.x - (distance - transition.distance),
          y: contentOffset.y)
        
        state = .scrolling(
          pagingItem: pagingItem,
          upcomingPagingItem: upcomingPagingItem,
          progress: progress,
          initialContentOffset: newContentOffset,
          distance: distance)
        
        onStateChange?(oldState, state, event)
      }
    }
  }
  
  private func handleScrollEvent(_ event: PagingEvent<T>, progress: CGFloat) {
    let oldState = state
    
    switch state {
    case .empty:
      return
    case let .scrolling(pagingItem, upcomingPagingItem, oldProgress, initialContentOffset, distance):
      if oldProgress < 0 && progress > 0 {
        state = .selected(pagingItem: pagingItem)
      } else if oldProgress > 0 && progress < 0 {
        state = .selected(pagingItem: pagingItem)
      } else if progress == 0 {
        state = .selected(pagingItem: pagingItem)
      } else {
        state = .scrolling(
          pagingItem: pagingItem,
          upcomingPagingItem: upcomingPagingItem,
          progress: progress,
          initialContentOffset: initialContentOffset,
          distance: distance)
        
        onStateChange?(oldState, state, event)
      }
    case let .selected(pagingItem):
      if progress > 0 {
        let upcomingPagingItem = pagingItemAfterItem?(pagingItem)
        if let transition = transitionFromItem?(pagingItem, upcomingPagingItem) {
          state = .scrolling(
            pagingItem: pagingItem,
            upcomingPagingItem: upcomingPagingItem,
            progress: progress,
            initialContentOffset: transition.contentOffset,
            distance: transition.distance)
          
          onStateChange?(oldState, state, event)
        }
      } else if progress < 0 {
        let upcomingPagingItem = pagingItemBeforeItem?(pagingItem)
        if let transition = transitionFromItem?(pagingItem, upcomingPagingItem) {
          state = .scrolling(
            pagingItem: pagingItem,
            upcomingPagingItem: upcomingPagingItem,
            progress: progress,
            initialContentOffset: transition.contentOffset,
            distance: transition.distance)
          
          onStateChange?(oldState, state, event)
        }
      }
    }
  }
  
  private func handleInitialEvent(_ event: PagingEvent<T>, pagingItem: T) {
    let oldState = state
    state = .selected(pagingItem: pagingItem)
    onStateChange?(oldState, state, event)
  }
  
  private func handleSelectEvent(_ event: PagingEvent<T>, selectedPagingItem: T, direction: PagingDirection, animated: Bool) {
    let oldState = state

    switch state {
    case .empty:
      state = .selected(pagingItem: selectedPagingItem)
      onStateChange?(oldState, state, event)
    default:
      if let currentPagingItem = state.currentPagingItem {
        if selectedPagingItem != state.currentPagingItem {
          if case .selected = state {
            if let transition = transitionFromItem?(currentPagingItem, selectedPagingItem) {
              state = .scrolling(
                pagingItem: currentPagingItem,
                upcomingPagingItem: selectedPagingItem,
                progress: 0,
                initialContentOffset: transition.contentOffset,
                distance: transition.distance)
              
              onPagingItemSelect?(selectedPagingItem, direction, animated)
              onStateChange?(oldState, state, event)
            }
          }
        }
      }
    }
  }
  
  private func handleFinishScrollingEvent(_ event: PagingEvent<T>) {
    let oldState = state
    switch state {
    case let .scrolling(currentPagingItem, upcomingPagingItem, _, _, _):
      state = .selected(pagingItem: upcomingPagingItem ?? currentPagingItem)
      onStateChange?(oldState, state, event)
    case .selected, .empty:
      break
    }
  }
  
  private func handleTransitionSizeEvent(_ event: PagingEvent<T>) {
    let oldState = state
    switch state {
    case let .scrolling(currentPagingItem, _, _, _, _):
      state = .selected(pagingItem: currentPagingItem)
      onStateChange?(oldState, state, event)
    case .selected, .empty:
      break
    }
  }
  
  private func handleCancelScrollingEvent(_ event: PagingEvent<T>) {
    let oldState = state
    switch state {
    case let .scrolling(currentPagingItem, _, _, _, _):
      state = .selected(pagingItem: currentPagingItem)
      onStateChange?(oldState, state, event)
    case .selected, .empty:
      break
    }
  }
  
  private func handleRemoveAllEvent(_ event: PagingEvent<T>) {
    let oldState = state
    state = .empty
    onStateChange?(oldState, state, event)
  }
  
  private func handleResetEvent(_ event: PagingEvent<T>, pagingItem: T) {
    let oldState = state
    state = .selected(pagingItem: pagingItem)
    onStateChange?(oldState, state, event)
  }
}

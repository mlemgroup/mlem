//
//  ChildTracker.swift
//  Mlem
//
//  Created by Eric Andrews on 2023-10-16.
//

import Foundation

class ChildTracker<Item: ChildTrackerItem>: BasicTracker<Item>, ChildTrackerProtocol {
    private var parentTracker: ParentTracker<Item.ParentType>?
    private var cursor: Int = 0
    
    func setParentTracker(_ newParent: ParentTracker<Item.ParentType>) {
        parentTracker = newParent
    }
    
    func consumeNextItem() -> Item.ParentType? {
        assert(cursor < items.count, "consumeNextItem called on a tracker without a next item!")
        
        if cursor < items.count {
            cursor += 1
            return items[cursor - 1].toParent()
        }
        
        return nil
    }
    
    func nextItemSortVal(sortType: TrackerSortType) async throws -> TrackerSortVal? {
        assert(sortType == self.sortType, "Conflicting types for sortType! This will lead to unexpected sorting behavior.")
        
        if cursor < items.count {
            return items[cursor].sortVal(sortType: sortType)
        } else {
            // if done loading, return nil
            if loadingState == .done {
                print("done loading!")
                return nil
            }
            
            // otherwise, wait for the next page to load and try to return the first value
            // if the next page is already loading, this call to loadNextPage will be noop, but still wait until that load completes thanks to the semaphore
            try await loadPage(page + 1, clearBeforeReset: false)
            return cursor < items.count ? items[cursor].sortVal(sortType: sortType) : nil
        }
    }
}

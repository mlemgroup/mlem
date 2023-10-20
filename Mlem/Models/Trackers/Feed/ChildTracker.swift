//
//  ChildTracker.swift
//  Mlem
//
//  Created by Eric Andrews on 2023-10-16.
//
import Foundation

class ChildTracker<Item: ChildTrackerItem>: BasicTracker<Item>, ChildTrackerProtocol, ObservableObject {
    private weak var parentTracker: (any ParentTrackerProtocol)?
    private var cursor: Int = 0

    func setParentTracker(_ newParent: any ParentTrackerProtocol) {
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
            try await loadPage(page + 1, clearBeforeRefresh: false)
            return cursor < items.count ? items[cursor].sortVal(sortType: sortType) : nil
        }
    }

    func refresh(clearBeforeRefresh: Bool, notifyParent: Bool = true) async throws {
        try await refresh(clearBeforeRefresh: clearBeforeRefresh)
        cursor = 0

        if notifyParent, let parentTracker {
            print("refreshing parent tracker")
            await parentTracker.refresh(clearBeforeFetch: clearBeforeRefresh)
        }
    }

    func reset(notifyParent: Bool = true) async {
        await reset()
        cursor = 0
        if notifyParent, let parentTracker {
            print("resetting parent tracker")
            await parentTracker.reset()
        }
    }
}

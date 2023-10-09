//
//  InboxSubTracker.swift
//  Mlem
//
//  Created by Eric Andrews on 2023-09-23.
//
import Foundation

/// Protocol for trackers that can feed the inbox tracker
protocol InboxFeedSubTracker {
    /// Returns the sorting value for the next item
    /// - Parameter sortType: InboxSortType the values should be sorted by. This MUST agree with this tracker's sortType field!
    /// - Returns: InboxSortVal? containing the next item's sort value if present, nil otherwise
    func nextItemSortVal(sortType: InboxSortType) -> StreamItem<InboxSortVal>

    /// Returns the next item and increments the cursor
    /// - Returns: next item if present, nil otherwise
    func consumeNextItem() -> StreamItem<InboxItemNew>
}

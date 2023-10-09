//
//  RepliesTrackerNew.swift
//  Mlem
//
//  Created by Eric Andrews on 2023-09-23.
//
import Foundation

class RepliesTrackerNew: ObservableObject, InboxFeedSubTracker {
    @Published var replies: [ReplyModel] = .init()
    private var isLoading: Bool = false

    /// Parent tracker. If present, will be updated when this tracker is updated
    var parentTracker: InboxTrackerNew?

    /// Index of the first non-consumed item in mentions
    private var cursor: Int = 0

    private let sortType: InboxSortType = .published

    /// Returns the sorting value for the next item
    /// - Parameter sortType: InboxSortType the values should be sorted by. This MUST agree with this tracker's sortType field!
    /// - Returns: InboxSortVal? containing the next item's sort value if present, nil otherwise
    func nextItemSortVal(sortType: InboxSortType) -> StreamItem<InboxSortVal> {
        assert(sortType == self.sortType, "Conflicting types for sortType! This will lead to unexpected sorting behavior.")

        if cursor < replies.count {
            return .present(replies[cursor].getInboxSortVal(sortType: sortType))
        } else if isLoading {
            return .loading
        } else {
            print("no more replies")
            return .absent
        }
    }

    func consumeNextItem() -> StreamItem<InboxItemNew> {
        if cursor < replies.count {
            cursor += 1
            return .present(InboxItemNew.reply(replies[cursor - 1]))
        } else if isLoading {
            return .loading
        } else {
            print("no more replies")
            return .absent
        }
    }
}

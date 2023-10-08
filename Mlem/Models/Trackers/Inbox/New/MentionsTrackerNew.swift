//
//  MentionsTrackerNew.swift
//  Mlem
//
//  Created by Eric Andrews on 2023-09-23.
//
import Foundation

class MentionsTrackerNew: ObservableObject, InboxFeedSubTracker {
    @Published var mentions: [MentionModel] = .init()

    /// Parent tracker. If present, will be updated when this tracker is updated
    var parentTracker: InboxTrackerNew?

    /// Index of the first non-consumed item in mentions
    private var cursor: Int = 0

    private let sortType: InboxSortType = .published

    /// Returns the sorting value for the next item
    /// - Parameter sortType: InboxSortType the values should be sorted by. This MUST agree with this tracker's sortType field!
    /// - Returns: InboxSortVal? containing the next item's sort value if present, nil otherwise
    func nextItemSortVal(sortType: InboxSortType) -> InboxSortVal? {
        assert(sortType == self.sortType, "Conflicting types for sortType! This will lead to unexpected sorting behavior.")

        if cursor < mentions.count {
            return mentions[cursor].getInboxSortVal(sortType: sortType)
        }
        print("no more replies")
        return nil
    }

    func consumeNextItem() -> InboxItemNew? {
        if cursor < mentions.count {
            cursor += 1
            return InboxItemNew.mention(mentions[cursor - 1])
        }
        print("no more mentions")
        return nil
    }
}

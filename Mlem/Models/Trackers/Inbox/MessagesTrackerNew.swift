//
//  MessagesTrackerNew.swift
//  Mlem
//
//  Created by Eric Andrews on 2023-09-23.
//

import Foundation

class MessagesTrackerNew: ObservableObject, InboxFeedSubTracker {
    @Published var messages: [MessageModel] = .init()
    
    /// Index of the first non-consumed item in messages
    private var cursor: Int = 0
    
    // MARK: multi-feed support methods
    
    // TODO: dynamic loading
    
    private let sortType: InboxSortType = .published
    
    func nextItemSortVal(sortType: InboxSortType) -> InboxSortVal? {
        assert(sortType == self.sortType, "Conflicting types for sortType! This will lead to unexpected sorting behavior.")
        
        if cursor < messages.count {
            return messages[cursor].getInboxSortVal(sortType: sortType)
        }
        print("no more replies")
        return nil
    }
    
    func consumeNextItem() -> InboxItemNew? {
        if cursor < messages.count {
            cursor += 1
            return InboxItemNew.message(messages[cursor - 1])
        }
        print("no more messages")
        return nil
    }
    
    // refresh
    
    // filter
    
    // update
    
    // load page
    
    // reply
}

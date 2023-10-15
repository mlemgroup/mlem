//
//  InboxTrackerTypes.swift
//  Mlem
//
//  Created by Eric Andrews on 2023-10-14.
//

import Foundation

enum InboxParentTrackerItem: ParentTrackerItem {
    typealias ChildType = InboxChildTrackerItem
    
    typealias SortType = InboxSortType
    
    typealias SortVal = InboxSortVal
    
    case message(MessageModel)
    case mention(MentionModel)
    case reply(ReplyModel)
    
    func sortVal(sortType: InboxSortType) -> InboxSortVal {
        switch sortType {
        case .published:
            switch self {
            case let .message(message):
                return .published(message.privateMessage.published)
            case let .mention(mention):
                return .published(mention.personMention.published)
            case let .reply(reply):
                return .published(reply.commentReply.published)
            }
        }
    }
    
    var uid: ContentModelIdentifier {
        switch self {
        case let .message(message):
            return message.uid
        case let .mention(mention):
            return mention.uid
        case let .reply(reply):
            return reply.uid
        }
    }
}

class InboxChildTrackerItem: ChildTrackerItem {
    typealias ParentItem = InboxParentTrackerItem
    
    var uid: ContentModelIdentifier
    
    /// Dummy initializer. **DO NOT** instantiate this class directly! Use one of its inheritors below.
    init() {
        self.uid = .init(contentType: .mention, contentId: 0)
    }
    
    func toParentItem() -> InboxParentTrackerItem {
        assertionFailure("must be overridden by inheriting class")
        return .message(MessageModel())
    }
    
    func getSortVal(sortType: InboxSortType) -> InboxSortVal {
        assertionFailure("must be overridden by inheriting class")
        return .published(Date())
    }
}

class InboxMessage: InboxChildTrackerItem {
    private var message: MessageModel
    
    init(message: MessageModel) {
        // internal
        self.message = message
        
        // super
        super.init()
        self.uid = message.uid
    }
    
    override func toParentItem() -> InboxParentTrackerItem {
        .message(message)
    }
    
    override func getSortVal(sortType: InboxSortType) -> InboxSortVal {
        switch sortType {
        case .published:
            return .published(message.privateMessage.published)
        }
    }
}

class InboxMention: InboxChildTrackerItem {
    private var mention: MentionModel
    
    init(mention: MentionModel) {
        // internal
        self.mention = mention
        
        // super
        super.init()
        self.uid = mention.uid
    }
    
    override func toParentItem() -> InboxParentTrackerItem {
        .mention(mention)
    }
    
    override func getSortVal(sortType: InboxSortType) -> InboxSortVal {
        switch sortType {
        case .published:
            return .published(mention.personMention.published)
        }
    }
}

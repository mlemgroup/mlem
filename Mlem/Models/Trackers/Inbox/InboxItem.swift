//
//  InboxItem.swift
//  Mlem
//
//  Created by Eric Andrews on 2023-06-26.
//

import Foundation
import SwiftUI

protocol InboxItem: Identifiable, ContentIdentifiable, TrackerItem {
    var published: Date { get }
    var uid: ContentModelIdentifier { get }
    var creatorId: Int { get }
    var banStatusCreatorId: Int { get }
    var commentCreatorBannedFromCommunity: Bool { get }
    var read: Bool { get }
    var id: Int { get }
    
    func toAnyInboxItem() -> AnyInboxItem
    
    func setCreatorBannedFromCommunity(_ newBanned: Bool)
}

enum AnyInboxItem: InboxItem {
    case reply(ReplyModel)
    case mention(MentionModel)
    case message(MessageModel)
    case commentReport(CommentReportModel)
    case postReport(PostReportModel)
    
    var value: any InboxItem {
        switch self {
        case let .reply(reply):
            return reply
        case let .mention(mention):
            return mention
        case let .message(message):
            return message
        case let .commentReport(commentReport):
            return commentReport
        case let .postReport(postReport):
            return postReport
        }
    }
    
    var published: Date { value.published }
    
    var uid: ContentModelIdentifier { value.uid }
    
    var creatorId: Int { value.creatorId }
    
    var banStatusCreatorId: Int { value.banStatusCreatorId }
    
    var commentCreatorBannedFromCommunity: Bool {
        get { value.commentCreatorBannedFromCommunity }
        set { value.setCreatorBannedFromCommunity(newValue) }
    }
    
    var read: Bool { value.read }
    
    var id: Int { value.id }
    
    func sortVal(sortType: TrackerSortVal.Case) -> TrackerSortVal { value.sortVal(sortType: sortType) }
    
    func toAnyInboxItem() -> AnyInboxItem { self }
    
    func setCreatorBannedFromCommunity(_ newBanned: Bool) {
        value.setCreatorBannedFromCommunity(newBanned)
    }
}

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
    var read: Bool { get }
    var id: Int { get }
}

enum AnyInboxItem: InboxItem {
    case reply(ReplyModel)
    case mention(MentionModel)
    case message(MessageModel)
    case commentReport(CommentReportModel)
    
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
        }
    }
    
    var published: Date { value.published }
    
    var uid: ContentModelIdentifier { value.uid }
    
    var creatorId: Int { value.creatorId }
    
    var read: Bool { value.read }
    
    var id: Int { value.id }
    
    func sortVal(sortType: TrackerSortType) -> TrackerSortVal { value.sortVal(sortType: sortType) }
}

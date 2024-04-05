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
    var creatorBannedFromInstance: Bool { get }
    var creatorBannedFromCommunity: Bool { get }
    var read: Bool { get }
    var id: Int { get }
    
    func toAnyInboxItem() -> AnyInboxItem
    
    func setCreatorBannedFromCommunity(_ newBanned: Bool)
    func setCreatorBannedFromInstance(_ newBanned: Bool)
}

enum AnyInboxItem: InboxItem {
    case reply(ReplyModel)
    case mention(MentionModel)
    case message(MessageModel)
    case commentReport(CommentReportModel)
    case postReport(PostReportModel)
    case messageReport(MessageReportModel)
    case registrationApplication(RegistrationApplicationModel)
    
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
        case let .messageReport(messageReport):
            return messageReport
        case let .registrationApplication(application):
            return application
        }
    }
    
    var published: Date { value.published }
    
    var uid: ContentModelIdentifier { value.uid }
    
    var creatorId: Int { value.creatorId }
    
    var banStatusCreatorId: Int { value.banStatusCreatorId }
    
    var creatorBannedFromCommunity: Bool { value.creatorBannedFromCommunity }
    
    var creatorBannedFromInstance: Bool { value.creatorBannedFromInstance }
    
    var read: Bool { value.read }
    
    var id: Int { value.id }
    
    func sortVal(sortType: TrackerSortVal.Case) -> TrackerSortVal { value.sortVal(sortType: sortType) }
    
    func toAnyInboxItem() -> AnyInboxItem { self }
    
    func setCreatorBannedFromCommunity(_ newBanned: Bool) {
        value.setCreatorBannedFromCommunity(newBanned)
    }
    
    func setCreatorBannedFromInstance(_ newBanned: Bool) {
        value.setCreatorBannedFromInstance(newBanned)
    }
}

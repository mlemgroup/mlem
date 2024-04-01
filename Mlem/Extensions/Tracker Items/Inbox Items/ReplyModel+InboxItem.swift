//
//  ReplyModel+InboxItem.swift
//  Mlem
//
//  Created by Eric Andrews on 2023-10-16.
//
import Foundation

extension ReplyModel: InboxItem {
    typealias ParentType = AnyInboxItem
    
    var published: Date { commentReply.published }
    
    var creatorId: Int { comment.creatorId }
    
    var banStatusCreatorId: Int { comment.creatorId }
    
    func toAnyInboxItem() -> AnyInboxItem { .reply(self) }
    
    @MainActor
    func setCreatorBannedFromCommunity(_ newBanned: Bool) {
        creatorBannedFromCommunity = newBanned
    }
}

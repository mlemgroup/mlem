//
//  MentionModel+InboxItem.swift
//  Mlem
//
//  Created by Eric Andrews on 2023-10-20.
//

import Foundation

extension MentionModel: InboxItem {
    typealias ParentType = AnyInboxItem
    
    var published: Date { personMention.published }
    
    var creatorId: Int { comment.creatorId }
    
    var banStatusCreatorId: Int { comment.creatorId }
    
    var creatorBannedFromCommunity: Bool { commentCreatorBannedFromCommunity }
    
    var creatorBannedFromInstance: Bool { creator.banned }
    
    func toAnyInboxItem() -> AnyInboxItem { .mention(self) }
    
    @MainActor
    func setCreatorBannedFromCommunity(_ newBanned: Bool) {
        commentCreatorBannedFromCommunity = newBanned
    }
    
    @MainActor
    func setCreatorBannedFromInstance(_ newBanned: Bool) {
        creator.banned = newBanned
    }
}

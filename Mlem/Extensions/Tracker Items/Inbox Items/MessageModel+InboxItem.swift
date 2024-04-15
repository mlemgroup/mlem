//
//  MessageModel+InboxItem.swift
//  Mlem
//
//  Created by Eric Andrews on 2023-10-16.
//
import Foundation

extension MessageModel: InboxItem {
    typealias ParentType = AnyInboxItem
    
    var published: Date { privateMessage.published }
    
    var creatorId: Int { privateMessage.creatorId }
    
    var banStatusCreatorId: Int { privateMessage.creatorId }
    
    var creatorBannedFromCommunity: Bool { false }
    
    var creatorBannedFromInstance: Bool { creator.banned }
    
    var read: Bool { privateMessage.read || siteInformation.userId == privateMessage.creatorId }
    
    func toAnyInboxItem() -> AnyInboxItem { .message(self) }
    
    @MainActor
    func setCreatorBannedFromCommunity(_ newBanned: Bool) {
        // noop
    }
    
    @MainActor
    func setCreatorBannedFromInstance(_ newBanned: Bool) {
        creator.banned = newBanned
    }
}

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
    
    var read: Bool { privateMessage.read }
    
    func toAnyInboxItem() -> AnyInboxItem { .message(self) }
    
    func setCreatorBannedFromCommunity(_ newBanned: Bool) {}
}

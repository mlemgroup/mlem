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
    
    // swiftlint:disable:next unused_setter_value
    var commentCreatorBannedFromCommunity: Bool { get { false } set {} }
    
    var read: Bool { privateMessage.read }
    
    func toAnyInboxItem() -> AnyInboxItem { .message(self) }
    
    func setCreatorBannedFromCommunity(_ newBanned: Bool) {}
}

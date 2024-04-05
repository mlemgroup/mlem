//
//  MessageReportModel+InboxItem.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-04-04.
//

import Foundation

extension MessageReportModel: InboxItem {
    typealias ParentType = AnyInboxItem
    
    var published: Date { messageReport.published }
    
    var creatorId: Int { messageReport.creatorId }
    
    var banStatusCreatorId: Int { messageCreator.userId }
    
    var creatorBannedFromCommunity: Bool { false }
    
    var read: Bool { messageReport.resolved }
    
    var id: Int { messageReport.id }
    
    func toAnyInboxItem() -> AnyInboxItem { .messageReport(self) }
    
    func setCreatorBannedFromCommunity(_ newBanned: Bool) {
        // noop
    }
}

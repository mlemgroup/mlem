//
//  PostReportModel+InboxItem.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-04-04.
//

import Foundation

extension PostReportModel: InboxItem {
    typealias ParentType = AnyInboxItem
    
    var published: Date { postReport.published }
    
    var creatorId: Int { reporter.userId }
    
    var banStatusCreatorId: Int { post.creatorId }
    
    var read: Bool { postReport.resolved }
    
    var id: Int { postReport.id }
    
    func toAnyInboxItem() -> AnyInboxItem { .postReport(self) }
    
    var creatorBannedFromCommunity: Bool { postCreatorBannedFromCommunity }
    
    func setCreatorBannedFromCommunity(_ newBanned: Bool) {
        postCreatorBannedFromCommunity = newBanned
    }
}

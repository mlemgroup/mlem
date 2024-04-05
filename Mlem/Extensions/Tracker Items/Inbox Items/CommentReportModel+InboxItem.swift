//
//  CommentReportModel+InboxItem.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-03-27.
//

import Foundation

extension CommentReportModel: InboxItem {
    typealias ParentType = AnyInboxItem
    
    var published: Date { commentReport.published }
    
    var creatorId: Int { reporter.userId }
    
    var banStatusCreatorId: Int { comment.creatorId }
    
    var creatorBannedFromCommunity: Bool { commentCreatorBannedFromCommunity }
    
    var read: Bool { commentReport.resolved }
    
    var id: Int { commentReport.id }
    
    func toAnyInboxItem() -> AnyInboxItem { .commentReport(self) }
    
    @MainActor
    func setCreatorBannedFromCommunity(_ newBanned: Bool) {
        commentCreatorBannedFromCommunity = newBanned
    }
}

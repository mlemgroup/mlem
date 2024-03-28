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
    
    var read: Bool { commentReport.resolved }
    
    var id: Int { commentReport.id }
}

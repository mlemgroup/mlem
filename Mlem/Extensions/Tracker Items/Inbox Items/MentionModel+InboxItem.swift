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
}

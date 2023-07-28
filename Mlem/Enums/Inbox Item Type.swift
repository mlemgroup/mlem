//
//  Inbox Item Types.swift
//  Mlem
//
//  Created by Eric Andrews on 2023-06-26.
//

import Foundation

enum InboxItemType {
    case mention(APIPersonMentionView)
    case message(APIPrivateMessageView)
    case reply(APICommentReplyView)
    
    var hasherId: Int {
        if case .mention(let _) = self {
            return 0
        } else if case .message(let _) = self {
            return 1
        } else if case .reply(let _) = self {
            return 2
        } else {
            assertionFailure("Unhandled InboxItemType")
            return -1
        }
    }
}

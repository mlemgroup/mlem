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
        switch self {
        case .mention:
            return 0
        case .message:
            return 1
        case .reply:
            return 2
        }
    }
}

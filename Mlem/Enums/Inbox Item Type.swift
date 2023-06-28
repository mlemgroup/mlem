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
}

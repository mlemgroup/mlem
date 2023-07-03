//
//  ReplyToProtocol.swift
//  Mlem
//
//  Created by Eric Andrews on 2023-07-03.
//

import Foundation
import SwiftUI

/**
 Protocol for things that can be replied to with comments, used to make CommentComposerView generic
 */
protocol ReplyToWithComment {
    func embeddedView() -> any View
    
    func sendReply(account: SavedAccount, tracker: FeedTracker<APICommentView>) async
}

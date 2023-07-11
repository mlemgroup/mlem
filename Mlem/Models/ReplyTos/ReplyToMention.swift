//
//  ReplyToMention.swift
//  Mlem
//
//  Created by Eric Andrews on 2023-07-03.
//

import Foundation
import SwiftUI

struct ReplyToMention: ReplyTo {
    let mention: APIPersonMentionView
    let account: SavedAccount
    let appState: AppState
    
    func embeddedView() -> AnyView {
        return AnyView(InboxMentionView(account: account,
                                        mention: mention,
                                        menuFunctions: [])
            .padding(.horizontal))
    }
    
    func sendReply(commentContents: String) async throws {
        try await postCommentWithoutTracker(postId: mention.post.id,
                                            commentId: mention.comment.id,
                                            commentContents: commentContents,
                                            account: account,
                                            appState: appState)
    }
}

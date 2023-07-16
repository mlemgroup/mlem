//
//  ReplyToMention.swift
//  Mlem
//
//  Created by Eric Andrews on 2023-07-03.
//

import Foundation
import SwiftUI

struct ReplyToMention: Respondable {
    
    var id: Int { mention.id }
    let appState: AppState
    let canUpload: Bool = true
    let modalName: String = "New Comment"
    let mention: APIPersonMentionView
    
    func embeddedView() -> AnyView {
        return AnyView(InboxMentionView(mention: mention,
                                        menuFunctions: [])
            .padding(.horizontal))
    }
    
    func sendResponse(responseContents: String) async throws {
        try await postCommentWithoutTracker(postId: mention.post.id,
                                            commentId: mention.comment.id,
                                            commentContents: responseContents,
                                            account: appState.currentActiveAccount,
                                            appState: appState)
    }
}

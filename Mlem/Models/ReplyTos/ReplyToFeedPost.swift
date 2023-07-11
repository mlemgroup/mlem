//
//  ReplyToPost.swift
//  Mlem
//
//  Created by Eric Andrews on 2023-07-03.
//

import Foundation
import SwiftUI

struct ReplyToFeedPost: ReplyTo {
    
    @EnvironmentObject var appState: AppState
    
    let post: APIPostView
    
    func embeddedView() -> AnyView {
        return AnyView(LargePost(postView: post, isExpanded: true)
            .padding(.horizontal))
    }
    
    func sendReply(commentContents: String) async throws {
        try await postCommentWithoutTracker(
            postId: post.post.id,
            commentId: nil,
            commentContents: commentContents,
            account: appState.currentActiveAccount,
            appState: appState)
    }
}

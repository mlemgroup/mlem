//
//  ReplyToPost.swift
//  Mlem
//
//  Created by Eric Andrews on 2023-07-03.
//

import Foundation
import SwiftUI

struct ReplyToFeedPost: Respondable {
    
    var id: Int { post.id }
    let appState: AppState
    let canUpload: Bool = true
    let modalName: String = "New Comment"
    let post: APIPostView
    
    func embeddedView() -> AnyView {
        return AnyView(LargePost(postView: post, isExpanded: true)
            .padding(.horizontal))
    }
    
    func sendResponse(responseContents: String) async throws {
        try await postCommentWithoutTracker(
            postId: post.post.id,
            commentId: nil,
            commentContents: responseContents,
            account: appState.currentActiveAccount,
            appState: appState)
    }
}

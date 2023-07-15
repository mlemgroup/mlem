//
//  ReplyToPost.swift
//  Mlem
//
//  Created by Eric Andrews on 2023-07-15.
//

import Foundation
import SwiftUI

struct ReplyToExpandedPost: Respondable {
    
    var id: Int { post.id }
    let appState: AppState
    let canUpload: Bool = true
    let modalName: String = "New Comment"
    let post: APIPostView
    let commentTracker: CommentTracker
    
    func embeddedView() -> AnyView {
        return AnyView(ExpandedPost(post: post)
            .padding(.horizontal))
    }
    
    func sendResponse(responseContents: String) async throws {
        try await postComment(to: post,
                              commentContents: responseContents,
                              commentTracker: commentTracker,
                              account: appState.currentActiveAccount,
                              appState: appState)
    }
}

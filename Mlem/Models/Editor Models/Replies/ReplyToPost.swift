//
//  ReplyToPost.swift
//  Mlem
//
//  Created by Eric Andrews on 2023-07-24.
//

import Foundation
import SwiftUI
import Dependencies

struct ReplyToPost: EditorModel {
    
    @Dependency(\.commentRepository) var commentRepository
    
    let appState: AppState
    let canUpload: Bool = true
    let modalName: String = "New Comment"
    let prefillContents: String?
    let commentTracker: CommentTracker?
    let post: APIPostView
    
    init(appState: AppState,
         prefillContents: String? = nil,
         commentTracker: CommentTracker? = nil,
         post: APIPostView) {
        self.appState = appState
        self.prefillContents = prefillContents
        self.commentTracker = commentTracker
        self.post = post
    }
    
    var id: Int { post.id }
    
    func embeddedView() -> AnyView {
        return AnyView(LargePost(postView: post, isExpanded: true)
            .padding(.horizontal))
    }
    
    func sendResponse(responseContents: String) async throws {
        let comment = try await commentRepository.postComment(
            content: responseContents,
            postId: post.post.id
        )
        
        if let commentTracker {
            await MainActor.run {
                withAnimation {
                    commentTracker.comments.prepend(comment)
                }
            }
        }
    }
}

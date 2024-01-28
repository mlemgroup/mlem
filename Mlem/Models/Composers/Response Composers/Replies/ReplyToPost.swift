//
//  ReplyToPost.swift
//  Mlem
//
//  Created by Eric Andrews on 2023-07-24.
//

import Dependencies
import Foundation
import SwiftUI

struct ReplyToPost: ResponseEditorModel {
    @Dependency(\.commentRepository) var commentRepository
    
    let canUpload: Bool = true
    let showSlurWarning: Bool = true
    let modalName: String = "New Comment"
    let prefillContents: String?
    let commentTracker: CommentTracker?
    let post: PostModel
    
    init(
        prefillContents: String? = nil,
        commentTracker: CommentTracker? = nil,
        post: PostModel
    ) {
        self.prefillContents = prefillContents
        self.commentTracker = commentTracker
        self.post = post
    }
    
    var id: Int { post.postId }
    
    func embeddedView() -> AnyView {
        AnyView(LargePost(post: post, layoutMode: .constant(.maximize))
            .padding(.horizontal))
    }
    
    func sendResponse(responseContents: String) async throws {
        let comment = try await commentRepository.postComment(
            content: responseContents,
            postId: post.postId
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

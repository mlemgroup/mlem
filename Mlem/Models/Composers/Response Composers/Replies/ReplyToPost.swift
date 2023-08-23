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
    let modalName: String = "New Comment"
    let prefillContents: String?
    let commentTracker: CommentTracker?
    let post: APIPostView
    
    init(
        prefillContents: String? = nil,
        commentTracker: CommentTracker? = nil,
        post: APIPostView
    ) {
        self.prefillContents = prefillContents
        self.commentTracker = commentTracker
        self.post = post
    }
    
    var id: Int { post.id }
    
    func embeddedView() -> AnyView {
        AnyView(LargePost(postView: post, layoutMode: .constant(.maximize))
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

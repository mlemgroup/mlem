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
    let postModel: PostModel
    
    init(
        prefillContents: String? = nil,
        commentTracker: CommentTracker? = nil,
        postModel: PostModel
    ) {
        self.prefillContents = prefillContents
        self.commentTracker = commentTracker
        self.postModel = postModel
    }
    
    var id: Int { postModel.postId }
    
    func embeddedView() -> AnyView {
        AnyView(LargePost(postModel: postModel, layoutMode: .constant(.maximize))
            .padding(.horizontal))
    }
    
    func sendResponse(responseContents: String) async throws {
        let comment = try await commentRepository.postComment(
            content: responseContents,
            postId: postModel.postId
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

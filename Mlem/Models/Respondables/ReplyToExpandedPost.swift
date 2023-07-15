//
//  ReplyToPost.swift
//  Mlem
//
//  Created by Eric Andrews on 2023-07-15.
//

import Foundation
import Dependencies
import SwiftUI

struct ReplyToExpandedPost: Respondable {
    
    @Dependency(\.commentRepository) var commentRepository
    
    var id: Int { post.id }
    let appState: AppState
    let canUpload: Bool = true
    let modalName: String = "New Comment"
    let post: APIPostView
    let commentTracker: CommentTracker
    
    func embeddedView() -> AnyView {
        return AnyView(LargePost(postView: post, isExpanded: true)
            .padding(.horizontal))
    }
    
    func sendResponse(responseContents: String) async throws {
        if let comment = await commentRepository.postComment(content: responseContents, postId: post.post.id) {
            await MainActor.run {
                withAnimation {
                    commentTracker.comments.prepend(comment)
                }
            }
        }
    }
}

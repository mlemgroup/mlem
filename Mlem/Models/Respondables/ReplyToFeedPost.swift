//
//  ReplyToPost.swift
//  Mlem
//
//  Created by Eric Andrews on 2023-07-03.
//

import Foundation
import Dependencies
import SwiftUI

struct ReplyToFeedPost: Respondable {
    
    @Dependency(\.commentRepository) var commentRepository
    
    let appState: AppState
    let canUpload: Bool = true
    let modalName: String = "New Comment"
    let post: APIPostView
    
    var id: Int { post.id }
    
    func embeddedView() -> AnyView {
        return AnyView(LargePost(postView: post, isExpanded: true)
            .padding(.horizontal))
    }
    
    func sendResponse(responseContents: String) async throws {
        await commentRepository.postComment(content: responseContents, postId: post.post.id)
    }
}

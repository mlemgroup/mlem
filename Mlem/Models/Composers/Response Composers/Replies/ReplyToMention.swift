//
//  ReplyToMention.swift
//  Mlem
//
//  Created by Eric Andrews on 2023-07-03.
//

import Dependencies
import Foundation
import SwiftUI

struct ReplyToMention: ResponseEditorModel {
    @Dependency(\.commentRepository) var commentRepository
    
    let canUpload: Bool = true
    let showSlurWarning: Bool = true
    let modalName: String = "New Comment"
    let prefillContents: String? = nil
    let mention: MentionModel
    
    var id: Int { mention.id }
    
    func embeddedView() -> AnyView {
        AnyView(
            InboxMentionBodyView(mention: mention)
                .padding(.horizontal)
        )
    }
    
    func sendResponse(responseContents: String) async throws {
        try await commentRepository.postComment(
            content: responseContents,
            parentId: mention.comment.id,
            postId: mention.post.id
        )
    }
}

//
//  ReplyToMention.swift
//  Mlem
//
//  Created by Eric Andrews on 2023-07-03.
//

import Foundation
import Dependencies
import SwiftUI

struct ReplyToMention: Respondable {
    
    @Dependency(\.commentRepository) var commentRepository
    
    let appState: AppState
    let canUpload: Bool = true
    let modalName: String = "New Comment"
    let mention: APIPersonMentionView
    
    var id: Int { mention.id }
    
    func embeddedView() -> AnyView {
        return AnyView(InboxMentionView(mention: mention,
                                        menuFunctions: [])
            .padding(.horizontal))
    }
    
    func sendResponse(responseContents: String) async throws {
        try await commentRepository.postComment(
            content: responseContents,
            parentId: mention.comment.id,
            postId: mention.post.id
        )
    }
}

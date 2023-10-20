//
//  ReportMention.swift
//  Mlem
//
//  Created by Eric Andrews on 2023-07-15.
//

import Dependencies
import Foundation
import SwiftUI

struct ReportMention: ResponseEditorModel {
    @Dependency(\.commentRepository) var commentRepository
    
    var id: Int { mention.id }
    let canUpload: Bool = false
    let modalName: String = "Report Comment"
    let prefillContents: String? = nil
    let mention: MentionModel
    
    func embeddedView() -> AnyView {
        AnyView(InboxMentionView(mention: mention, menuFunctions: [])
            .padding(.horizontal))
    }
    
    func sendResponse(responseContents: String) async throws {
        try await commentRepository.reportComment(id: mention.comment.id, reason: responseContents)
    }
}

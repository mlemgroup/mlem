//
//  ReportComment.swift
//  Mlem
//
//  Created by Eric Andrews on 2023-07-15.
//

 import Foundation
 import SwiftUI

 struct ReportMention: Respondable {
    var id: Int { mention.id }
    let appState: AppState
    let canUpload: Bool = false
    let modalName: String = "Report Comment"
    let mention: APIPersonMentionView

    func embeddedView() -> AnyView {
        return AnyView(InboxMentionView(mention: mention, menuFunctions: [])
            .padding(.horizontal))
    }

    func sendResponse(responseContents: String) async throws {
        _ = try await reportComment(account: appState.currentActiveAccount,
                                    commentId: mention.comment.id,
                                    reason: responseContents)
    }
 }

//
//  ReplyToMessage.swift
//  Mlem
//
//  Created by Eric Andrews on 2023-07-15.
//

import Foundation
import SwiftUI

struct ReplyToMessage: EditorModel {
    var id: Int { message.id }
    let appState: AppState
    let canUpload: Bool = true
    let modalName: String = "New Message"
    let prefillContents: String? = nil
    let message: APIPrivateMessageView
    
    func embeddedView() -> AnyView {
        return AnyView(InboxMessageView(message: message, menuFunctions: [])
            .padding(.horizontal, AppConstants.postAndCommentSpacing))
    }
    
    func sendResponse(responseContents: String) async throws {
        try await sendPrivateMessage(
            content: responseContents,
            recipient: message.creator,
            account: appState.currentActiveAccount
        )
    }
}

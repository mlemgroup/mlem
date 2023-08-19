//
//  ReplyToMessage.swift
//  Mlem
//
//  Created by Eric Andrews on 2023-07-15.
//

import Dependencies
import Foundation
import SwiftUI

struct ReplyToMessage: ResponseEditorModel {
    
    @Dependency(\.apiClient) var apiClient
    @Dependency(\.hapticManager) var hapticManager
    
    var id: Int { message.id }
    let canUpload: Bool = true
    let modalName: String = "New Message"
    let prefillContents: String? = nil
    let message: APIPrivateMessageView
    
    func embeddedView() -> AnyView {
        return AnyView(InboxMessageView(message: message, menuFunctions: [])
            .padding(.horizontal, AppConstants.postAndCommentSpacing))
    }
    
    func sendResponse(responseContents: String) async throws {
        do {
            try await apiClient.sendPrivateMessage(content: responseContents, recipient: message.creator)
            hapticManager.play(haptic: .success, priority: .high)
        } catch {
            hapticManager.play(haptic: .failure, priority: .high)
            throw error
        }
    }
}

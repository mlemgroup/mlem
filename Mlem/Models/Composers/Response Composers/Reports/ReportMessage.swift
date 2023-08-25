//
//  ReportMessage.swift
//  Mlem
//
//  Created by Eric Andrews on 2023-07-15.
//

import Dependencies
import Foundation
import SwiftUI

struct ReportMessage: ResponseEditorModel {
    @Dependency(\.apiClient) var apiClient
    @Dependency(\.hapticManager) var hapticManager
    
    var id: Int { message.id }
    let canUpload: Bool = false
    let modalName: String = "Report Message"
    let prefillContents: String? = nil
    let message: APIPrivateMessageView
    
    func embeddedView() -> AnyView {
        AnyView(InboxMessageView(message: message, menuFunctions: [])
            .padding(.horizontal))
    }
    
    func sendResponse(responseContents: String) async throws {
        do {
            try await apiClient.reportPrivateMessage(id: message.id, reason: responseContents)
            hapticManager.play(haptic: .violentSuccess, priority: .high)
        } catch {
            hapticManager.play(haptic: .failure, priority: .high)
            throw error
        }
    }
}

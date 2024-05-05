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
    @Dependency(\.inboxRepository) var inboxRepository
    @Dependency(\.hapticManager) var hapticManager
    
    var id: Int { message.id }
    let canUpload: Bool = false
    let showSlurWarning: Bool = false
    let modalName: String = "Report Message"
    let prefillContents: String? = nil
    let message: MessageModel
    
    func embeddedView() -> AnyView {
        AnyView(InboxMessageBodyView(message: message)
            .padding(AppConstants.standardSpacing))
    }
    
    func sendResponse(responseContents: String) async throws {
        do {
            _ = try await inboxRepository.reportMessage(id: message.id, reason: responseContents)
            hapticManager.play(haptic: .violentSuccess, priority: .high)
        } catch {
            hapticManager.play(haptic: .failure, priority: .high)
            throw error
        }
    }
}

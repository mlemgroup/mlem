//
//  Report Private Message.swift
//  Mlem
//
//  Created by Eric Andrews on 2023-07-12.
//

import Foundation

@MainActor
func reportMessage(
    messageId: Int,
    reason: String,
    appState: AppState
) async throws -> APIPrivateMessageReportView {
    do {
        let request = CreatePrivateMessageReportRequest(account: appState.currentActiveAccount,
                                                        privateMessageId: messageId,
                                                        reason: reason)
        
        let response = try await APIClient().perform(request: request)
        HapticManager.shared.play(haptic: .violentSuccess, priority: .high)
        return response.privateMessageReportView
    } catch {
        HapticManager.shared.play(haptic: .failure, priority: .high)
        throw error
    }
}

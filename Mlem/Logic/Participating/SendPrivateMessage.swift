//
//  SendPrivateMessage.swift
//  Mlem
//
//  Created by Eric Andrews on 2023-07-02.
//

import Foundation

@MainActor
func sendPrivateMessage(
    content: String,
    recipient: APIPerson,
    account: SavedAccount
) async throws {
    do {
        let request = CreatePrivateMessageRequest(account: account, content: content, recipient: recipient)
        HapticManager.shared.success()
        try await APIClient().perform(request: request)
    } catch {
        HapticManager.shared.error()
        throw error
    }
}

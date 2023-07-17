//
//  MarkPrivateMessageAsRead.swift
//  Mlem
//
//  Created by Eric Andrews on 2023-07-02.
//

import Foundation

@MainActor
func sendMarkPrivateMessageAsReadRequest(
    messageView: APIPrivateMessageView,
    read: Bool,
    account: SavedAccount,
    messagesTracker: FeedTracker<APIPrivateMessageView>,
    appState: AppState
) async throws {
    do {
        let request = MarkPrivateMessageAsRead(account: account,
                                               privateMessageId: messageView.id,
                                               read: read)

        HapticManager.shared.gentleSuccess()
        let response = try await APIClient().perform(request: request)
        
        messagesTracker.update(with: response.privateMessageView)
    } catch {
        HapticManager.shared.error()
        throw error
    }
}

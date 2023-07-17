//
//  MarkPersonMentionAsRead.swift
//  Mlem
//
//  Created by Eric Andrews on 2023-07-02.
//

import Foundation

@MainActor
func sendMarkPersonMentionAsReadRequest(
    personMention: APIPersonMentionView,
    read: Bool,
    account: SavedAccount,
    mentionTracker: FeedTracker<APIPersonMentionView>,
    appState: AppState
) async throws {
    do {
        let request = MarkPersonMentionAsRead(
            account: account,
            personMentionId: personMention.personMention.id,
            read: read
        )

        HapticManager.shared.gentleSuccess()
        let response = try await APIClient().perform(request: request)
        
        mentionTracker.update(with: response.personMentionView)
    } catch {
        HapticManager.shared.error()
        throw error
    }
}

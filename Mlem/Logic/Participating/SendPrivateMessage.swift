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
    account: SavedAccount,
    appState: AppState
) async throws {
    do {
        let request = CreatePrivateMessageRequest(account: account, content: content, recipient: recipient)

        print(request)
        
        AppConstants.hapticManager.notificationOccurred(.success)
        try await APIClient().perform(request: request)
    } catch let ratingOperationError {
        AppConstants.hapticManager.notificationOccurred(.error)
        print("Failed while trying to mark read: \(ratingOperationError)")
        throw RatingFailure.failedToPostScore
    }
}

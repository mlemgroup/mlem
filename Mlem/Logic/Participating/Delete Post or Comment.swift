//
//  Delete Post or Comment.swift
//  Mlem
//
//  Created by Jake Shirley on 6/26/23.
//

import Foundation

@MainActor
func deletePost(
    postId: Int,
    account: SavedAccount,
    postTracker: PostTracker,
    appState: AppState
) async throws -> APIPostView {
    do {
        let request = DeletePostRequest(
            account: account,
            postId: postId,
            deleted: true
        )
        
        let response = try await APIClient().perform(request: request)
        postTracker.update(with: response.postView)
        HapticManager.shared.play(haptic: .destructiveSuccess, priority: .high)
        return response.postView
    } catch {
        HapticManager.shared.play(haptic: .failure, priority: .high)
        throw error
    }
}

//
//  Rate Post or Comment.swift
//  Mlem
//
//  Created by David Bureš on 23.05.2023.
//

import Foundation

enum ScoringOperation: Int, Decodable {
    case upvote = 1
    case downvote = -1
    case resetVote = 0
}

@MainActor
func ratePost(
    postId: Int,
    operation: ScoringOperation,
    account: SavedAccount,
    postTracker: PostTracker,
    appState: AppState
) async throws -> APIPostView {
    do {
        let request = CreatePostLikeRequest(
            account: account,
            postId: postId,
            score: operation
        )

        let response = try await APIClient().perform(request: request)
        postTracker.update(with: response.postView)
        return response.postView
    } catch {
        throw error
    }
}

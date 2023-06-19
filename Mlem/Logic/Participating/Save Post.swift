//
//  Save Post.swift
//  Mlem
//
//  Created by Eric Andrews on 2023-06-19.
//

import Foundation

enum SavingFailure {
    case failedToSavePost
}

@MainActor
func sendSavePostRequest(account: SavedAccount,
              postId: Int,
              save: Bool,
              postTracker: PostTracker) async throws {
    do {
        let request = SavePostRequest(account: account, postId: postId, save: save)
        
        AppConstants.hapticManager.notificationOccurred(.success)
        let response = try await APIClient().perform(request: request)
        
        guard let indexToReplace = postTracker.posts.firstIndex(where: { $0.post.id == postId }) else {
            // shouldn't happen, but safer than force unwrapping
            return
        }
        
        postTracker.posts[indexToReplace] = response.postView
    }
    catch {
        AppConstants.hapticManager.notificationOccurred(.error)
        throw RatingFailure.failedToPostScore
    }
}

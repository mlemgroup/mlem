//
//  Report Post or Comment.swift
//  Mlem
//
//  Created by Jake Shirley on 7/1/23.
//

import Foundation

@MainActor
func reportPost(
    postId: Int,
    account: SavedAccount,
    reason: String
) async throws -> APIPostReportView {
    do {
        let request = CreatePostReportRequest(
            account: account,
            postId: postId,
            reason: reason
        )
        
        let response = try await APIClient().perform(request: request)
        HapticManager.shared.play(haptic: .violentSuccess, priority: .core)
        return response.postReportView
    } catch {
        HapticManager.shared.play(haptic: .failure, priority: .core)
        throw error
    }
}

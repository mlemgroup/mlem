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
        HapticManager.shared.violentSuccess()
        return response.postReportView
    } catch {
        HapticManager.shared.error()
        throw error
    }
}

@MainActor
func reportComment(
    account: SavedAccount,
    commentId: Int,
    reason: String
) async throws -> APICommentReportView {
    do {
        let request = CreateCommentReportRequest(
            account: account,
            commentId: commentId,
            reason: reason
        )
        
        let response = try await APIClient().perform(request: request)
        HapticManager.shared.violentSuccess()
        return response.commentReportView
    } catch {
        HapticManager.shared.error()
        throw error
    }
}

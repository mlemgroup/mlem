//
//  Report Post or Comment.swift
//  Mlem
//
//  Created by Jake Shirley on 7/1/23.
//

import Foundation

enum ReportFailiure: Error {
    case failedToReport
}

@MainActor
func reportPost(
    postId: Int,
    account: SavedAccount,
    reason: String,
    appState: AppState
) async throws -> APIPostReportView {
    do {
        let request = CreatePostReportRequest(
            account: account,
            postId: postId,
            reason: reason
        )
        
        let response = try await APIClient().perform(request: request)
        AppConstants.hapticManager.notificationOccurred(.success)
        return response.postReportView
    } catch {
        AppConstants.hapticManager.notificationOccurred(.error)
        print("Failed to report post: \(error)")
        throw ReportFailiure.failedToReport
    }
}

@MainActor
func reportComment(
    commentId: Int,
    account: SavedAccount,
    reason: String,
    appState: AppState
) async throws -> APICommentReportView {
    do {
        let request = CreateCommentReportRequest(
            account: account,
            commentId: commentId,
            reason: reason
        )
        
        let response = try await APIClient().perform(request: request)
        AppConstants.hapticManager.notificationOccurred(.success)
        return response.commentReportView
    } catch {
        AppConstants.hapticManager.notificationOccurred(.error)
        print("Failed to report comment: \(error)")
        throw ReportFailiure.failedToReport
    }
}

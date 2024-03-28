//
//  APIClient+Moderation.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-03-27.
//

import Foundation

extension APIClient {
    func loadCommentReports(
        page: Int,
        limit: Int,
        unresolvedOnly: Bool,
        communityId: Int?
    ) async throws -> [CommentReportModel] {
        let request = try ListCommentReportsRequest(
            session: session,
            page: page,
            limit: limit,
            unresolvedOnly: unresolvedOnly,
            communityId: communityId
        )
        let response = try await perform(request: request)
        
        return response.commentReports.map { CommentReportModel(
            reporter: UserModel(from: $0.creator),
            commentReport: $0.commentReport,
            comment: $0.comment
        ) }
    }
}

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
        // the request throws an error if the calling user is not mod or admin, so prevent it from executing in that case
        guard siteInformation.isAdmin || !siteInformation.moderatedCommunities.isEmpty else {
            return .init()
        }
        
        let response = try await perform(request: request)
        
        return response.commentReports.map { CommentReportModel(
            reporter: UserModel(from: $0.creator),
            community: CommunityModel(from: $0.community),
            commentReport: $0.commentReport,
            comment: $0.comment,
            votes: VotesModel(from: $0.counts, myVote: $0.myVote ?? .resetVote),
            numReplies: $0.counts.childCount
        ) }
    }
}

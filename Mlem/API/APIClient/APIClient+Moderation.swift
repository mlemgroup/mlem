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
        try print(session.token)
        
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
        
        return response.commentReports.map {
            var resolver: UserModel?
            if let apiResolver = $0.resolver {
                resolver = UserModel(from: apiResolver)
            }
            
            return CommentReportModel(
                reporter: UserModel(from: $0.creator),
                resolver: resolver,
                commentCreator: UserModel(from: $0.commentCreator),
                community: CommunityModel(from: $0.community),
                commentReport: $0.commentReport,
                comment: $0.comment,
                votes: VotesModel(from: $0.counts, myVote: $0.myVote ?? .resetVote),
                numReplies: $0.counts.childCount,
                creatorBannedFromCommunity: $0.creatorBannedFromCommunity
            )
        }
    }
    
    func markCommentReportResolved(
        reportId: Int,
        resolved: Bool
    ) async throws -> CommentReportModel {
        let request = try ResolveCommentReportRequest(session: session, reportId: reportId, resolved: resolved)
        let response = try await perform(request: request)
        
        var resolver: UserModel?
        if let apiResolver = response.commentReportView.resolver {
            resolver = UserModel(from: apiResolver)
        }
        
        return CommentReportModel(
            reporter: UserModel(from: response.commentReportView.creator),
            resolver: resolver,
            commentCreator: UserModel(from: response.commentReportView.commentCreator),
            community: CommunityModel(from: response.commentReportView.community),
            commentReport: response.commentReportView.commentReport,
            comment: response.commentReportView.comment,
            votes: VotesModel(from: response.commentReportView.counts, myVote: response.commentReportView.myVote),
            numReplies: response.commentReportView.counts.childCount,
            creatorBannedFromCommunity: response.commentReportView.creatorBannedFromCommunity
        )
    }
}

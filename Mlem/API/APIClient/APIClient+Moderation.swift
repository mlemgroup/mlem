//
//  APIClient+Moderation.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-03-27.
//

import Foundation

extension APIClient {
    
    // MARK: - Comment Reports
    
    func loadCommentReports(
        page: Int,
        limit: Int,
        unresolvedOnly: Bool,
        communityId: Int?
    ) async throws -> [CommentReportModel] {
        // the request throws an error if the calling user is not mod or admin--should never be called
        guard siteInformation.isAdmin || !siteInformation.moderatedCommunities.isEmpty else {
            assertionFailure("loadCommentReports called by non-moderator user!")
            return .init()
        }
        
        let request = try ListCommentReportsRequest(
            session: session,
            page: page,
            limit: limit,
            unresolvedOnly: unresolvedOnly,
            communityId: communityId
        )
        let response = try await perform(request: request)
        
        return response.commentReports.map { report in
            var resolver: UserModel?
            if let apiResolver = report.resolver {
                resolver = UserModel(from: apiResolver)
            }
            
            return CommentReportModel(
                reporter: UserModel(from: report.creator),
                resolver: resolver,
                commentCreator: UserModel(from: report.commentCreator),
                community: CommunityModel(from: report.community),
                commentReport: report.commentReport,
                comment: report.comment,
                votes: VotesModel(from: report.counts, myVote: report.myVote ?? .resetVote),
                numReplies: report.counts.childCount,
                commentCreatorBannedFromCommunity: report.creatorBannedFromCommunity
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
            commentCreatorBannedFromCommunity: response.commentReportView.creatorBannedFromCommunity
        )
    }
    
    // MARK: - Post Reports
    
    func loadPostReports(
        page: Int,
        limit: Int,
        unresolvedOnly: Bool,
        communityId: Int?
    ) async throws -> [PostReportModel] {
        // the request throws an error if the calling user is not mod or admin--should never be called
        guard siteInformation.isAdmin || !siteInformation.moderatedCommunities.isEmpty else {
            assertionFailure("loadPostReports called by non-moderator user!")
            return .init()
        }
        
        let request = try ListPostReportsRequest(
            session: session,
            page: page,
            limit: limit,
            unresolvedOnly: unresolvedOnly,
            communityId: communityId
        )
        let response = try await perform(request: request)
        
        return response.postReports.map { report in
            var resolver: UserModel?
            if let apiResolver = report.resolver {
                resolver = UserModel(from: apiResolver)
            }
            
            return PostReportModel(
                reporter: UserModel(from: report.creator),
                resolver: resolver,
                postCreator: UserModel(from: report.postCreator),
                community: CommunityModel(from: report.community),
                postReport: report.postReport,
                post: report.post,
                votes: VotesModel(from: report.counts, myVote: report.myVote ?? .resetVote),
                numReplies: report.counts.comments,
                postCreatorBannedFromCommunity: report.creatorBannedFromCommunity
            )
        }
    }
    
    func markPostReportResolved(
        reportId: Int,
        resolved: Bool
    ) async throws -> PostReportModel {
        let request = try ResolvePostReportRequest(session: session, reportId: reportId, resolved: resolved)
        let response = try await perform(request: request)
        
        var resolver: UserModel?
        if let apiResolver = response.postReportView.resolver {
            resolver = UserModel(from: apiResolver)
        }
        
        return PostReportModel(
            reporter: UserModel(from: response.postReportView.creator),
            resolver: resolver,
            postCreator: UserModel(from: response.postReportView.postCreator),
            community: CommunityModel(from: response.postReportView.community),
            postReport: response.postReportView.postReport,
            post: response.postReportView.post,
            votes: VotesModel(from: response.postReportView.counts, myVote: response.postReportView.myVote ?? .resetVote),
            numReplies: response.postReportView.counts.comments,
            postCreatorBannedFromCommunity: response.postReportView.creatorBannedFromCommunity
        )
    }
}

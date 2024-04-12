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
    
    // MARK: - Message Reports
    
    func loadMessageReports(
        page: Int,
        limit: Int,
        unresolvedOnly: Bool
    ) async throws -> [MessageReportModel] {
        let request = try ListPrivateMessageReportsRequest(session: session, page: page, limit: limit, unresolvedOnly: unresolvedOnly)
        let response = try await perform(request: request)
        
        return response.privateMessageReports.map { report in
            var resolver: UserModel?
            if let apiResolver = report.resolver {
                resolver = UserModel(from: apiResolver)
            }
            
            return MessageReportModel(
                reporter: UserModel(from: report.creator),
                resolver: resolver,
                messageCreator: UserModel(from: report.privateMessageCreator),
                messageReport: report.privateMessageReport
            )
        }
    }
    
    func markPrivateMessageReportResolved(
        reportId: Int,
        resolved: Bool
    ) async throws -> MessageReportModel {
        let request = try ResolvePrivateMessageReportRequest(session: session, reportId: reportId, resolved: resolved)
        let response = try await perform(request: request).privateMessageReportView
        
        var resolver: UserModel?
        if let apiResolver = response.resolver {
            resolver = UserModel(from: apiResolver)
        }
        
        return MessageReportModel(
            reporter: UserModel(from: response.creator),
            resolver: resolver,
            messageCreator: UserModel(from: response.privateMessageCreator),
            messageReport: response.privateMessageReport
        )
    }
    
    // MARK: - Registration Applications
    
    func loadRegistrationApplications(
        page: Int,
        limit: Int,
        unresolvedOnly: Bool
    ) async throws -> [RegistrationApplicationModel] {
        let request = try ListRegistrationApplicationsRequest(session: session, unreadOnly: unresolvedOnly, page: page, limit: limit)
        let response = try await perform(request: request)
        
        return response.registrationApplications.map { registrationApplication in
            var resolver: UserModel?
            if let apiResolver = registrationApplication.admin {
                resolver = UserModel(from: apiResolver)
            }
            
            return RegistrationApplicationModel(
                application: registrationApplication.registrationApplication,
                creator: UserModel(from: registrationApplication.creator),
                resolver: resolver,
                approved: resolver != nil ? registrationApplication.creatorLocalUser.acceptedApplication : nil
            )
        }
    }
    
    func approveRegistrationApplication(
        applicationId: Int,
        approve: Bool,
        denyReason: String?
    ) async throws -> RegistrationApplicationModel {
        let request = try ApproveRegistrationApplicationRequest(
            session: session,
            id: applicationId,
            approve: approve,
            denyReason: denyReason
        )
        let response = try await perform(request: request).registrationApplication
        
        var resolver: UserModel?
        if let apiResolver = response.admin {
            resolver = UserModel(from: apiResolver)
        }
        
        return RegistrationApplicationModel(
            application: response.registrationApplication,
            creator: UserModel(from: response.creator),
            resolver: resolver,
            approved: resolver != nil ? response.creatorLocalUser.acceptedApplication : nil
        )
    }
    
    // MARK: - Unread Counts
    
    func getUnreadReports(for communityId: Int?) async throws -> APIGetReportCountResponse {
        // the request throws an error if the calling user is not mod or admin--should never be called
        guard siteInformation.isAdmin || !siteInformation.moderatedCommunities.isEmpty else {
            assertionFailure("getUnreadReports called by non-moderator user!")
            return .init(communityId: communityId, commentReports: 0, postReports: 0, privateMessageReports: 0)
        }
        
        let request = try GetReportCountRequest(session: session, communityId: communityId)
        let response = try await perform(request: request)
        return response
    }
    
    func getUnreadRegistrationApplications() async throws -> APIGetUnreadRegistrationApplicationCountResponse {
        // the request throws an error if the calling user is not an admin--should never be called
        guard siteInformation.isAdmin else {
            assertionFailure("getUnreadRegistrationApplications called by non-moderator user!")
            return .init(registrationApplications: 0)
        }
        
        let request = try GetUnreadRegistrationApplicationCountRequest(session: session)
        let response = try await perform(request: request)
        return response
    }
}

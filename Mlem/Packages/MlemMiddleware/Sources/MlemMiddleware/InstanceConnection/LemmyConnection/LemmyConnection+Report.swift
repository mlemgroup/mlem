//
//  File.swift
//  MlemMiddleware
//
//  Created by Sjmarf on 2025-06-08.
//

import Foundation

internal extension LemmyConnection {
    func getReportCount(communityId: Int? = nil) async throws -> Int {
        try await processingForEndpoint { endpoint in
            switch endpoint {
            case .v3:
                let response = try await self.perform(LemmyReportCountRequest(communityId: communityId), endpoint: .v3)
                return response.postReports + response.commentReports
            case .v4:
                guard communityId == nil else { throw ApiClientError.featureUnsupported }
                let response = try await self.perform(LemmyGetUnreadCountsRequest(), endpoint: .v4)
                return response.notificationCount
            }
        }
    }

    func getPostReports(
        pageInfo: PageInfo,
        unresolvedOnly: Bool = false,
        communityId: Int? = nil,
        postId: Int? = nil
    ) async throws -> PagedResponse<ReportSnapshot> {
        try await processingForEndpoint { endpoint in
            switch endpoint {
            case .v3:
                let request = LemmyListPostReportsRequest(
                    page: try pageInfo.cursor.requirePageNumber,
                    limit: pageInfo.limit,
                    unresolvedOnly: unresolvedOnly,
                    communityId: communityId,
                    postId: postId
                )
                let response = try await self.perform(request, endpoint: .v3)
                return try .fromLemmyV3(
                    pageInfo: pageInfo,
                    items: response.postReports.map { try .init(from: $0) },
                    nextCursor: nil
                )
            case .v4:
                let request = LemmyListReportsRequest(
                    unresolvedOnly: unresolvedOnly,
                    type_: .posts,
                    postId: postId,
                    communityId: communityId,
                    sort: .new,
                    pageCursor: try pageInfo.cursor.requireCursorString,
                    limit: pageInfo.limit,
                    showCommunityRuleViolations: nil,
                    myReportsOnly: false
                )
                let response = try await self.perform(request, endpoint: .v4)
                return try .init(from: response.toPostReportsResponse()) {
                    try .init(from: $0)
                }
            }
        }
    }
    
    func getCommentReports(
        pageInfo: PageInfo,
        unresolvedOnly: Bool = false,
        communityId: Int? = nil,
        commentId: Int? = nil
    ) async throws -> PagedResponse<ReportSnapshot> {
        try await processingForEndpoint { endpoint in
            switch endpoint {
            case .v3:
                let request = LemmyListCommentReportsRequest(
                    page: try pageInfo.cursor.requirePageNumber,
                    limit: pageInfo.limit,
                    unresolvedOnly: unresolvedOnly,
                    communityId: communityId,
                    commentId: commentId
                )
                let response = try await self.perform(request, endpoint: .v3)
                return try .fromLemmyV3(
                    pageInfo: pageInfo,
                    items: response.commentReports.map { try .init(from: $0) },
                    nextCursor: nil
                )
            case .v4:
                if commentId != nil {
                    throw ApiClientError.featureUnsupported
                }
                let request = LemmyListReportsRequest(
                    unresolvedOnly: unresolvedOnly,
                    type_: .comments,
                    postId: nil,
                    communityId: communityId,
                    sort: .new,
                    pageCursor: try pageInfo.cursor.requireCursorString,
                    limit: pageInfo.limit,
                    showCommunityRuleViolations: nil,
                    myReportsOnly: false
                )
                let response = try await self.perform(request, endpoint: .v4)
                return try .init(from: response.toCommentReportsResponse()) {
                    try .init(from: $0)
                }
            }
        }
    }

    func getMessageReports(
        pageInfo: PageInfo,
        unresolvedOnly: Bool = false
    ) async throws -> PagedResponse<ReportSnapshot> {
        try await processingForEndpoint { endpoint in
            switch endpoint {
            case .v3:
                let request = LemmyListPmReportsRequest(
                    page: try pageInfo.cursor.requirePageNumber,
                    limit: pageInfo.limit,
                    unresolvedOnly: unresolvedOnly
                )
                let response = try await self.perform(request, endpoint: .v3)
                return try .fromLemmyV3(
                    pageInfo: pageInfo,
                    items: response.privateMessageReports.map { try .init(from: $0) },
                    nextCursor: nil
                )
            case .v4:
                let request = LemmyListReportsRequest(
                    unresolvedOnly: unresolvedOnly,
                    type_: .privateMessages,
                    postId: nil,
                    communityId: nil,
                    sort: .new,
                    pageCursor: try pageInfo.cursor.requireCursorString,
                    limit: pageInfo.limit,
                    showCommunityRuleViolations: nil,
                    myReportsOnly: false
                )
                let response = try await self.perform(request, endpoint: .v4)
                return try .init(from: response.toPrivateMessageReportsResponse()) {
                    try .init(from: $0)
                }
            }
        }
    }
    
    @discardableResult
    func resolvePostReport(id: Int, resolved: Bool) async throws -> ReportSnapshot {
        let response = try await performingForEndpoint { endpoint in
            LemmyResolvePostReportRequest(
                endpoint: endpoint,
                reportId: id,
                resolved: resolved,
                conclusion: nil
            )
        }
        return try .init(from: response.postReportView)
    }
    
    @discardableResult
    func resolveCommentReport(id: Int, resolved: Bool) async throws -> ReportSnapshot {
        let response = try await performingForEndpoint { endpoint in
            LemmyResolveCommentReportRequest(
                endpoint: endpoint,
                reportId: id,
                resolved: resolved,
                conclusion: nil
            )
        }
        return try .init(from: response.commentReportView)
    }
    
    @discardableResult
    func resolveMessageReport(id: Int, resolved: Bool) async throws -> ReportSnapshot {
        let response = try await performingForEndpoint { endpoint in
            LemmyResolvePmReportRequest(
                endpoint: endpoint,
                reportId: id,
                resolved: resolved,
                conclusion: nil
            )
        }
        return try .init(from: response.privateMessageReportView)
    }
}

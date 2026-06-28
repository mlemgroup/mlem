//
//  File.swift
//  MlemMiddleware
//
//  Created by Sjmarf on 2025-06-08.
//

import Foundation

internal extension LemmyConnection {
    func getReportCount(communityId: Int? = nil) async throws -> Int {
        let response = try await performingForEndpoint { endpoint in
            switch endpoint {
            case .v3:
                LemmyReportCountRequest(communityId: communityId)
            case .v4:
                throw ApiClientError.featureUnsupported
            }
        }
        return response.postReports + response.commentReports
    }
    
    func getPostReports(
        pageInfo: PageInfo,
        unresolvedOnly: Bool = false,
        communityId: Int? = nil,
        postId: Int? = nil
    ) async throws -> PagedResponse<ReportSnapshot> {
        let response = try await performingForEndpoint { _ in
            LemmyListPostReportsRequest(
                page: try pageInfo.cursor.requirePageNumber,
                limit: pageInfo.limit,
                unresolvedOnly: unresolvedOnly,
                communityId: communityId,
                postId: postId
            )
        }
        return try .fromLemmyV3(
            pageInfo: pageInfo,
            items: response.postReports.map { try .init(from: $0) },
            nextCursor: nil
        )
    }
    
    func getCommentReports(
        pageInfo: PageInfo,
        unresolvedOnly: Bool = false,
        communityId: Int? = nil,
        commentId: Int? = nil
    ) async throws -> PagedResponse<ReportSnapshot> {
        let response = try await performingForEndpoint { _ in
            LemmyListCommentReportsRequest(
                page: try pageInfo.cursor.requirePageNumber,
                limit: pageInfo.limit,
                unresolvedOnly: unresolvedOnly,
                communityId: communityId,
                commentId: commentId
            )
        }
        return try .fromLemmyV3(
            pageInfo: pageInfo,
            items: response.commentReports.map { try .init(from: $0) },
            nextCursor: nil
        )
    }
    
    func getMessageReports(
        pageInfo: PageInfo,
        unresolvedOnly: Bool = false
    ) async throws -> PagedResponse<ReportSnapshot> {
        let response = try await performingForEndpoint { _ in
            LemmyListPmReportsRequest(
                page: try pageInfo.cursor.requirePageNumber,
                limit: pageInfo.limit,
                unresolvedOnly: unresolvedOnly
            )
        }
        return try .fromLemmyV3(
            pageInfo: pageInfo,
            items: response.privateMessageReports.map { try .init(from: $0) },
            nextCursor: nil
        )
    }
    
    @discardableResult
    func resolvePostReport(id: Int, resolved: Bool) async throws -> ReportSnapshot {
        let response = try await performingForEndpoint { endpoint in
            LemmyResolvePostReportRequest(endpoint: endpoint, reportId: id, resolved: resolved)
        }
        return try .init(from: response.postReportView)
    }
    
    @discardableResult
    func resolveCommentReport(id: Int, resolved: Bool) async throws -> ReportSnapshot {
        let response = try await performingForEndpoint { endpoint in
            LemmyResolveCommentReportRequest(endpoint: endpoint, reportId: id, resolved: resolved)
        }
        return try .init(from: response.commentReportView)
    }
    
    @discardableResult
    func resolveMessageReport(id: Int, resolved: Bool) async throws -> ReportSnapshot {
        let response = try await performingForEndpoint { endpoint in
            LemmyResolvePmReportRequest(endpoint: endpoint, reportId: id, resolved: resolved)
        }
        return try .init(from: response.privateMessageReportView)
    }
}

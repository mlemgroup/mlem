//
//  File.swift
//  MlemMiddleware
//
//  Created by Sjmarf on 2025-06-08.
//

import Foundation

public extension LemmyConnection {
    func getReportCount(communityId: Int? = nil) async throws -> ReportUnreadCountSnapshot {
        let response = try await performingForEndpoint { endpoint in
            switch endpoint {
            case .v3:
                LemmyReportCountRequest(communityId: communityId)
            case .v4:
                throw ApiClientError.featureUnsupported
            }
        }
        return try .init(from: response)
    }
    
    func getPostReports(
        page: Int = 1,
        limit: Int = 20,
        unresolvedOnly: Bool = false,
        communityId: Int? = nil,
        postId: Int? = nil
    ) async throws -> [ReportSnapshot] {
        let response = try await performingForEndpoint { _ in
            LemmyListPostReportsRequest(
                page: page,
                limit: limit,
                unresolvedOnly: unresolvedOnly,
                communityId: communityId,
                postId: postId
            )
        }
        return try response.postReports.map { try .init(from: $0) }
    }
    
    func getCommentReports(
        page: Int = 1,
        limit: Int = 20,
        unresolvedOnly: Bool = false,
        communityId: Int? = nil,
        commentId: Int? = nil
    ) async throws -> [ReportSnapshot] {
        let response = try await performingForEndpoint { _ in
            LemmyListCommentReportsRequest(
                page: page,
                limit: limit,
                unresolvedOnly: unresolvedOnly,
                communityId: communityId,
                commentId: commentId
            )
        }
        return try response.commentReports.map { try .init(from: $0) }
    }
    
    func getMessageReports(
        page: Int = 1,
        limit: Int = 20,
        unresolvedOnly: Bool = false
    ) async throws -> [ReportSnapshot] {
        let response = try await performingForEndpoint { _ in
            LemmyListPmReportsRequest(
                page: page,
                limit: limit,
                unresolvedOnly: unresolvedOnly
            )
        }
        return try response.privateMessageReports.map { try .init(from: $0) }
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

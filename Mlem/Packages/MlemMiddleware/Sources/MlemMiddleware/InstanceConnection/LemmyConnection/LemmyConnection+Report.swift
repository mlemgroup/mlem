//
//  File.swift
//  MlemMiddleware
//
//  Created by Sjmarf on 2025-06-08.
//

import Foundation

public extension LemmyConnection {
    func getReportCount(communityId: Int? = nil) async throws -> ApiGetReportCountResponse {
        let response = try await performingForEndpoint { endpoint in
            ReportCountRequest(endpoint: endpoint, communityId: communityId)
        }
        return response
    }
    
    func getPostReports(
        page: Int = 1,
        limit: Int = 20,
        unresolvedOnly: Bool = false,
        communityId: Int? = nil,
        postId: Int? = nil
    ) async throws -> [ReportSnapshot] {
        let response = try await performingForEndpoint { _ in
            ListPostReportsRequest(
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
            ListCommentReportsRequest(
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
            ListPmReportsRequest(
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
            ResolvePostReportRequest(endpoint: endpoint, reportId: id, resolved: resolved)
        }
        return try .init(from: response.postReportView)
    }
    
    @discardableResult
    func resolveCommentReport(id: Int, resolved: Bool) async throws -> ReportSnapshot {
        let response = try await performingForEndpoint { endpoint in
            ResolveCommentReportRequest(endpoint: endpoint, reportId: id, resolved: resolved)
        }
        return try .init(from: response.commentReportView)
    }
    
    @discardableResult
    func resolveMessageReport(id: Int, resolved: Bool) async throws -> ReportSnapshot {
        let response = try await performingForEndpoint { endpoint in
            ResolvePmReportRequest(endpoint: endpoint, reportId: id, resolved: resolved)
        }
        return try .init(from: response.privateMessageReportView)
    }
}

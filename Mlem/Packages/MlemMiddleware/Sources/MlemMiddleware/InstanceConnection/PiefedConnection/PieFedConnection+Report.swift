//
//  File.swift
//  MlemMiddleware
//
//  Created by Sjmarf on 2025-06-08.
//

import Foundation

public extension PieFedConnection {
    func getReportCount(communityId: Int? = nil) async throws -> ReportUnreadCountSnapshot {
        throw ApiClientError.featureUnsupported
    }
    
    func getPostReports(
        pageInfo: PageInfo,
        unresolvedOnly: Bool = false,
        communityId: Int? = nil,
        postId: Int? = nil
    ) async throws -> PagedResponse<ReportSnapshot> {
        throw ApiClientError.featureUnsupported
    }

    func getCommentReports(
        pageInfo: PageInfo,
        unresolvedOnly: Bool = false,
        communityId: Int? = nil,
        commentId: Int? = nil
    ) async throws -> PagedResponse<ReportSnapshot> {
        throw ApiClientError.featureUnsupported
    }

    func getMessageReports(
        pageInfo: PageInfo,
        unresolvedOnly: Bool = false
    ) async throws -> PagedResponse<ReportSnapshot> {
        throw ApiClientError.featureUnsupported
    }
    
    @discardableResult
    func resolvePostReport(id: Int, resolved: Bool) async throws -> ReportSnapshot {
        throw ApiClientError.featureUnsupported
    }
    
    @discardableResult
    func resolveCommentReport(id: Int, resolved: Bool) async throws -> ReportSnapshot {
        throw ApiClientError.featureUnsupported
    }
    
    @discardableResult
    func resolveMessageReport(id: Int, resolved: Bool) async throws -> ReportSnapshot {
        throw ApiClientError.featureUnsupported
    }
}

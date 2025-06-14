//
//  File.swift
//  MlemMiddleware
//
//  Created by Sjmarf on 2025-06-08.
//

import Foundation

public extension PieFedConnection {
    func getReportCount(communityId: Int? = nil) async throws -> ReportUnreadCountSnapshot {
        throw ApiClientError.unsupportedLemmyVersion
    }
    
    func getPostReports(
        page: Int = 1,
        limit: Int = 20,
        unresolvedOnly: Bool = false,
        communityId: Int? = nil,
        postId: Int? = nil
    ) async throws -> [ReportSnapshot] {
        throw ApiClientError.unsupportedLemmyVersion
    }
    
    func getCommentReports(
        page: Int = 1,
        limit: Int = 20,
        unresolvedOnly: Bool = false,
        communityId: Int? = nil,
        commentId: Int? = nil
    ) async throws -> [ReportSnapshot] {
        throw ApiClientError.unsupportedLemmyVersion
    }
    
    func getMessageReports(
        page: Int = 1,
        limit: Int = 20,
        unresolvedOnly: Bool = false
    ) async throws -> [ReportSnapshot] {
        throw ApiClientError.unsupportedLemmyVersion
    }
    
    @discardableResult
    func resolvePostReport(id: Int, resolved: Bool) async throws -> ReportSnapshot {
        throw ApiClientError.unsupportedLemmyVersion
    }
    
    @discardableResult
    func resolveCommentReport(id: Int, resolved: Bool) async throws -> ReportSnapshot {
        throw ApiClientError.unsupportedLemmyVersion
    }
    
    @discardableResult
    func resolveMessageReport(id: Int, resolved: Bool) async throws -> ReportSnapshot {
        throw ApiClientError.unsupportedLemmyVersion
    }
}

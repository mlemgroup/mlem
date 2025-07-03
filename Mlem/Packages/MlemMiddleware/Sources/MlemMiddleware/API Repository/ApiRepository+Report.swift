//
//  ApiRepository+Report.swift
//  MlemMiddleware
//
//  Created by Eric Andrews on 2025-07-03.
//

extension ApiRepository {
    func getReportCount(communityId: Int? = nil) async throws -> ReportUnreadCountSnapshot {
        try await performingForConnection { connection in
            try await connection.getReportCount(communityId: communityId)
        }
    }
    
    func getPostReports(
        page: Int = 1,
        limit: Int = 20,
        unresolvedOnly: Bool = false,
        communityId: Int? = nil,
        postId: Int? = nil
    ) async throws -> [ReportSnapshot] {
        try await performingForConnection { connection in
            try await connection.getPostReports(
                page: page,
                limit: limit,
                unresolvedOnly: unresolvedOnly,
                communityId: communityId,
                postId: postId
            )
        }
    }
    
    func getCommentReports(
        page: Int = 1,
        limit: Int = 20,
        unresolvedOnly: Bool = false,
        communityId: Int? = nil,
        commentId: Int? = nil
    ) async throws -> [ReportSnapshot] {
        try await performingForConnection { connection in
            try await connection.getCommentReports(
                page: page,
                limit: limit,
                unresolvedOnly: unresolvedOnly,
                communityId: communityId,
                commentId: commentId
            )
        }
    }
    
    func getMessageReports(
        page: Int = 1,
        limit: Int = 20,
        unresolvedOnly: Bool = false
    ) async throws -> [ReportSnapshot] {
        try await performingForConnection { connection in
            try await connection.getMessageReports(
                page: page,
                limit: limit,
                unresolvedOnly: unresolvedOnly
            )
        }
    }
    
    func resolvePostReport(
        id: Int,
        resolved: Bool
    ) async throws -> ReportSnapshot {
        try await performingForConnection { connection in
            try await connection.resolvePostReport(id: id, resolved: resolved)
        }
    }
    
    func resolveCommentReport(
        id: Int,
        resolved: Bool
    ) async throws -> ReportSnapshot {
        try await performingForConnection { connection in
            try await connection.resolveCommentReport(id: id, resolved: resolved)
        }
    }
    
    func resolveMessageReport(
        id: Int,
        resolved: Bool
    ) async throws -> ReportSnapshot {
        try await performingForConnection { connection in
            try await connection.resolveMessageReport(id: id, resolved: resolved)
        }
    }
}

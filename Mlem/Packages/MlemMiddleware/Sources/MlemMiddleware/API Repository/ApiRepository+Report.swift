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
        pageInfo: PageInfo,
        unresolvedOnly: Bool = false,
        communityId: Int? = nil,
        postId: Int? = nil
    ) async throws -> PagedResponse<ReportSnapshot> {
        try await performingForConnection { connection in
            try await connection.getPostReports(
                pageInfo: pageInfo,
                unresolvedOnly: unresolvedOnly,
                communityId: communityId,
                postId: postId
            )
        }
    }
    
    func getCommentReports(
        pageInfo: PageInfo,
        unresolvedOnly: Bool = false,
        communityId: Int? = nil,
        commentId: Int? = nil
    ) async throws -> PagedResponse<ReportSnapshot> {
        try await performingForConnection { connection in
            try await connection.getCommentReports(
                pageInfo: pageInfo,
                unresolvedOnly: unresolvedOnly,
                communityId: communityId,
                commentId: commentId
            )
        }
    }
    
    func getMessageReports(
        pageInfo: PageInfo,
        unresolvedOnly: Bool = false
    ) async throws -> PagedResponse<ReportSnapshot> {
        try await performingForConnection { connection in
            try await connection.getMessageReports(
                pageInfo: pageInfo,
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

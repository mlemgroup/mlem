//
//  File.swift
//  MlemMiddleware
//
//  Created by Sjmarf on 2025-07-25.
//

import Foundation

extension ReportSnapshot {
    init(from report: PieFedCommentReportView) throws(ApiClientError) {
        try self.init(
            creator: .init(from: report.creator),
            id: report.commentReport.id,
            created: report.commentReport.published,
            resolver: report.resolver.map { resolver throws(ApiClientError) in try .init(from: resolver) },
            updated: report.commentReport.updated,
            resolved: report.commentReport.resolved,
            reason: report.commentReport.reason ?? "",
            target: .comment(.init(from: report))
        )
    }
    
    init(from report: PieFedPostReportView) throws(ApiClientError) {
        try self.init(
            creator: .init(from: report.creator),
            id: report.postReport.id,
            created: report.postReport.published,
            resolver: report.resolver.map { resolver throws(ApiClientError) in try .init(from: resolver) },
            updated: report.postReport.updated,
            resolved: report.postReport.resolved,
            reason: report.postReport.reason,
            target: .post(.init(from: report))
        )
    }
}

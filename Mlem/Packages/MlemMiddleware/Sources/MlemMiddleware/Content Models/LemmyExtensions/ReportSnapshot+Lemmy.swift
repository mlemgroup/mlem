//
//  File.swift
//  MlemMiddleware
//
//  Created by Sjmarf on 2025-07-25.
//

import Foundation

extension ReportSnapshot {
    init(from report: LemmyCommentReportView) throws(ApiClientError) {
        guard let published = report.commentReport.publishedAt ?? report.commentReport.published else {
            throw .responseMissingRequiredData("LemmyCommentReportView published")
        }

        try self.init(
            creator: .init(from: report.creator),
            id: report.commentReport.id,
            created: published,
            resolver: report.resolver.map { resolver throws(ApiClientError) in try .init(from: resolver) },
            updated: report.commentReport.updatedAt ?? report.commentReport.updated,
            resolved: report.commentReport.resolved,
            reason: report.commentReport.reason,
            target: .comment(.init(from: report))
        )
    }
    
    init(from report: LemmyPostReportView) throws(ApiClientError) {
        guard let published = report.postReport.publishedAt ?? report.postReport.published else {
            throw .responseMissingRequiredData("LemmyPostReply published")
        }

        try self.init(
            creator: .init(from: report.creator),
            id: report.postReport.id,
            created: published,
            resolver: report.resolver.map { resolver throws(ApiClientError) in try .init(from: resolver) },
            updated: report.postReport.updatedAt ?? report.postReport.updated,
            resolved: report.postReport.resolved,
            reason: report.postReport.reason,
            target: .post(.init(from: report))
        )
    }
    
    init(from report: LemmyPrivateMessageReportView) throws(ApiClientError) {
        guard let published = report.privateMessageReport.publishedAt ?? report.privateMessageReport.published else {
            throw .responseMissingRequiredData("LemmyPrivateMessageReport published")
        }
        let messageView = report.toPrivateMessageView()

        try self.init(
            creator: .init(from: report.creator),
            id: report.privateMessageReport.id,
            created: published,
            resolver: report.resolver.map { resolver throws(ApiClientError) in try .init(from: resolver) },
            updated: report.privateMessageReport.updatedAt ?? report.privateMessageReport.updated,
            resolved: report.privateMessageReport.resolved,
            reason: report.privateMessageReport.reason,
            target: .message(.init(from: messageView))
        )
    }
}

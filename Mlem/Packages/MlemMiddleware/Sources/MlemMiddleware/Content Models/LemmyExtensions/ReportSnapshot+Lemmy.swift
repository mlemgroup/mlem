//
//  File.swift
//  MlemMiddleware
//
//  Created by Sjmarf on 2025-07-25.
//

import Foundation

extension ReportSnapshot {
    init(from report: LemmyCommentReportView) throws(ApiClientError) {
        self.creator = try .init(from: report.creator)
        
        self.id = report.commentReport.id
        
        if let published = report.commentReport.publishedAt ?? report.commentReport.published {
            self.created = published
        } else {
            throw .responseMissingRequiredData("LemmyCommentReportView published")
        }

        if let resolver = report.resolver {
            self.resolver = try .init(from: resolver)
        } else {
            self.resolver = nil
        }
        
        self.updated = report.commentReport.updatedAt ?? report.commentReport.updated
        self.resolved = report.commentReport.resolved
        self.reason = report.commentReport.reason
        
        do {
            self.target = try .comment(.init(from: report))
        } catch .responseMissingRequiredData {
            self.target = try .legacyComment(
                .init(from: report.comment),
                community: .init(from: report.community),
                creator: .init(from: report.creator)
            )
        }
    }
    
    init(from report: LemmyPostReportView) throws(ApiClientError) {
        self.creator = try .init(from: report.creator)
        
        self.id = report.postReport.id
        
        if let published = report.postReport.publishedAt ?? report.postReport.published {
            self.created = published
        } else {
            throw .responseMissingRequiredData("LemmyPostReply published")
        }

        if let resolver = report.resolver {
            self.resolver = try .init(from: resolver)
        } else {
            self.resolver = nil
        }
        
        self.updated = report.postReport.updatedAt ?? report.postReport.updated
        self.resolved = report.postReport.resolved
        self.reason = report.postReport.reason
        
        do {
            self.target = try .post(.init(from: report))
        } catch .responseMissingRequiredData {
            self.target = try .legacyPost(
                .init(from: report.post),
                community: .init(from: report.community),
                creator: .init(from: report.creator)
            )
        }
    }
    
    init(from report: LemmyPrivateMessageReportView) throws(ApiClientError) {
        self.creator = try .init(from: report.creator)
        
        self.id = report.privateMessageReport.id
        
        if let published = report.privateMessageReport.publishedAt ?? report.privateMessageReport.published {
            self.created = published
        } else {
            throw .responseMissingRequiredData("LemmyPrivateMessageReport published")
        }

        if let resolver = report.resolver {
            self.resolver = try .init(from: resolver)
        } else {
            self.resolver = nil
        }
        
        self.updated = report.privateMessageReport.updatedAt ?? report.privateMessageReport.updated
        self.resolved = report.privateMessageReport.resolved
        self.reason = report.privateMessageReport.reason
        
        let messageView = report.toPrivateMessageView()
        self.target = try .message(.init(from: messageView))
    }
}

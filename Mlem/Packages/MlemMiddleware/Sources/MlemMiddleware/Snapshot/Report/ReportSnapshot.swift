//
//  File.swift
//  MlemMiddleware
//
//  Created by Sjmarf on 2025-05-10.
//

import Foundation

public struct ReportSnapshot: CacheIdentifiable {
    // Won't change, but the corresponding models need to
    // be updated within the `update` method of Report.
    public let creator: Person1Snapshot
    
    // Won't change.
    public let id: Int
    public let created: Date

    // May change. If you add/remove items from this list,
    // remember to also amend the `update` method of Report!
    public let resolver: Person1Snapshot?
    public let updated: Date?
    public let resolved: Bool
    public let reason: String
    
    public let target: ReportTargetSnapshot
    
    public var cacheId: Int {
        var hasher = Hasher()
        hasher.combine(target.type)
        hasher.combine(id)
        return hasher.finalize()
    }
    
    init(from report: ApiCommentReportView) throws(ApiClientError) {
        self.creator = try .init(from: report.creator)
        
        self.id = report.commentReport.id
        self.created = report.commentReport.published
        
        if let resolver = report.resolver {
            self.resolver = try .init(from: resolver)
        } else {
            self.resolver = nil
        }
        
        self.updated = report.commentReport.updated
        self.resolved = report.commentReport.resolved
        self.reason = report.commentReport.reason
        
        if let commentView = report.toCommentView() {
            self.target = try .comment(.init(from: commentView))
        } else {
            self.target = try .legacyComment(
                .init(from: report.comment),
                community: .init(from: report.community),
                creator: .init(from: report.creator)
            )
        }
    }
    
    init(from report: ApiPostReportView) throws(ApiClientError) {
        self.creator = try .init(from: report.creator)
        
        self.id = report.postReport.id
        self.created = report.postReport.published
        
        if let resolver = report.resolver {
            self.resolver = try .init(from: resolver)
        } else {
            self.resolver = nil
        }
        
        self.updated = report.postReport.updated
        self.resolved = report.postReport.resolved
        self.reason = report.postReport.reason
        
        if let postView = report.toPostView() {
            self.target = try .post(.init(from: postView))
        } else {
            self.target = try .legacyPost(
                .init(from: report.post),
                community: .init(from: report.community),
                creator: .init(from: report.creator)
            )
        }
    }
    
    init(from report: ApiPrivateMessageReportView) throws(ApiClientError) {
        self.creator = try .init(from: report.creator)
        
        self.id = report.privateMessageReport.id
        self.created = report.privateMessageReport.published
        
        if let resolver = report.resolver {
            self.resolver = try .init(from: resolver)
        } else {
            self.resolver = nil
        }
        
        self.updated = report.privateMessageReport.updated
        self.resolved = report.privateMessageReport.resolved
        self.reason = report.privateMessageReport.reason
        
        if let messageView = report.toPrivateMessageView() {
            self.target = try .message(.init(from: messageView))
        }
    }
}

public enum ReportTargetSnapshot {
    /// All post reports use this case on 0.19.4 and above.
    case post(Post2Snapshot)
    /// All comment reports use this case on 0.19.4 and above.
    case comment(Comment2Snapshot)
    /// All messages reports use this case regardless of version.
    case message(Message2Snapshot)
    /// All post reports use this case on 0.19.3 and below.
    case legacyPost(Post1Snapshot, community: Community1Snapshot, creator: Person1Snapshot)
    /// All comment reports use this case on 0.19.3 and below.
    case legacyComment(Comment1Snapshot, community: Community1Snapshot, creator: Person1Snapshot)
    
    var type: ReportType {
        switch self {
        case .post, .legacyPost: .post
        case .comment, .legacyComment: .comment
        case .message: .message
        }
    }
}

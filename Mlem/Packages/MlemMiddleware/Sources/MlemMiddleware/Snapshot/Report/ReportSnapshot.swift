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
    
    public init(
        creator: Person1Snapshot,
        id: Int,
        created: Date,
        resolver: Person1Snapshot?,
        updated: Date?,
        resolved: Bool,
        reason: String,
        target: ReportTargetSnapshot
    ) {
        self.creator = creator
        self.id = id
        self.created = created
        self.resolver = resolver
        self.updated = updated
        self.resolved = resolved
        self.reason = reason
        self.target = target
    }
}

public enum ReportTargetSnapshot {
    case post(Post2Snapshot)
    case comment(Comment2Snapshot)
    case message(Message2Snapshot)
    
    var type: ReportType {
        switch self {
        case .post: .post
        case .comment: .comment
        case .message: .message
        }
    }
}

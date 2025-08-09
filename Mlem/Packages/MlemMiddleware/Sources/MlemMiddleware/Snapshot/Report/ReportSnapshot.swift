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

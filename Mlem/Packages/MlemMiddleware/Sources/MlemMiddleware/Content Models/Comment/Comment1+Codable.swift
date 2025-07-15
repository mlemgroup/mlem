//
//  File.swift
//  MlemMiddleware
//
//  Created by Sjmarf on 2025-03-17.
//

import Foundation

extension Comment1 {
    var apiComment: LemmyComment {
        LemmyComment(
            id: id,
            creatorId: creatorId,
            postId: postId,
            content: content,
            removed: removed,
            published: created,
            updated: updated,
            deleted: deleted,
            apId: actorId,
            local: actorId.host == api.actorId.host,
            path: ([0] + parentCommentIds + [id]).map(String.init).joined(separator: "."),
            distinguished: distinguished,
            languageId: languageId,
            publishedAt: created,
            updatedAt: updated,
            score: nil,
            upvotes: nil,
            downvotes: nil,
            childCount: nil,
            reportCount: nil,
            unresolvedReportCount: nil,
            federationPending: nil
        )
    }
}

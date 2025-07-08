//
//  File.swift
//  MlemMiddleware
//
//  Created by Sjmarf on 2025-02-23.
//

import Foundation

extension Post1 {
    var apiPost: LemmyPost {
        LemmyPost(
            id: id,
            name: title,
            url: linkUrl,
            body: content,
            creatorId: creatorId,
            communityId: communityId,
            removed: removed,
            locked: locked,
            published: created,
            updated: updated,
            deleted: deleted,
            nsfw: nsfw,
            embedTitle: embed?.title,
            embedDescription: embed?.description,
            thumbnailUrl: thumbnailUrl,
            apId: actorId,
            local: actorId.host == api.actorId.host,
            embedVideoUrl: embed?.videoUrl,
            languageId: languageId,
            featuredCommunity: pinnedCommunity,
            featuredLocal: pinnedInstance,
            urlContentType: nil,
            altText: altText,
            scheduledPublishTime: nil,
            comments: nil,
            score: nil,
            upvotes: nil,
            downvotes: nil,
            newestCommentTime: nil,
            reportCount: nil,
            unresolvedReportCount: nil,
            federationPending: nil
        )
    }
}

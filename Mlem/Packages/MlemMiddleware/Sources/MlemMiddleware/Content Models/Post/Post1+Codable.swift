//
//  File.swift
//  MlemMiddleware
//
//  Created by Sjmarf on 2025-02-23.
//

import Foundation

extension Post1 {
    var apiPost: ApiPost {
        ApiPost(
            id: id,
            name: title,
            url: linkUrl?.absoluteString,
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
            actorId: actorId,
            local: actorId.host == api.actorId.host,
            embedVideoUrl: embed?.videoUrl,
            languageId: languageId,
            featuredCommunity: pinnedCommunity,
            featuredLocal: pinnedInstance,
            urlContentType: nil,
            altText: altText,
            scheduledPublishTime: nil
        )
    }
}

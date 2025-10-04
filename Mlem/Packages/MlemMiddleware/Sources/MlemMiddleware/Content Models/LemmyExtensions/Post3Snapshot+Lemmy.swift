//
//  File.swift
//  MlemMiddleware
//
//  Created by Sjmarf on 2025-07-14.
//

import Foundation

extension Post3Snapshot {
    init(from post: LemmyGetPostResponse) throws(ApiClientError) {
        var crossPosts: [Post2Snapshot] = []
        for crossPost in post.crossPosts {
            try crossPosts.append(.init(from: crossPost))
        }

        try self.init(
            post: .init(from: post.postView),
            community: .init(from: post.communityView),
            crossPosts: crossPosts
        )
    }
}

//
//  File.swift
//  MlemMiddleware
//
//  Created by Sjmarf on 2025-07-14.
//

import Foundation

extension Post3Snapshot {
    init(from post: LemmyGetPostResponse) throws(ApiClientError) {
        self.post = try .init(from: post.postView)
        self.community = try .init(from: post.communityView)
        
        var crossPosts: [Post2Snapshot] = []
        for crossPost in post.crossPosts {
            try crossPosts.append(.init(from: crossPost))
        }
        self.crossPosts = crossPosts
    }
}

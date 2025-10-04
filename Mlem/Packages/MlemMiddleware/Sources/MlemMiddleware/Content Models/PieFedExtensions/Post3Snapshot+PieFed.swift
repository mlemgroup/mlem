//
//  File.swift
//  MlemMiddleware
//
//  Created by Sjmarf on 2025-06-19.
//

import Foundation

public extension Post3Snapshot {
    init(from post: PieFedGetPostResponse) throws(ApiClientError) {
        var crossPosts: [Post2Snapshot] = []
        for crossPost in post.crossPosts {
            try crossPosts.append(.init(from: crossPost))
        }

        try self.init(
            post: .init(from: post.postView),
            community: .init(from: post.communityView, allPropertiesPresent: false),
            crossPosts: crossPosts
        )
    }
}

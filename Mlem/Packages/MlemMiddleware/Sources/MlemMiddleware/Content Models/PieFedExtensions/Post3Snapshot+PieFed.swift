//
//  File.swift
//  MlemMiddleware
//
//  Created by Sjmarf on 2025-06-19.
//

import Foundation

public extension Post3Snapshot {
    init(from post: PieFedGetPostResponse) throws(ApiClientError) {
        self.post = try .init(from: post.postView)
        self.community = try .init(from: post.communityView, allPropertiesPresent: true)
        
        var crossPosts: [Post2Snapshot] = []
        for crossPost in post.crossPosts {
            try crossPosts.append(.init(from: crossPost))
        }
        self.crossPosts = crossPosts
    }
}

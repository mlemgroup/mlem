//
//  File.swift
//  MlemMiddleware
//
//  Created by Sjmarf on 2025-07-25.
//

import Foundation

extension PieFedPostAggregates: ApiContentAggregatesProtocol {
    static var zero: Self {
        .init(
            postId: 0,
            comments: 0,
            score: 0,
            upvotes: 0,
            downvotes: 0,
            published: .distantPast,
            newestCommentTime: .distantPast,
            crossPosts: 0
        )
    }
}

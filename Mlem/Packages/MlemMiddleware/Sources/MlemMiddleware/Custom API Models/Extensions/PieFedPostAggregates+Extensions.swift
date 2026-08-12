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
            comments: 0,
            downvotes: 0,
            newestCommentTime: .distantPast,
            postId: 0,
            published: .distantPast,
            score: 0,
            upvotes: 0,
            crossPosts: 0
        )
    }
}

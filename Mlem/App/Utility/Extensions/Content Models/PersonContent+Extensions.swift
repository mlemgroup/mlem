//
//  PersonContent+Extensions.swift
//  Mlem
//
//  Created by Sjmarf on 2024-10-31.
//

import MlemMiddleware

extension PersonContent {
    var shouldHideInFeed: Bool {
        switch wrappedValue {
        case let .post(post): post.shouldHideInFeed
        case let .comment(comment): comment.shouldHideInFeed
        }
    }
}

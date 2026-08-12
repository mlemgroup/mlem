//
//  PersonContentSnapshot+Lemmy.swift
//  Mlem
//
//  Created by Sjmarf on 2026-08-07.
//

import Foundation

extension PersonContentSnapshot {
    init(from personContent: LemmyPostCommentCombinedView) throws (ApiClientError) {
        self = switch personContent {
        case let .post(post): try .post(.init(from: post))
        case let .comment(comment): try .comment(.init(from: comment))
        }
    }
}

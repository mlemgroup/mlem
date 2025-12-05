//
//  LemmyPersonSavedCombinedView+Extensions.swift
//  MlemMiddleware
//
//  Created by Sjmarf on 2025-11-25.
//

import Foundation

extension LemmyPostCommentCombinedView {
    var postValue: LemmyPostView? {
        switch self {
        case let .post(post): post
        case .comment: nil
        }
    }

    var commentValue: LemmyCommentView? {
        switch self {
        case let .comment(comment): comment
        case .post: nil
        }
    }
}

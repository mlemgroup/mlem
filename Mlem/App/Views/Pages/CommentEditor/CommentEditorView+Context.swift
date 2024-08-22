//
//  CommentEditorView+Context.swift
//  Mlem
//
//  Created by Sjmarf on 20/08/2024.
//

import MlemMiddleware

extension CommentEditorView {
    enum Context: Hashable {
        case post(any Post1Providing)
        case comment(any Comment1Providing)
        
        static func == (lhs: Context, rhs: Context) -> Bool {
            lhs.hashValue == rhs.hashValue
        }
        
        func hash(into hasher: inout Hasher) {
            switch self {
            case let .post(post):
                hasher.combine("post")
                hasher.combine(post.hashValue)
            case let .comment(comment):
                hasher.combine("comment")
                hasher.combine(comment.hashValue)
            }
        }
        
        var api: ApiClient {
            switch self {
            case let .post(post):
                post.api
            case let .comment(comment):
                comment.api
            }
        }
    }
}

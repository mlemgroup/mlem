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
        case unifiedPost(UnifiedPostModel)
        
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
            case let .unifiedPost(post):
                hasher.combine("unifiedPost")
                hasher.combine(post.actorId.hashValue) // TODO: NOW make it hashable
            }
        }
        
        var item: any SelectableContentProviding {
            switch self {
            case let .post(post): post
            case let .comment(comment): comment
            case let .unifiedPost(post): post
            }
        }
        
        var api: ApiClient {
            switch self {
            case let .post(post):
                post.api
            case let .comment(comment):
                comment.api
            case let .unifiedPost(post):
                post.api
            }
        }
    }
}

//
//  SingleSourceMixedFeedLoader+Extensions.swift
//  Mlem
//
//  Created by Sjmarf on 2025-10-29.
//  

import MlemMiddleware

extension SingleSourceMixedFeedLoader {
    func itemsForType(_ type: PersonContentType) -> [PersonContent] {
        switch type {
        case .all: items
        case .posts: posts
        case .comments: comments
        }
    }
    
    func loadingStateForType(_ type: PersonContentType) -> FeedLoadingState {
        switch type {
        case .all: loadingState
        case .posts: postLoadingState
        case .comments: commentLoadingState
        }
    }
}

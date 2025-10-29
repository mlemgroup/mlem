//
//  PersonContentGridView+FeedLoaderType.swift
//  Mlem
//
//  Created by Sjmarf on 2025-10-29.
//  

import Foundation
import MlemMiddleware

extension PersonContentGridView {
    enum FeedLoaderType {
        case dualSourceMixed(StandardFeedLoader<PersonContent>)
        case post(StandardFeedLoader<Post2>)
        case comment(StandardFeedLoader<Comment2>)
        case singleSourceMixed(SingleSourceMixedFeedLoader, contentType: PersonContentType)

        var items: [PersonContent] {
            switch self {
            case let .dualSourceMixed(feedLoader): feedLoader.items
            case let .post(feedLoader): feedLoader.items.map { .init(wrappedValue: .post($0)) }
            case let .comment(feedLoader): feedLoader.items.map { .init(wrappedValue: .comment($0)) }
            case let .singleSourceMixed(feedLoader, contentType): feedLoader.itemsForType(contentType)
            }
        }
        
        var loadingState: FeedLoadingState {
            switch self {
            case let .singleSourceMixed(feedLoader, contentType): feedLoader.loadingStateForType(contentType)
            default: feedLoading.loadingState
            }
        }
        
        var feedLoading: any FeedLoading {
            switch self {
            case let .dualSourceMixed(feedLoader): feedLoader
            case let .post(feedLoader): feedLoader
            case let .comment(feedLoader): feedLoader
            case let .singleSourceMixed(feedLoader, _): feedLoader
            }
        }
        
        func loadIfThreshold(_ item: PersonContent) throws {
            switch self {
            case let .dualSourceMixed(feedLoader): try feedLoader.loadIfThreshold(item)
            case let .post(feedLoader):
                switch item.wrappedValue {
                case let .post(post):
                    try feedLoader.loadIfThreshold(post)
                default:
                    assertionFailure()
                }
            case let .comment(feedLoader):
                switch item.wrappedValue {
                case let .comment(comment):
                    try feedLoader.loadIfThreshold(comment)
                default:
                    assertionFailure()
                }
            case let .singleSourceMixed(feedLoader, contentType):
                try feedLoader.loadIfThreshold(item, asChild: contentType != .all)
            }
        }
    }
}

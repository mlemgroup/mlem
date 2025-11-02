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
        case standard(StandardFeedLoader<PersonContent>, contentType: PersonContentType)
        case singleSourceMixed(SingleSourceMixedFeedLoader, contentType: PersonContentType)

        var items: [PersonContent] {
            switch self {
            case let .standard(feedLoader, _): feedLoader.items
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
            case let .standard(feedLoader, _): feedLoader
            case let .singleSourceMixed(feedLoader, _): feedLoader
            }
        }
        
        func loadIfThreshold(_ item: PersonContent) throws {
            switch self {
            case let .standard(feedLoader, _): try feedLoader.loadIfThreshold(item)
            case let .singleSourceMixed(feedLoader, contentType):
                try feedLoader.loadIfThreshold(item, asChild: contentType != .all)
            }
        }
        
        var type: PersonContentType {
            switch self {
            case let .standard(_, type): type
            case let .singleSourceMixed(_, type): type
            }
        }
    }
}

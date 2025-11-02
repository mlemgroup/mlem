//
//  DualSourceMixedFeedLoader.swift
//  MlemMiddleware
//
//  Created by Sjmarf on 2025-10-29.
//

import Foundation

// A feed loader that loads both posts and comments, with two child feed loaders that fetch from different sources.
public class DualSourceMixedFeedLoader: StandardFeedLoader<PersonContent> {
    public init(
        api: ApiClient,
        pageSize: Int,
        sources: [ChildFeedLoader<PersonContent>],
        sortType: FeedLoaderSort.SortType
    ) {
        super.init(
            filter: MultiFilter(),
            fetcher: MultiFetcher(
                api: api,
                pageSize: pageSize,
                sources: sources,
                sortType: sortType
            )
        )
        
        for source in sources {
            source.setParent(parent: self)
        }
    }
    
    public static func setup(
        api: ApiClient,
        pageSize: Int,
        sortType: FeedLoaderSort.SortType,
        filter: GetContentFilter
    ) -> (
        postFeedLoader: PostChildFeedLoader,
        commentFeedLoader: CommentChildFeedLoader,
        savedFeedLoader: DualSourceMixedFeedLoader
    ) {
        let postFeedLoader: PostChildFeedLoader = .init(
            api: api,
            pageSize: pageSize,
            sortType: sortType,
            filter: filter
        )
        
        let commentFeedLoader: CommentChildFeedLoader = .init(
            api: api,
            pageSize: pageSize,
            sortType: sortType,
            filter: filter
        )
        
        let savedFeedLoader: DualSourceMixedFeedLoader = .init(
            api: api,
            pageSize: pageSize,
            sources: [postFeedLoader, commentFeedLoader],
            sortType: sortType
        )
        
        return (postFeedLoader, commentFeedLoader, savedFeedLoader)
    }
}

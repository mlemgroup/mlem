//
//  SavedFeedLoader.swift
//  MlemMiddleware
//
//  Created by Sjmarf on 2025-10-29.
//

import Foundation

public class SavedFeedLoader: StandardFeedLoader<PersonContent> {
    var savedFetcher: MultiFetcher<PersonContent> { fetcher as! MultiFetcher }
    
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
        sortType: FeedLoaderSort.SortType
    ) -> (
        postFeedLoader: SavedPostChildFeedLoader,
        commentFeedLoader: SavedCommentChildFeedLoader,
        savedFeedLoader: SavedFeedLoader
    ) {
        let postFeedLoader: SavedPostChildFeedLoader = .init(api: api, pageSize: pageSize, sortType: sortType)
        let commentFeedLoader: SavedCommentChildFeedLoader = .init(api: api, pageSize: pageSize, sortType: sortType)
        
        let savedFeedLoader: SavedFeedLoader = .init(
            api: api,
            pageSize: pageSize,
            sources: [postFeedLoader, commentFeedLoader],
            sortType: sortType
        )
        
        return (
        postFeedLoader, commentFeedLoader, savedFeedLoader
        )
    }
}

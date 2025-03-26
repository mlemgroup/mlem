//
//  ModlogChildFeedLoader.swift
//  MlemMiddleware
//
//  Created by Sjmarf on 2024-12-28.
//

import Foundation

public class ModlogChildFeedLoader: ChildFeedLoader<ModlogEntry> {
    var modlogFetcher: ModlogChildFetcher { fetcher as! ModlogChildFetcher }
    
    public init(api: ApiClient, sortType: FeedLoaderSort.SortType, fetcher: ModlogChildFetcher) {
        super.init(filter: ModlogEntryFilter(), fetcher: fetcher, sortType: sortType)
    }
}

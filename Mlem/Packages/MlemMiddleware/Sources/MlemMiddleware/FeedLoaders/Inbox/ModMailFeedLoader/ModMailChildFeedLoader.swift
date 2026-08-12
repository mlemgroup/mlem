//
//  ModMailChildFeedLoader.swift
//  MlemMiddleware
//
//  Created by Eric Andrews on 2024-12-04.
//

public class ModMailChildFeedLoader: ChildFeedLoader<ModMailItem>, InboxFeedLoading {
    var modMailFetcher: ModMailFetcher { fetcher as! ModMailFetcher }
    
    public init(api: ApiClient, sortType: FeedLoaderSort.SortType, fetcher: ModMailFetcher, showRead: Bool) {
        super.init(filter: ModMailItemFilter(showRead: showRead), fetcher: fetcher, sortType: sortType)
    }
    
    func hideRead() async throws {
        try await loadingActor.activateFilter(.read) {
            modMailFetcher.hideRead()
            try await refresh(clearBeforeRefresh: true)
        }
    }
    
    func showRead() async throws {
        try await loadingActor.deactivateFilter(.read) {
            modMailFetcher.showRead()
            try await refresh(clearBeforeRefresh: true)
        }
    }
}

//
//  InboxChildFeedLoader.swift
//  MlemMiddleware
//
//  Created by Eric Andrews on 2024-12-04.
//

public class InboxChildFeedLoader: ChildFeedLoader<InboxItem> {
    
    var inboxFetcher: InboxFetcher { fetcher as! InboxFetcher }
    
    public init(api: ApiClient, sortType: FeedLoaderSort.SortType, fetcher: InboxFetcher, showRead: Bool) {
        super.init(filter: InboxItemFilter(showRead: showRead), fetcher: fetcher, sortType: sortType)
    }
    
    func hideRead() async throws {
        try await loadingActor.activateFilter(.read) {
            await setItems(loadingActor.filter.reset(with: items))
            inboxFetcher.hideRead(unreadCount: items.count)
            
            if items.isEmpty {
                try await refresh(clearBeforeRefresh: false)
            }
        }
    }
    
    func showRead() async throws {
        try await loadingActor.deactivateFilter(.read) {
            inboxFetcher.showRead()
            try await refresh(clearBeforeRefresh: true)
        }
    }
}

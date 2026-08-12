//
//  MentionChildFeedLoader.swift
//  MlemMiddleware
//
//  Created by Eric Andrews on 2024-12-02.
//

public class MentionChildFeedLoader: InboxChildFeedLoader {
    class Fetcher: InboxFetcher {
        override func fetchContent(_ pageInfo: PageInfo) async throws -> PagedResponse<InboxNotification> {
            try await api.getMentionNotifications(pageInfo: pageInfo, unreadOnly: unreadOnly)
        }
    }
    
    public init(api: ApiClient, pageSize: Int, sortType: FeedLoaderSort.SortType, showRead: Bool) {
        super.init(
            api: api,
            sortType: sortType,
            fetcher: Fetcher(
                api: api,
                pageSize: pageSize,
                unreadOnly: !showRead
            ),
            showRead: showRead
        )
    }
}

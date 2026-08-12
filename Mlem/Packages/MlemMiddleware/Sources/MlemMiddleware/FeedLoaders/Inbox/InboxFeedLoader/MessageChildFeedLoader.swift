//
//  MessageChildFeedLoader.swift
//  MlemMiddleware
//
//  Created by Eric Andrews on 2024-11-26.
//

public class MessageChildFeedLoader: InboxChildFeedLoader {
    class Fetcher: InboxFetcher {
        override func fetchContent(_ pageInfo: PageInfo) async throws -> PagedResponse<InboxNotification> {
            try await api.getMessageNotifications(pageInfo: pageInfo, unreadOnly: unreadOnly)
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

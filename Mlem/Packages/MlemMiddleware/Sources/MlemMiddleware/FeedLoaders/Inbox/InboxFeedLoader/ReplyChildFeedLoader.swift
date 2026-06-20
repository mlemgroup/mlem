//
//  ReplyChildFeedLoader.swift
//  MlemMiddleware
//
//  Created by Eric Andrews on 2024-11-27.
//

public class ReplyChildFeedLoader: InboxChildFeedLoader {
    class Fetcher: InboxFetcher {
        override func fetchContent(_ pageInfo: PageInfo) async throws -> PagedResponse<InboxNotification> {
            try await api.getReplyNotifications(pageInfo: pageInfo, unreadOnly: unreadOnly)
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

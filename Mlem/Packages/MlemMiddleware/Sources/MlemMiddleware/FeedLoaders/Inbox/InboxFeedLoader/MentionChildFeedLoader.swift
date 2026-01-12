//
//  MentionChildFeedLoader.swift
//  MlemMiddleware
//
//  Created by Eric Andrews on 2024-12-02.
//

public class MentionChildFeedLoader: InboxChildFeedLoader {
    class Fetcher: InboxFetcher {
        override func fetchPage(_ page: Int) async throws -> FetchResponse {
            let response = try await api.getMentionNotifications(
                page: page,
                limit: pageSize,
                unreadOnly: unreadOnly
            )
            return .init(
                items: response,
                prevCursor: nil,
                nextCursor: nil
            )
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

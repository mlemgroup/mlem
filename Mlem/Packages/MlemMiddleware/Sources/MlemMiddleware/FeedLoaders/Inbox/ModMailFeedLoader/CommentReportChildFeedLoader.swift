//
//  CommentReportChildFeedLoader.swift
//  MlemMiddleware
//
//  Created by Eric Andrews on 2024-11-26.
//

public class CommentReportChildFeedLoader: ModMailChildFeedLoader {
    class Fetcher: ModMailFetcher {
        override func fetchContent(_ pageInfo: PageInfo) async throws -> PagedResponse<ModMailItem> {
            do {
                let response = try await api.getCommentReports(pageInfo: pageInfo, unresolvedOnly: unreadOnly)
                return .init(
                    items: response.items.map { .report($0) },
                    nextLocation: response.nextLocation
                )
            } catch ApiClientError.notModOrAdmin {
                return .init(items: [], nextLocation: .end)
            }
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

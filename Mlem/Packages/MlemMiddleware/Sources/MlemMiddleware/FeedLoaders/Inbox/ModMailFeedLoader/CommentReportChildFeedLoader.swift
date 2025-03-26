//
//  CommentReportChildFeedLoader.swift
//  MlemMiddleware
//
//  Created by Eric Andrews on 2024-11-26.
//

public class CommentReportChildFeedLoader: ModMailChildFeedLoader {
    class Fetcher: ModMailFetcher {
        override func fetchPage(_ page: Int) async throws -> FetchResponse {
            do {
                let response = try await api.getCommentReports(page: page, limit: pageSize, unresolvedOnly: unreadOnly)
                return .init(
                    items: response.map { .report($0) },
                    prevCursor: nil,
                    nextCursor: nil
                )
            } catch let ApiClientError.response(response, _) where response.notModOrAdmin {
                return .init(items: .init(), prevCursor: nil, nextCursor: nil)
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

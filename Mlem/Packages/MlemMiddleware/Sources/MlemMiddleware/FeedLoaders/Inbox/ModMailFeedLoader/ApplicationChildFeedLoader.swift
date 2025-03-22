//
//  ApplicationChildFeedLoader.swift
//  MlemMiddleware
//
//  Created by Eric Andrews on 2024-12-02.
//

public class ApplicationChildFeedLoader: ModMailChildFeedLoader {
    class Fetcher: ModMailFetcher {
        override func fetchPage(_ page: Int) async throws -> FetchResponse {
            guard api.isAdmin else { return .init(items: [], prevCursor: nil, nextCursor: nil) }
            
            do {
                let response = try await api.getRegistrationApplications(page: page, limit: pageSize, unreadOnly: unreadOnly)
                return .init(
                    items: response.map { .application($0) },
                    prevCursor: nil,
                    nextCursor: nil
                )
            } catch let ApiClientError.response(response, _) where response.notAdmin {
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

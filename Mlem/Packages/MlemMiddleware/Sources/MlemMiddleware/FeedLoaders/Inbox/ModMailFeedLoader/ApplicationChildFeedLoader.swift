//
//  ApplicationChildFeedLoader.swift
//  MlemMiddleware
//
//  Created by Eric Andrews on 2024-12-02.
//

public class ApplicationChildFeedLoader: ModMailChildFeedLoader {
    class Fetcher: ModMailFetcher {
        override func fetchContent(_ pageInfo: PageInfo) async throws -> PagedResponse<ModMailItem> {
            guard api.isAdmin else { return .init(items: [], nextLocation: .end) }
            
            do {
                let response = try await api.getRegistrationApplications(pageInfo: pageInfo, unreadOnly: unreadOnly)
                return .init(
                    items: response.items.map { .application($0) },
                    nextLocation: response.nextLocation
                )
            } catch ApiClientError.notAdmin {
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

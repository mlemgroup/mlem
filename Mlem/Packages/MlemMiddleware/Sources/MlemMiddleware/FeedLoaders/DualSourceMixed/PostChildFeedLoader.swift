//
//  PostChildFeedLoader.swift
//  MlemMiddleware
//
//  Created by sjmarf on 2025-10-29.
//

public class PostChildFeedLoader: ChildFeedLoader<PersonContent> {
    class Fetcher: MlemMiddleware.Fetcher<PersonContent> {
        let filter: GetContentFilter
        
        init(
            api: ApiClient,
            pageSize: Int,
            filter: GetContentFilter
        ) {
            self.filter = filter
            super.init(api: api, pageSize: pageSize)
        }

        override func fetchContent(_ pageInfo: PageInfo) async throws -> PagedResponse<PersonContent> {
            let response = try await api.getPostHistory(
                type: self.filter,
                pageInfo: pageInfo
            )

            return .init(
                items: response.items.map { PersonContent(wrappedValue: .post($0)) },
                nextLocation: response.nextLocation
            )
        }
    }

    public init(
        api: ApiClient,
        pageSize: Int,
        sortType: FeedLoaderSort.SortType,
        filter: GetContentFilter
    ) {
        super.init(
            filter: MultiFilter(),
            fetcher: Fetcher(api: api, pageSize: pageSize, filter: filter),
            sortType: sortType
        )
    }
}

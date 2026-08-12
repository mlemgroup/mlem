//
//  CommentChildFeedLoader.swift
//  MlemMiddleware
//
//  Created by sjmarf on 2025-10-29.
//

public class CommentChildFeedLoader: ChildFeedLoader<PersonContent> {
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
            let response = try await api.getCommentHistory(
                type: self.filter,
                pageInfo: pageInfo
            )

            return .init(
                items: response.items.map { PersonContent(wrappedValue: .comment($0)) },
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

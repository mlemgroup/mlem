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
            page: Int = 0,
            filter: GetContentFilter
        ) {
            self.filter = filter
            super.init(api: api, pageSize: pageSize, page: page)
        }
        
        override func fetchPage(_ page: Int) async throws -> FetchResponse {
            try await internalFetchCursor(page: page, cursor: nil)
        }

        override func fetchCursor(_ cursor: String) async throws -> FetchResponse {
            try await internalFetchCursor(page: nil, cursor: cursor)
        }

        private func internalFetchCursor(page: Int?, cursor: String?) async throws -> FetchResponse {
            let response = try await api.getCommentHistory(
                page: page,
                cursor: cursor,
                limit: pageSize
            )

            return .init(
                items: response.comments.map { PersonContent(wrappedValue: .comment($0)) },
                prevCursor: cursor,
                nextCursor: response.cursor
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

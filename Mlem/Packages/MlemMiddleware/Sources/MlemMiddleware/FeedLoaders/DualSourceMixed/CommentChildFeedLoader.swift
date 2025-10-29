//
//  CommentChildFeedLoader.swift
//  MlemMiddleware
//
//  Created by sjmarf on 2025-10-29.
//

public class CommentChildFeedLoader: ChildFeedLoader<PersonContent> {
    class Fetcher: MlemMiddleware.Fetcher<PersonContent> {
        override func fetchPage(_ page: Int) async throws -> FetchResponse {
            let response = try await api.getComments(
                sort: .new,
                page: page,
                limit: pageSize,
                filter: .saved
            )
            return .init(
                items: response.map { PersonContent(wrappedValue: .comment($0)) },
                prevCursor: nil,
                nextCursor: nil
            )
        }
    }

    public init(api: ApiClient, pageSize: Int, sortType: FeedLoaderSort.SortType) {
        super.init(
            filter: MultiFilter(),
            fetcher: Fetcher(api: api, pageSize: pageSize),
            sortType: sortType
        )
    }
}

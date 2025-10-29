//
//  PostChildFeedLoader.swift
//  MlemMiddleware
//
//  Created by sjmarf on 2025-10-29.
//

public class PostChildFeedLoader: ChildFeedLoader<PersonContent> {
    class Fetcher: MlemMiddleware.Fetcher<PersonContent> {
        override func fetchPage(_ page: Int) async throws -> FetchResponse {
            let response = try await api.getPosts(
                feed: .all,
                sort: .new,
                page: page,
                cursor: nil,
                limit: pageSize,
                filter: .saved
            )
            return .init(
                items: response.posts.map { PersonContent(wrappedValue: .post($0)) },
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

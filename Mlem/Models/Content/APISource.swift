//
//  ApiSource.swift
//  Mlem
//
//  Created by Sjmarf on 15/02/2024.
//

import Foundation

protocol ApiSource: AnyObject, ActorIdentifiable, Equatable {
    var caches: BaseCacheGroup { get }
    var api: ApiClient { get }
    var instance: InstanceStub { get }
}

extension ApiSource {
    func getPosts(
        feed: ApiListingType,
        sort: PostSortType,
        page: Int = 1,
        cursor: String? = nil,
        limit: Int,
        savedOnly: Bool = false
    ) async throws -> (posts: [Post2], cursor: String?) {
        let response = try await api.getPosts(
            feedType: feed,
            sort: sort,
            page: page,
            cursor: cursor,
            limit: limit,
            savedOnly: savedOnly
        )
        return (
            posts: response.posts.map { caches.post2.createModel(source: self, for: $0) },
            cursor: cursor
        )
    }
}

class MockApiSource: ApiSource {
    var caches: BaseCacheGroup = .init()
    
    let actorId: URL = .init(string: "https://lemmy.world")!
    let instance: InstanceStub = .mock
    var api: ApiClient { fatalError("You cannot access the 'api' property of MockApiSource.") }
}

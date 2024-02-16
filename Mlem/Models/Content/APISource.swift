//
//  APISource.swift
//  Mlem
//
//  Created by Sjmarf on 15/02/2024.
//

import Foundation

protocol APISource: AnyObject, ActorIdentifiable, Equatable {
    var caches: BaseCacheGroup { get }
    var api: APIClient { get }
    var instance: InstanceStub { get }
}

extension APISource {
    func getPosts(
        feed: APIListingType,
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
            posts: response.posts.map { caches.post2.createModel(source: self, for: $0)},
            cursor: cursor
        )
    }
}

class MockAPISource: APISource {
    var caches: BaseCacheGroup = .init()
    
    let actorId: URL = .init(string: "https://lemmy.world")!
    let instance: InstanceStub = .mock
    var api: APIClient { fatalError("You cannot access the 'api' property of MockAPISource.") }

}

//
//  APISource.swift
//  Mlem
//
//  Created by Sjmarf on 15/02/2024.
//

import Foundation

protocol APISource: AnyObject, ActorIdentifiable, Equatable {
    var caches: BaseCacheGroup { get }
    var api: NewAPIClient { get }
    var instance: NewInstanceStub { get }
    
    func getPosts(
        sort: PostSortType,
        page: Int,
        cursor: String?,
        limit: Int,
        savedOnly: Bool
    ) async throws -> (posts: [Post2], cursor: String?)
}

class MockAPISource: APISource {
    var caches: BaseCacheGroup = .init()
    
    let actorId: URL = .init(string: "https://lemmy.world")!
    let instance: NewInstanceStub = .mock
    var api: NewAPIClient { fatalError("You cannot access the 'api' property of MockAPISource.") }
    
    func getPosts(
        sort: PostSortType,
        page: Int,
        cursor: String?,
        limit: Int,
        savedOnly: Bool
    ) async throws -> (posts: [Post2], cursor: String?) {
        return (posts: [], cursor: nil)
    }
    
}

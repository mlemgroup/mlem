//
//  ApiClient+Mock.swift
//  MlemMiddleware
//
//  Created by Sjmarf on 2025-02-02.
//

import Foundation
import Rest

#if DEBUG

public extension ApiClient {
    static let mock: MockApiClient = .init()
}

public class MockApiClient: ApiClient {
    public init(
        posts: [Post2] = [],
        communities: [Community2] = [],
        people: [Person2] = [],
        comments: [Comment2] = []
    ) {
        let url = URL(string: "https://lemmy.world/")!
        let username = ""
        super.init(
            url: url,
            username: username
        )
        
        self.repository = MockApiRepository(url: url, username: username, posts: posts, communities: communities, people: people, comments: comments)
    }
    
    private var mockRepository: MockApiRepository { repository as! MockApiRepository }
    
    public func setPosts(_ posts: [Post2]) {
        mockRepository.posts = posts
    }
    
    public func setCommunities(_ communities: [Community2]) {
        mockRepository.communities = communities
    }
    
    public func setPeople(_ people: [Person2]) {
        mockRepository.people = people
    }
}

#endif

//
//  Post3.swift
//  MlemMiddleware
//
//  Created by Sjmarf on 25/09/2024.
//

import Foundation
import Observation

@Observable
public final class Post3: Post3Providing {
    public static let tierNumber: Int = 3
    public var api: ApiClient
    public var post3: Post3 { self }
    
    public let post2: Post2
    public let community: Community2
    public var communityModerators: [Person1]
    public var crossPosts: [Post2]
    
    internal init(
        api: ApiClient,
        post2: Post2,
        community: Community2,
        communityModerators: [Person1],
        crossPosts: [Post2]
    ) {
        self.api = api
        self.post2 = post2
        self.community = community
        self.communityModerators = communityModerators
        self.crossPosts = crossPosts
    }
}


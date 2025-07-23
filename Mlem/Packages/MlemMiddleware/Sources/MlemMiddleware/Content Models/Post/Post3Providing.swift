//
//  Post3Providing.swift
//  MlemMiddleware
//
//  Created by Sjmarf on 25/09/2024.
//

import Foundation
import Nuke

public protocol Post3Providing: Post2Providing {
    var post3: Post3 { get }
    var crossPosts: [Post2] { get }
}

public extension Post3Providing {
    var updateQueue: PostUpdateQueue { post1.updateQueue }
    
    func upgrade() async throws -> any Post { self }

    // Override `Post2Providing` definition
    var community: Community2 { post3.community }
    var community_: (Community2)? { post3.community }
    
    var crossPosts: [Post2] { post3.crossPosts }
    
    var crossPosts_: [Post2]? { post3.crossPosts }
}

// ImagePrefetchProviding conformance
public extension Post3Providing {
    func imageRequests(configuration config: PrefetchingConfiguration) async -> [ImageRequest] {
        await post2.imageRequests(configuration: config)
    }
}

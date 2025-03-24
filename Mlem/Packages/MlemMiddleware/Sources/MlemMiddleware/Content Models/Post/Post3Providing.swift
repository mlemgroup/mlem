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
    
    var communityModerators: [Person1] { get }
    var crossPosts: [Post2] { get }
}

public extension Post3Providing {
    func upgrade() async throws -> any Post { self }

    // Override `Post2Providing` definition
    var community: any Community { post3.community }
    var community_: (any Community)? { post3.community }
    
    var communityModerators: [Person1] { post3.communityModerators }
    var crossPosts: [Post2] { post3.crossPosts }
    
    var communityModerators_: [Person1]? { post3.communityModerators }
    var crossPosts_: [Post2]? { post3.crossPosts }
}

// ImagePrefetchProviding conformance
public extension Post3Providing {
    func imageRequests(configuration config: PrefetchingConfiguration) async -> [ImageRequest] {
        await post2.imageRequests(configuration: config)
    }
}

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

// snapshot methods
extension Post3Providing {
    public func snapshotUpdate(with snapshot: any PostSnapshotProviding) {
        if let post3snapshot = snapshot as? Post3Snapshot {
            snapshot3Update(with: post3snapshot)
        } else if let post2snapshot = snapshot as? Post2Snapshot {
            post2.snapshot2Update(with: post2snapshot)
        } else if let post1snapshot = snapshot as? Post1Snapshot {
            post2.post1.snapshot1Update(with: post1snapshot)
        } else {
            assertionFailure("Unrecognized post snapshot")
        }
    }
    
    internal func snapshot3Update(with snapshot: Post3Snapshot) {
        // self.crossPosts = snapshot.crossPosts // TODO: get models from cache
        post2.snapshot2Update(with: snapshot.post)
    }
    
    public func takeSnapshot() -> any PostSnapshotProviding {
        takeSnapshot3()
    }
    
    internal func takeSnapshot3() -> Post3Snapshot {
        .init(
            post: post2.takeSnapshot2(),
            community: community.takeSnapshot2(),
            crossPosts: crossPosts.map { $0.takeSnapshot2() }
        )
    }
}

// ImagePrefetchProviding conformance
public extension Post3Providing {
    func imageRequests(configuration config: PrefetchingConfiguration) async -> [ImageRequest] {
        await post2.imageRequests(configuration: config)
    }
}

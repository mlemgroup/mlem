//
//  Post3Providing+Snapshots.swift
//  MlemMiddleware
//
//  Created by Eric Andrews on 2025-07-22.
//

extension Post3Providing {
    @MainActor
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
    
    @MainActor
    internal func snapshot3Update(with snapshot: Post3Snapshot) {
        // self.crossPosts = snapshot.crossPosts // TODO: NOW get models from cache
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

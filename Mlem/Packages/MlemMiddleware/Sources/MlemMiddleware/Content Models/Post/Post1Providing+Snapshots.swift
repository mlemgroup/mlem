//
//  Post1Providing+Snapshots.swift
//  MlemMiddleware
//
//  Created by Eric Andrews on 2025-07-22.
//

public extension Post1Providing {
    func snapshotUpdate(with snapshot: any PostSnapshotProviding) async {
        if let post3snapshot = snapshot as? Post3Snapshot {
            await snapshot1Update(with: post3snapshot.post.post)
        } else if let post2snapshot = snapshot as? Post2Snapshot {
            await snapshot1Update(with: post2snapshot.post)
        } else if let post1snapshot = snapshot as? Post1Snapshot {
            await snapshot1Update(with: post1snapshot)
        } else {
            assertionFailure("Unrecognized post snapshot")
        }
    }
    
    @MainActor
    internal func snapshot1Update(with snapshot: Post1Snapshot) {
        post1.setIfChanged(\.title, snapshot.title)
        post1.setIfChanged(\.content, snapshot.content)
        post1.setIfChanged(\.linkUrl, snapshot.linkUrl)
        post1.setIfChanged(\.embed, snapshot.embed)
        post1.setIfChanged(\.nsfw, snapshot.nsfw)
        post1.setIfChanged(\.thumbnailUrl, snapshot.thumbnailUrl)
        post1.setIfChanged(\.updated, snapshot.updated)
        post1.setIfChanged(\.languageId, snapshot.languageId)
        post1.setIfChanged(\.altText, snapshot.altText)
        post1.setIfChanged(\.deleted, snapshot.deleted)
        post1.setIfChanged(\.removed, snapshot.removed)
        post1.setIfChanged(\.removedPending, false)
        post1.setIfChanged(\.pinnedCommunity, snapshot.pinnedCommunity)
        post1.setIfChanged(\.pinnedCommunityPending, false)
        post1.setIfChanged(\.pinnedInstance, snapshot.pinnedInstance)
        post1.setIfChanged(\.pinnedInstancePending, false)
        post1.setIfChanged(\.locked, snapshot.locked)
        post1.setIfChanged(\.lockedPending, false)
        post1.setIfChanged(\.nsfwPending, false)
    }
    
    func takeSnapshot() -> any PostSnapshotProviding {
        takeSnapshot1()
    }
    
    func takeSnapshot1() -> Post1Snapshot {
        .init(
            actorId: actorId,
            id: id,
            creatorId: creatorId,
            communityId: communityId,
            created: created,
            title: title,
            content: content,
            linkUrl: linkUrl,
            embed: embed,
            nsfw: nsfw,
            thumbnailUrl: thumbnailUrl,
            updated: updated,
            languageId: languageId,
            altText: altText,
            deleted: deleted,
            removed: removed,
            pinnedCommunity: pinnedCommunity,
            pinnedInstance: pinnedInstance,
            locked: locked
        )
    }
}

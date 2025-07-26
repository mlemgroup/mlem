//
//  Community1Providing+Snapshots.swift
//  MlemMiddleware
//
//  Created by Eric Andrews on 2025-07-23.
//

extension Community1Providing {
    internal func takeSnapshot1() -> Community1Snapshot {
        .init(actorId: actorId,
              id: id,
              name: name,
              created: created,
              instanceId: instanceId,
              updated: updated,
              displayName: displayName,
              description: description,
              deleted: deleted,
              removed: removed,
              nsfw: nsfw,
              avatar: avatar,
              banner: banner,
              hidden: hidden,
              onlyModeratorsCanPost: onlyModeratorsCanPost,
              allPropertiesPresent: false
        )
    }
}

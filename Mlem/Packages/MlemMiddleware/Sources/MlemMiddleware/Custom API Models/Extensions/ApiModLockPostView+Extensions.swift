//
//  File.swift
//  MlemMiddleware
//
//  Created by Sjmarf on 2024-12-25.
//

import Foundation

extension ApiModLockPostView: ModlogEntryApiBacker {
    var published: Date { modLockPost.published }
    var moderatorId: Int { modLockPost.id }
    
    @MainActor
    func type(api: ApiClient) -> ModlogEntryType {
        .lockPost(
            api.caches.post1.getModel(api: api, from: post),
            community: api.caches.community1.getModel(api: api, from: community),
            locked: modLockPost.locked
        )
    }
}

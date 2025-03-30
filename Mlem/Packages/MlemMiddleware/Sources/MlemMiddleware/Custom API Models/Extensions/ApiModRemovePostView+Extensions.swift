//
//  ApiModRemovePostView+Extensions.swift
//  MlemMiddleware
//
//  Created by Sjmarf on 2024-12-25.
//

import Foundation

extension ApiModRemovePostView: ModlogEntryApiBacker {
    var published: Date { modRemovePost.published }
    var moderatorId: Int { modRemovePost.id }
    
    @MainActor
    func type(api: ApiClient) -> ModlogEntryType {
        .removePost(
            api.caches.post1.getModel(api: api, from: post),
            community: api.caches.community1.getModel(api: api, from: community),
            removed: modRemovePost.removed,
            reason: modRemovePost.reason
        )
    }
}

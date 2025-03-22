//
//  ApiModFeaturePostView+Extensions.swift
//  MlemMiddleware
//
//  Created by Sjmarf on 2024-12-26.
//

import Foundation

extension ApiModFeaturePostView: ModlogEntryApiBacker {
    var published: Date { modFeaturePost.published }
    var moderatorId: Int { modFeaturePost.id }
    
    @MainActor
    func type(api: ApiClient) -> ModlogEntryType {
        .pinPost(
            api.caches.post1.getModel(api: api, from: post),
            community: api.caches.community1.getModel(api: api, from: community),
            pinned: modFeaturePost.featured,
            type: modFeaturePost.isFeaturedCommunity ? .community : .local
        )
    }
}

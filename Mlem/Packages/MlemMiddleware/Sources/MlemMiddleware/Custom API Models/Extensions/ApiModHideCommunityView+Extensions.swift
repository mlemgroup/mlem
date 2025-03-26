//
//  ApiModHideCommunityView+Extensions.swift
//  MlemMiddleware
//
//  Created by Sjmarf on 2024-12-26.
//

import Foundation

extension ApiModHideCommunityView: ModlogEntryApiBacker {
    var published: Date { modHideCommunity.published }
    var moderator: ApiPerson? { admin }
    var moderatorId: Int { modHideCommunity.id }
    
    @MainActor
    func type(api: ApiClient) -> ModlogEntryType {
        .hideCommunity(
            api.caches.community1.getModel(api: api, from: community),
            hidden: modHideCommunity.hidden,
            reason: modHideCommunity.reason
        )
    }
}

//
//  ApiModAddCommunityView+Extensions.swift
//  MlemMiddleware
//
//  Created by Sjmarf on 2024-12-26.
//

import Foundation

extension ApiModAddCommunityView: ModlogEntryApiBacker {
    var published: Date { modAddCommunity.published }
    var moderatorId: Int { modAddCommunity.id }
    
    @MainActor
    func type(api: ApiClient) -> ModlogEntryType {
        .updatePersonModeratorStatus(
            person: api.caches.person1.getModel(api: api, from: otherPerson),
            community: api.caches.community1.getModel(api: api, from: community),
            appointed: !modAddCommunity.removed
        )
    }
}

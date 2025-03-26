//
//  ApiModTransferCommunityView+Extensions.swift
//  MlemMiddleware
//
//  Created by Sjmarf on 2024-12-26.
//

import Foundation

extension ApiModTransferCommunityView: ModlogEntryApiBacker {
    var published: Date { modTransferCommunity.published }
    var moderatorId: Int { modTransferCommunity.id }

    @MainActor
    func type(api: ApiClient) -> ModlogEntryType {
        .transferCommunityOwnership(
            person: api.caches.person1.getModel(api: api, from: otherPerson),
            community: api.caches.community1.getModel(api: api, from: community)
        )
    }
}

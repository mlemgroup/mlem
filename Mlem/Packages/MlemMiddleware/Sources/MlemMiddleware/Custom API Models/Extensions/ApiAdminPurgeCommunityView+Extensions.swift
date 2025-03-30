//
//  ApiAdminPurgeCommunityView+Extensions.swift
//  MlemMiddleware
//
//  Created by Sjmarf on 2024-12-26.
//

import Foundation

extension ApiAdminPurgeCommunityView: ModlogEntryApiBacker {
    var published: Date { adminPurgeCommunity.published }
    var moderator: ApiPerson? { admin }
    var moderatorId: Int { adminPurgeCommunity.id }
    
    @MainActor
    func type(api: ApiClient) -> ModlogEntryType {
        .purgeCommunity(reason: adminPurgeCommunity.reason)
    }
}

//
//  ApiModBanView+Extensions.swift
//  MlemMiddleware
//
//  Created by Sjmarf on 2024-12-28.
//

import Foundation

extension ApiModBanView: ModlogEntryApiBacker {
    var published: Date { modBan.published }
    var moderatorId: Int { modBan.id }
    
    @MainActor
    func type(api: ApiClient) -> ModlogEntryType {
        .banPersonFromInstance(
            person: api.caches.person1.getModel(api: api, from: otherPerson),
            banned: modBan.banned,
            reason: modBan.reason,
            expires: modBan.expires
        )
    }
}

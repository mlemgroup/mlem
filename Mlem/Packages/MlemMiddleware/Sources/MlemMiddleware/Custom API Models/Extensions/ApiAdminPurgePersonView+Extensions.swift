//
//  ApiAdminPurgePersonView+Extensions.swift
//  MlemMiddleware
//
//  Created by Sjmarf on 2024-12-28.
//

import Foundation

extension ApiAdminPurgePersonView: ModlogEntryApiBacker {
    var published: Date { adminPurgePerson.published }
    var moderator: ApiPerson? { admin }
    var moderatorId: Int { adminPurgePerson.id }
    
    @MainActor
    func type(api: ApiClient) -> ModlogEntryType {
        .purgePerson(reason: adminPurgePerson.reason)
    }
}

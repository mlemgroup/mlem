//
//  ApiModAddView+Extensions.swift
//  MlemMiddleware
//
//  Created by Sjmarf on 2024-12-27.
//  

import Foundation

extension ApiModAddView: ModlogEntryApiBacker {
    var published: Date { modAdd.published }
    var moderatorId: Int { modAdd.id }
    
    @MainActor
    func type(api: ApiClient) -> ModlogEntryType {
        .updatePersonAdminStatus(
            person: api.caches.person1.getModel(api: api, from: otherPerson),
            appointed: !modAdd.removed
        )
    }
}

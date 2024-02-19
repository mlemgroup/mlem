//
//  APIAdminPurgePersonView.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-02-18
//

import Foundation

// ---- AUTOMATICALLY GENERATED FILE, DO NOT MODIFY ---- //

// sources/js/types/AdminPurgePersonView.ts
struct APIAdminPurgePersonView: Codable {
    let admin_purge_person: APIAdminPurgePerson
    let admin: APIPerson?

    func toQueryItems() -> [URLQueryItem] {
        [
        ]
    }
}

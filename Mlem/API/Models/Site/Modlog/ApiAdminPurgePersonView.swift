//
//  ApiAdminPurgePersonView.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-02-27
//

import Foundation

// AdminPurgePersonView.ts
struct ApiAdminPurgePersonView: Decodable {
    let adminPurgePerson: ApiAdminPurgePerson
    let admin: APIPerson?
}
